import 'package:cryptography/cryptography.dart';
import 'package:flutter_test/flutter_test.dart';
import '../backend/core/local_accounts.dart';

void main() {
  LocalAccountService service() => LocalAccountService(
    passwordHasher: Pbkdf2(
      macAlgorithm: Hmac.sha256(),
      iterations: 10,
      bits: 256,
    ),
  );
  test(
    'register chosen username, sign out, verify password and reject wrong password',
    () async {
      final accounts = service();
      final account = await accounts.register(
        'MyPlayer',
        'a long test password',
      );
      expect(account.displayName, 'MyPlayer');
      expect(accounts.currentAccount, account);
      accounts.signOut();
      expect(accounts.currentAccount, isNull);
      await expectLater(
        accounts.signIn('MyPlayer', 'wrong password'),
        throwsA(isA<AccountException>()),
      );
      expect(accounts.currentAccount, isNull);
      expect(
        (await accounts.signIn(' myplayer ', 'a long test password')).id,
        account.id,
      );
    },
  );
  test(
    'duplicate case-insensitive usernames and weak password rejected',
    () async {
      final accounts = service();
      await accounts.register('Player', 'a long test password');
      await expectLater(
        accounts.register('PLAYER', 'another long password'),
        throwsA(isA<AccountException>()),
      );
      await expectLater(
        accounts.register('other', 'short'),
        throwsA(isA<AccountException>()),
      );
      await expectLater(
        accounts.register(' ', 'a long test password'),
        throwsA(isA<AccountException>()),
      );
    },
  );
  test(
    'unknown account cannot sign in and profiles have independent identities',
    () async {
      final accounts = service();
      await expectLater(
        accounts.signIn('unknown', 'a long test password'),
        throwsA(isA<AccountException>()),
      );
      final a = await accounts.register('alice', 'a long test password');
      final b = await accounts.register('bob', 'a long test password');
      expect(a.id, isNot(b.id));
    },
  );
  test('parallel registration cannot overwrite a username', () async {
    final accounts = service();
    final results = await Future.wait([
      accounts
          .register('same', 'a long test password')
          .then<Object>((a) => a, onError: (Object e) => e),
      accounts
          .register('same', 'a different password')
          .then<Object>((a) => a, onError: (Object e) => e),
    ]);
    expect(results.whereType<AccountException>().length, 1);
    accounts.signOut();
    await accounts.signIn('same', 'a long test password');
  });
}
