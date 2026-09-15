import 'models.dart';

abstract interface class CompanyRepository {
  Future<CompanyState?> loadCompany(String companyId);
  Future<void> saveCompany(CompanyState state);
}

abstract interface class CommandLedger {
  Future<bool> hasProcessed(String commandId);
  Future<void> markProcessed(String commandId);
}

abstract interface class EventStore {
  Future<void> append(GameEvent event);
  Future<List<GameEvent>> eventsAfter(String companyId, int revision);
}

class RevisionConflict implements Exception {
  const RevisionConflict(this.expected, this.actual);
  final int expected;
  final int actual;

  @override
  String toString() => 'RevisionConflict(expected: $expected, actual: $actual)';
}
