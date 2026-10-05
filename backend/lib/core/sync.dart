import 'models.dart';
import 'repository.dart';

class SyncRequest {
  const SyncRequest({
    required this.accountId,
    required this.companyId,
    required this.deviceId,
    required this.localRevision,
  });

  final String accountId;
  final String companyId;
  final String deviceId;
  final int localRevision;
}

class SyncResponse {
  const SyncResponse({
    required this.authoritativeRevision,
    required this.company,
    required this.events,
    required this.serverTimestampUtc,
  });

  final int authoritativeRevision;
  final CompanyState company;
  final List<GameEvent> events;
  final DateTime serverTimestampUtc;
}

class SyncService {
  const SyncService({required this.companies, required this.events});

  final CompanyRepository companies;
  final EventStore events;

  Future<SyncResponse> synchronize(SyncRequest request) async {
    final company = await companies.loadCompany(request.companyId);
    if (company == null) throw StateError('Company not found.');
    if (company.accountId != request.accountId) throw StateError('Account does not own company.');

    return SyncResponse(
      authoritativeRevision: company.revision,
      company: company,
      events: await events.eventsAfter(company.id, request.localRevision),
      serverTimestampUtc: DateTime.now().toUtc(),
    );
  }
}
