import 'dart:math';
import 'package:cryptography/cryptography.dart';
import 'models.dart';

/// Alpha accounts live only in this process. Never persist plaintext passwords.
class LocalAccountService {
  LocalAccountService({Pbkdf2? passwordHasher})
    : _hasher =
          passwordHasher ??
          Pbkdf2(macAlgorithm: Hmac.sha256(), iterations: 600000, bits: 256);

  final Pbkdf2 _hasher;
  final _random = Random.secure();
  final Map<String, _Credential> _accounts = {};
  final Set<String> _registering = {};
  PlayerAccount? currentAccount;

  Future<PlayerAccount> register(String username, String password) async {
    final name = username.trim();
    if (!RegExp(r'^[a-zA-Z0-9_.-]{3,32}$').hasMatch(name)) {
      throw const AccountException(
        'Use a username of 3–32 letters, numbers, dots, underscores or hyphens.',
      );
    }
    if (password.length < 12 || password.length > 128) {
      throw const AccountException('Use a password of 12–128 characters.');
    }
    final key = name.toLowerCase();
    if (_accounts.containsKey(key) || !_registering.add(key)) {
      throw const AccountException('That username is already in use.');
    }
    try {
      final salt = List<int>.generate(16, (_) => _random.nextInt(256));
      final hash = await _hash(password, salt);
      final account = PlayerAccount(
        id: List.generate(
          16,
          (_) => _random.nextInt(256).toRadixString(16).padLeft(2, '0'),
        ).join(),
        displayName: name,
        preferredTimeZone: 'UTC',
        createdAtUtc: DateTime.now().toUtc(),
      );
      _accounts[key] = _Credential(account, salt, hash);
      currentAccount = account;
      return account;
    } finally {
      _registering.remove(key);
    }
  }

  Future<PlayerAccount> signIn(String username, String password) async {
    if (password.length > 128 || username.length > 64) {
      throw const AccountException('Incorrect username or password.');
    }
    final credential = _accounts[username.trim().toLowerCase()];
    // Derive for unknown users as well; never authenticate by display name alone.
    final candidate = await _hash(
      password,
      credential?.salt ?? List.filled(16, 0),
    );
    final expected = credential?.hash ?? List.filled(32, 0);
    var difference = candidate.length ^ expected.length;
    for (var i = 0; i < expected.length; i++) {
      difference |= candidate[i] ^ expected[i];
    }
    if (credential == null || difference != 0) {
      throw const AccountException('Incorrect username or password.');
    }
    currentAccount = credential.account;
    return credential.account;
  }

  void signOut() => currentAccount = null;

  Future<List<int>> _hash(String password, List<int> salt) async =>
      (await _hasher.deriveKeyFromPassword(
        password: password,
        nonce: salt,
      )).extractBytes();
}

class _Credential {
  _Credential(this.account, this.salt, this.hash);
  final PlayerAccount account;
  final List<int> salt, hash;
}

class AccountException implements Exception {
  const AccountException(this.message);
  final String message;
}
