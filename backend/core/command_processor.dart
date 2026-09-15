import 'models.dart';
import 'repository.dart';

class CommandResult {
  const CommandResult({
    required this.accepted,
    required this.company,
    this.events = const [],
    this.reason,
  });

  final bool accepted;
  final CompanyState? company;
  final List<GameEvent> events;
  final String? reason;
}

class CommandProcessor {
  CommandProcessor({
    required this.companies,
    required this.ledger,
    required this.events,
  });

  final CompanyRepository companies;
  final CommandLedger ledger;
  final EventStore events;

  Future<CommandResult> execute(GameCommand command) async {
    if (await ledger.hasProcessed(command.commandId)) {
      return CommandResult(
        accepted: true,
        company: await companies.loadCompany(command.companyId),
        reason: 'Command already processed.',
      );
    }

    final company = await companies.loadCompany(command.companyId);
    if (company == null) {
      return const CommandResult(accepted: false, company: null, reason: 'Company not found.');
    }
    if (company.accountId != command.accountId) {
      return CommandResult(accepted: false, company: company, reason: 'Account does not own company.');
    }
    if (company.revision != command.expectedRevision) {
      throw RevisionConflict(command.expectedRevision, company.revision);
    }

    switch (command.type) {
      case 'setSimulationSpeed':
        return _setSimulationSpeed(company, command);
      default:
        return CommandResult(
          accepted: false,
          company: company,
          reason: 'Unsupported command: ${command.type}',
        );
    }
  }

  Future<CommandResult> _setSimulationSpeed(CompanyState company, GameCommand command) async {
    final requested = command.payload['speed'] as String?;
    final speed = switch (requested) {
      'PAUSED' => SimulationSpeed.paused,
      'X1' => SimulationSpeed.x1,
      'X2' => SimulationSpeed.x2,
      'X5' => SimulationSpeed.x5,
      'X10' => SimulationSpeed.x10,
      _ => null,
    };
    if (speed == null) {
      return CommandResult(accepted: false, company: company, reason: 'Invalid simulation speed.');
    }

    final next = CompanyState(
      id: company.id,
      accountId: company.accountId,
      name: company.name,
      cashCents: company.cashCents,
      reputation: company.reputation,
      progression: company.progression,
      simulation: company.simulation.copyWith(speed: speed),
      revision: company.revision + 1,
    );
    final event = GameEvent(
      eventId: '${command.commandId}:simulation-speed',
      companyId: company.id,
      revision: next.revision,
      type: 'simulationSpeedChanged',
      gameTimeUtc: next.simulation.gameTimeUtc,
      payload: {'speed': requested},
    );

    await companies.saveCompany(next);
    await events.append(event);
    await ledger.markProcessed(command.commandId);
    return CommandResult(accepted: true, company: next, events: [event]);
  }
}
