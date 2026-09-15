import 'models.dart';
import 'repository.dart';

class InMemoryCompanyRepository implements CompanyRepository {
  final Map<String, CompanyState> _companies = {};

  @override
  Future<CompanyState?> loadCompany(String companyId) async => _companies[companyId];

  @override
  Future<void> saveCompany(CompanyState state) async {
    _companies[state.id] = state;
  }
}

class InMemoryCommandLedger implements CommandLedger {
  final Set<String> _processed = {};

  @override
  Future<bool> hasProcessed(String commandId) async => _processed.contains(commandId);

  @override
  Future<void> markProcessed(String commandId) async {
    _processed.add(commandId);
  }
}

class InMemoryEventStore implements EventStore {
  final List<GameEvent> _events = [];

  @override
  Future<void> append(GameEvent event) async => _events.add(event);

  @override
  Future<List<GameEvent>> eventsAfter(String companyId, int revision) async => _events
      .where((event) => event.companyId == companyId && event.revision > revision)
      .toList(growable: false);
}
