import 'dart:async';
import 'dart:math' as math;
import 'models.dart';
import 'repository.dart';
import 'progression.dart';
import 'vehicle_catalog.dart';

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
      final startingCity = command.payload['startingCity'] ?? 'Dallas, TX';
      if (startingCity is! String || findGameCity(startingCity) == null)
        return reject('Choose a valid starting city.');
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
        startingCity: startingCity,
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
          final offerId = command.payload['catalogId'] ?? 'new-van';
          final offer = offerId is String ? findVehicleOffer(offerId) : null;
          if (offer == null)
            return reject('Choose a vehicle from the catalogue.');
          if (company.cashCents < offer.priceCents)
            return reject('Not enough cash to buy this vehicle.');
          final city = findGameCity(company.startingCity)!;
          final vehicle = FleetVehicle(
            id: '${company.id}:vehicle:${command.commandId}',
            unitNumber: '${1001 + company.fleet.length}',
            catalogId: offer.id,
            name: offer.name,
            vehicleClass: offer.vehicleClass,
            used: offer.used,
            year: offer.year,
            purchasePriceCents: offer.priceCents,
            mileage: offer.mileage,
            conditionPercent: offer.conditionPercent,
            city: city.name,
            latitude: city.latitude,
            longitude: city.longitude,
          );
          next = company.copyWith(
            cashCents: company.cashCents - offer.priceCents,
            fleet: [...company.fleet, vehicle],
          );
          eventType = 'vehiclePurchased';
        case 'hireEmployee':
          if (company.cashCents < 100000)
            return reject('Not enough cash to hire a driver.');
          final enteredName = command.payload['name'];
          if (enteredName != null &&
              (enteredName is! String ||
                  enteredName.trim().isEmpty ||
                  enteredName.trim().length > 60)) {
            return reject('Enter a driver name (1–60 characters).');
          }
          final driver = CompanyDriver(
            id: '${company.id}:driver:${command.commandId}',
            name: enteredName is String
                ? enteredName.trim()
                : 'Driver ${company.drivers.length + 1}',
          );
          next = company.copyWith(
            cashCents: company.cashCents - 100000,
            drivers: [...company.drivers, driver],
          );
          eventType = 'employeeHired';
        case 'assignDriver':
          final driverId = command.payload['driverId'];
          final truckId = command.payload['truckId'];
          final index = company.drivers.indexWhere((d) => d.id == driverId);
          if (index < 0 ||
              (truckId != null && !company.fleet.any((t) => t.id == truckId)))
            return reject('Choose a driver and vehicle owned by this company.');
          if (company.loads.any(
            (l) =>
                !l.delivered &&
                (l.driverId == driverId || l.truckId == truckId),
          ))
            return reject('Cannot change an assignment during an active load.');
          if (truckId != null &&
              company.drivers.any(
                (d) => d.id != driverId && d.truckId == truckId,
              ))
            return reject('That vehicle already has a driver.');
          final updated = [...company.drivers];
          updated[index] = updated[index].assignedTo(truckId as String?);
          next = company.copyWith(drivers: updated);
          eventType = 'driverAssigned';
        case 'acceptLoad':
          final freeDrivers = company.drivers.where(
            (d) =>
                !company.loads.any((l) => !l.delivered && l.driverId == d.id),
          );
          CompanyDriver? driver;
          FleetVehicle? truck;
          // Use an existing free assignment first, then assign an unassigned driver automatically.
          for (final candidate in freeDrivers) {
            if (candidate.truckId == null) continue;
            for (final vehicle in company.fleet) {
              if (vehicle.id == candidate.truckId &&
                  !company.loads.any(
                    (l) => !l.delivered && l.truckId == vehicle.id,
                  )) {
                driver = candidate;
                truck = vehicle;
                break;
              }
            }
            if (truck != null) break;
          }
          if (truck == null) {
            for (final candidate in freeDrivers.where(
              (d) => d.truckId == null,
            )) {
              for (final vehicle in company.fleet) {
                if (!company.drivers.any((d) => d.truckId == vehicle.id) &&
                    !company.loads.any(
                      (l) => !l.delivered && l.truckId == vehicle.id,
                    )) {
                  driver = candidate;
                  truck = vehicle;
                  break;
                }
              }
              if (truck != null) break;
            }
          }
          if (truck == null || driver == null)
            return reject('A free vehicle and driver are required.');
          final origin = findGameCity(truck.city)!;
          final destinations =
              gameCities.where((c) => c.name != truck!.city).toList()..sort(
                (a, b) => _distanceMiles(
                  origin,
                  a,
                ).compareTo(_distanceMiles(origin, b)),
              );
          final destination = destinations.first;
          final load = CompanyLoad(
            id: '${company.id}:load:${command.commandId}',
            truckId: truck.id,
            driverId: driver.id,
            origin: truck.city,
            destination: destination.name,
            miles: _distanceMiles(origin, destination),
          );
          final assigned = driver.assignedTo(truck.id);
          next = company.copyWith(
            loads: [...company.loads, load],
            drivers: company.drivers
                .map((d) => d.id == assigned.id ? assigned : d)
                .toList(),
          );
          eventType = 'loadStatusChanged';
        case 'completeLoad':
          final active = company.loads.where((l) => !l.delivered);
          final requestedId = command.payload['loadId'];
          final matches = active.where(
            (l) => requestedId == null || l.id == requestedId,
          );
          if (matches.isEmpty) return reject('No active load to complete.');
          final load = matches.first;
          final destination = findGameCity(load.destination)!;
          final xp = company.progression.xp + 100;
          var level = company.progression.level;
          while (xp >= xpRequiredForLevel(level + 1)) {
            level++;
          }
          next = company.copyWith(
            cashCents: company.cashCents + load.revenueCents,
            loads: company.loads
                .map((l) => l.id == load.id ? l.complete() : l)
                .toList(),
            fleet: company.fleet
                .map(
                  (t) => t.id == load.truckId
                      ? t.movedTo(destination, load.miles)
                      : t,
                )
                .toList(),
            drivers: company.drivers
                .map((d) => d.id == load.driverId ? d.addMiles(load.miles) : d)
                .toList(),
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

// Approximate route miles for the starter load; not turn-by-turn road routing.
int _distanceMiles(GameCity a, GameCity b) {
  final lat1 = a.latitude * math.pi / 180;
  final lat2 = b.latitude * math.pi / 180;
  final dlat = lat2 - lat1;
  final dlon = (b.longitude - a.longitude) * math.pi / 180;
  final h =
      math.pow(math.sin(dlat / 2), 2) +
      math.cos(lat1) * math.cos(lat2) * math.pow(math.sin(dlon / 2), 2);
  return (3959 * 2 * math.asin(math.sqrt(h)) * 1.2).round();
}
