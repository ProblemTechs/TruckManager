import 'dart:async';
import 'models.dart';
import 'repository.dart';
import 'progression.dart';

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

/// A single processor serializes access to its in-memory repositories.
/// The account ID must come from the signed-in session, never from a UI field.
class CommandProcessor {
  CommandProcessor({
    required this.companies,
    required this.ledger,
    required this.events,
  });
  final CompanyRepository companies;
  final CommandLedger ledger;
  final EventStore events;
  Future<void> _pending = Future.value();

  Future<CommandResult> execute(GameCommand command) {
    final result = _pending.then((_) => _execute(command));
    _pending = result.then<void>((_) {}, onError: (Object _, StackTrace __) {});
    return result;
  }

  Future<CommandResult> _execute(GameCommand command) async {
    final company = await companies.loadCompany(command.companyId);
    CommandResult reject(String reason) =>
        CommandResult(accepted: false, company: null, reason: reason);
    if (command.commandId.isEmpty ||
        command.accountId.isEmpty ||
        command.companyId.isEmpty) {
      return reject('Missing command identity.');
    }
    // Ownership is checked before the retry path to avoid leaking another account's state.
    if (company != null && company.accountId != command.accountId) {
      return reject('Account does not own company.');
    }
    final ledgerKey =
        '${command.accountId.length}:${command.accountId}:${command.companyId.length}:${command.companyId}:${command.commandId}';
    if (await ledger.hasProcessed(ledgerKey)) {
      return CommandResult(
        accepted: true,
        company: company,
        reason: 'Command already processed.',
      );
    }
    CompanyState next;
    String eventType;
    if (command.type == 'createCompany') {
      if (company != null) return reject('Company already exists.');
      if (command.expectedRevision != 0)
        throw RevisionConflict(command.expectedRevision, 0);
      final name = command.payload['name'];
      final difficulty = command.payload['difficulty'];
      final cash = switch (difficulty) {
        'Relaxed' => 25000000,
        'Standard' => 10000000,
        'Realistic' => 5000000,
        _ => null,
      };
      if (name is! String ||
          name.trim().isEmpty ||
          name.trim().length > 80 ||
          cash == null) {
        return reject(
          'Enter a company name (1–80 characters) and valid difficulty.',
        );
      }
      next = CompanyState(
        id: command.companyId,
        accountId: command.accountId,
        name: name.trim(),
        cashCents: cash,
        reputation: 50,
        progression: const CompanyProgression(level: 1, xp: 0),
        simulation: SimulationClock(gameTimeUtc: command.issuedAtUtc.toUtc()),
        revision: 1,
      );
      eventType = 'companyCreated';
    } else {
      if (company == null) return reject('Company not found.');
      if (company.revision != command.expectedRevision)
        throw RevisionConflict(command.expectedRevision, company.revision);
      switch (command.type) {
        case 'setSimulationSpeed':
          final speed = switch (command.payload['speed']) {
            'PAUSED' => SimulationSpeed.paused,
            'X1' => SimulationSpeed.x1,
            'X2' => SimulationSpeed.x2,
            'X5' => SimulationSpeed.x5,
            'X10' => SimulationSpeed.x10,
            _ => null,
          };
          if (speed == null) return reject('Invalid simulation speed.');
          next = company.copyWith(
            simulation: company.simulation.copyWith(speed: speed),
          );
          eventType = 'simulationSpeedChanged';
        case 'purchaseVehicle':
          // Starter catalogue price; client-supplied prices are never used.
          const price = 4800000;
          if (company.cashCents < price)
            return reject('Not enough cash to buy the starter cargo van.');
          next = company.copyWith(
            cashCents: company.cashCents - price,
            truckCount: company.truckCount + 1,
          );
          eventType = 'vehiclePurchased';
        case 'hireEmployee':
          if (company.cashCents < 100000)
            return reject('Not enough cash to hire a driver.');
          next = company.copyWith(
            cashCents: company.cashCents - 100000,
            driverCount: company.driverCount + 1,
          );
          eventType = 'employeeHired';
        case 'acceptLoad':
          if (company.activeLoads >= company.truckCount ||
              company.activeLoads >= company.driverCount) {
            return reject('A free vehicle and driver are required.');
          }
          next = company.copyWith(activeLoads: company.activeLoads + 1);
          eventType = 'loadStatusChanged';
        case 'completeLoad':
          if (company.activeLoads == 0)
            return reject('No active load to complete.');
          final xp = company.progression.xp + 100;
          var level = company.progression.level;
          while (xp >= xpRequiredForLevel(level + 1)) {
            level++;
          }
          next = company.copyWith(
            activeLoads: company.activeLoads - 1,
            cashCents: company.cashCents + 250000,
            progression: CompanyProgression(level: level, xp: xp),
          );
          eventType = 'loadStatusChanged';
        case 'borrowMoney':
        case 'repayLoan':
          final amount = command.payload['amountCents'];
          if (amount is! int || amount <= 0)
            return reject('Enter a positive whole-cent amount.');
          if (command.type == 'borrowMoney') {
            if (amount > 25000000 - company.debtCents)
              return reject('Credit limit exceeded.');
            next = company.copyWith(
              cashCents: company.cashCents + amount,
              debtCents: company.debtCents + amount,
            );
          } else {
            final payment = amount > company.debtCents
                ? company.debtCents
                : amount;
            if (payment == 0 || payment > company.cashCents)
              return reject('Cannot make that loan payment.');
            next = company.copyWith(
              cashCents: company.cashCents - payment,
              debtCents: company.debtCents - payment,
            );
          }
          eventType = 'financeUpdated';
        default:
          return reject('Unsupported command: ${command.type}');
      }
    }
    final event = GameEvent(
      eventId: '${command.companyId}:${command.commandId}',
      companyId: next.id,
      revision: next.revision,
      type: eventType,
      gameTimeUtc: next.simulation.gameTimeUtc,
      payload: Map.unmodifiable({
        'command': command.type,
        'cashCents': next.cashCents,
        'activeLoads': next.activeLoads,
        'speed': next.simulation.speed.name,
      }),
    );
    // These in-memory implementations do not fail. Durable storage will need a transaction.
    await companies.saveCompany(next);
    await events.append(event);
    await ledger.markProcessed(ledgerKey);
    return CommandResult(
      accepted: true,
      company: next,
      events: List.unmodifiable([event]),
    );
  }
}
