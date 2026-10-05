import 'package:flutter/foundation.dart';
import '../backend/core/backend_core.dart';
import '../backend/core/local_accounts.dart';

/// UI adapter: the command processor owns all gameplay mutations.
class TruckGameState extends ChangeNotifier {
  final accounts = LocalAccountService();
  final _companies = InMemoryCompanyRepository();
  final _ledger = InMemoryCommandLedger();
  final _events = InMemoryEventStore();
  late final _processor = CommandProcessor(
    companies: _companies,
    ledger: _ledger,
    events: _events,
  );
  CompanyState? _company;
  int _commandSequence = 0;
  String? lastError;
  String get playerName => accounts.currentAccount?.displayName ?? '';
  String get companyName => _company?.name ?? '';
  bool get hasCompany => _company != null;
  int get cashCents => _company?.cashCents ?? 0;
  int get debtCents => _company?.debtCents ?? 0;
  int get companyLevel => _company?.progression.level ?? 1;
  int get companyXp => _company?.progression.xp ?? 0;
  int get truckCount => _company?.truckCount ?? 0;
  int get driverCount => _company?.driverCount ?? 0;
  int get activeLoads => _company?.activeLoads ?? 0;
  int get speed => switch (_company?.simulation.speed) {
    SimulationSpeed.x1 => 1,
    SimulationSpeed.x2 => 2,
    SimulationSpeed.x5 => 5,
    SimulationSpeed.x10 => 10,
    _ => 0,
  };
  bool get paused => speed == 0;
  double get cash => cashCents / 100;
  double get debt => debtCents / 100;
  double get availableCredit => (25000000 - debtCents) / 100;
  bool get usedMarketAvailable => true;

  Future<void> selectSignedInAccount() async {
    final account = accounts.currentAccount;
    _company = account == null
        ? null
        : await _companies.loadCompany('company:${account.id}');
    lastError = null;
    notifyListeners();
  }

  void signOut() {
    accounts.signOut();
    _company = null;
    lastError = null;
    notifyListeners();
  }

  Future<bool> createCompany(String name, String difficulty) =>
      _send('createCompany', {'name': name, 'difficulty': difficulty});
  Future<bool> borrowMoney(int amountCents) =>
      _send('borrowMoney', {'amountCents': amountCents});
  Future<bool> repayLoan(int amountCents) =>
      _send('repayLoan', {'amountCents': amountCents});
  Future<bool> purchaseStarterTruck() => _send('purchaseVehicle');
  Future<bool> hireDriver() => _send('hireEmployee');
  Future<bool> acceptLoad() => _send('acceptLoad');
  Future<bool> completeLoad() => _send('completeLoad');
  Future<bool> setSpeed(int multiplier) => _send('setSimulationSpeed', {
    'speed': {0: 'PAUSED', 1: 'X1', 2: 'X2', 5: 'X5', 10: 'X10'}[multiplier],
  });

  Future<bool> _send(
    String type, [
    Map<String, Object?> payload = const {},
  ]) async {
    final account = accounts.currentAccount;
    if (account == null) {
      lastError = 'Sign in first.';
      notifyListeners();
      return false;
    }
    try {
      final result = await _processor.execute(
        GameCommand(
          commandId: 'local:${++_commandSequence}',
          accountId: account.id,
          companyId: 'company:${account.id}',
          deviceId: 'local-alpha',
          expectedRevision: _company?.revision ?? 0,
          type: type,
          issuedAtUtc: DateTime.now().toUtc(),
          payload: payload,
        ),
      );
      // A completed request must never switch state after signing into another account.
      if (accounts.currentAccount?.id != account.id) return false;
      if (result.accepted) _company = result.company;
      lastError = result.accepted ? null : result.reason;
      notifyListeners();
      return result.accepted;
    } on RevisionConflict {
      if (accounts.currentAccount?.id != account.id) return false;
      _company = await _companies.loadCompany('company:${account.id}');
      lastError = 'The company changed. Please try the action again.';
      notifyListeners();
      return false;
    }
  }
}

final truckGameState = TruckGameState();
