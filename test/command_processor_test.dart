import 'package:flutter_test/flutter_test.dart';
import 'package:truck_manager_backend/core/backend_core.dart';

void main() {
  late InMemoryCompanyRepository companies;
  late InMemoryCommandLedger ledger;
  late InMemoryEventStore events;
  late CommandProcessor processor;
  var sequence = 0;
  GameCommand command(
    String type,
    int revision, {
    String? id,
    String owner = 'alice',
    String company = 'company',
    Map<String, Object?> payload = const {},
  }) => GameCommand(
    commandId: id ?? '${++sequence}',
    accountId: owner,
    companyId: company,
    deviceId: 'test',
    expectedRevision: revision,
    type: type,
    issuedAtUtc: DateTime.utc(2026, 10, 2),
    payload: payload,
  );
  Future<CommandResult> create({String difficulty = 'Standard'}) =>
      processor.execute(
        command(
          'createCompany',
          0,
          payload: {'name': 'Independent Freight', 'difficulty': difficulty},
        ),
      );

  setUp(() {
    sequence = 0;
    companies = InMemoryCompanyRepository();
    ledger = InMemoryCommandLedger();
    events = InMemoryEventStore();
    processor = CommandProcessor(
      companies: companies,
      ledger: ledger,
      events: events,
    );
  });

  test(
    'company name, owner, capital, revision and UTC event are authoritative',
    () async {
      final result = await create();
      expect(result.accepted, isTrue);
      expect(result.company!.name, 'Independent Freight');
      expect(result.company!.accountId, 'alice');
      expect(result.company!.cashCents, 10000000);
      expect(result.company!.revision, 1);
      expect(result.events.single.type, 'companyCreated');
      expect(result.company!.simulation.gameTimeUtc.isUtc, isTrue);
    },
  );
  test('used starter purchase creates one priced unit even on retry', () async {
    await create(difficulty: 'Realistic');
    final buy = command(
      'purchaseVehicle',
      1,
      payload: {'catalogId': 'used-pickup', 'priceCents': 1},
    );
    final result = await processor.execute(buy);
    final c = result.company!;
    expect(c.cashCents, 4200000);
    expect(c.fleet.single.used, isTrue);
    expect(c.fleet.single.purchasePriceCents, 800000);
    expect(c.fleet.single.city, 'Dallas, TX');
    expect((await processor.execute(buy)).company!.fleet.length, 1);
    expect(() => c.fleet.clear(), throwsUnsupportedError);
    expect(
      (await processor.execute(
        command('purchaseVehicle', 2, payload: {'catalogId': 'made-up-truck'}),
      )).accepted,
      isFalse,
    );
  });
  test(
    'driver assignments reject foreign units, double booking and busy changes',
    () async {
      await create();
      final purchased = await processor.execute(
        command('purchaseVehicle', 1, payload: {'catalogId': 'used-van'}),
      );
      final truck = purchased.company!.fleet.single;
      final hired = await processor.execute(
        command('hireEmployee', 2, payload: {'name': 'Morgan'}),
      );
      final driver = hired.company!.drivers.single;
      expect(driver.name, 'Morgan');
      expect(
        (await processor.execute(
          command(
            'assignDriver',
            3,
            payload: {
              'driverId': driver.id,
              'truckId': 'another-company-truck',
            },
          ),
        )).accepted,
        isFalse,
      );
      await processor.execute(
        command(
          'assignDriver',
          3,
          payload: {'driverId': driver.id, 'truckId': truck.id},
        ),
      );
      final second = await processor.execute(command('hireEmployee', 4));
      expect(
        (await processor.execute(
          command(
            'assignDriver',
            5,
            payload: {
              'driverId': second.company!.drivers.last.id,
              'truckId': truck.id,
            },
          ),
        )).accepted,
        isFalse,
      );
      final dispatched = await processor.execute(command('acceptLoad', 5));
      final load = dispatched.company!.loads.single;
      expect(load.driverId, driver.id);
      expect(load.truckId, truck.id);
      expect(
        (await processor.execute(
          command(
            'assignDriver',
            6,
            payload: {'driverId': driver.id, 'truckId': null},
          ),
        )).accepted,
        isFalse,
      );
      final finished = (await processor.execute(
        command('completeLoad', 6, payload: {'loadId': load.id}),
      )).company!;
      expect(finished.fleet.single.city, load.destination);
      expect(
        finished.fleet.single.latitude,
        findGameCity(load.destination)!.latitude,
      );
      expect(finished.fleet.single.mileage, truck.mileage + load.miles);
      expect(finished.drivers.first.milesDriven, load.miles);
      expect(dispatched.company!.fleet.single.city, truck.city);
    },
  );
  test('blank name and invalid difficulty do not create or emit', () async {
    final result = await processor.execute(
      command(
        'createCompany',
        0,
        payload: {'name': ' ', 'difficulty': 'Standard'},
      ),
    );
    expect(result.accepted, isFalse);
    expect(await companies.loadCompany('company'), isNull);
    expect(await events.eventsAfter('company', 0), isEmpty);
  });
  test(
    'first playable loop pays once and capacity cannot be reused early',
    () async {
      await create();
      expect(
        (await processor.execute(command('acceptLoad', 1))).accepted,
        isFalse,
      );
      await processor.execute(command('purchaseVehicle', 1));
      await processor.execute(command('hireEmployee', 2));
      await processor.execute(command('acceptLoad', 3));
      expect(
        (await processor.execute(command('acceptLoad', 4))).accepted,
        isFalse,
      );
      final finish = command('completeLoad', 4, id: 'delivery');
      final delivered = await processor.execute(finish);
      expect(delivered.company!.cashCents, 5350000);
      expect(delivered.company!.activeLoads, 0);
      expect(delivered.company!.progression.xp, 100);
      final retry = await processor.execute(finish);
      expect(retry.company!.revision, 5);
      expect(retry.events, isEmpty);
      expect((await events.eventsAfter('company', 0)).length, 5);
      expect(
        (await processor.execute(command('completeLoad', 5))).accepted,
        isFalse,
      );
    },
  );
  test(
    'ownership checked even for duplicate commands, with no state leak',
    () async {
      await create();
      final result = await processor.execute(
        command('setSimulationSpeed', 1, id: 'speed', payload: {'speed': 'X2'}),
      );
      expect(result.accepted, isTrue);
      final attacker = await processor.execute(
        command(
          'setSimulationSpeed',
          1,
          id: 'speed',
          owner: 'bob',
          payload: {'speed': 'X2'},
        ),
      );
      expect(attacker.accepted, isFalse);
      expect(attacker.company, isNull);
      expect((await companies.loadCompany('company'))!.revision, 2);
    },
  );
  test(
    'parallel stale commands cannot both mutate the same revision',
    () async {
      await create();
      final outcomes = await Future.wait([
        processor
            .execute(command('purchaseVehicle', 1))
            .then<Object>((r) => r, onError: (Object e) => e),
        processor
            .execute(command('hireEmployee', 1))
            .then<Object>((r) => r, onError: (Object e) => e),
      ]);
      expect(outcomes.whereType<CommandResult>().length, 1);
      expect(outcomes.whereType<RevisionConflict>().length, 1);
      expect((await companies.loadCompany('company'))!.revision, 2);
    },
  );
  test(
    'malformed speed, unsupported command, insufficient cash do not mutate',
    () async {
      await create(difficulty: 'Realistic');
      expect(
        (await processor.execute(
          command('setSimulationSpeed', 1, payload: {'speed': 5}),
        )).accepted,
        isFalse,
      );
      expect(
        (await processor.execute(command('unknown', 1))).accepted,
        isFalse,
      );
      await processor.execute(command('purchaseVehicle', 1));
      expect(
        (await processor.execute(command('purchaseVehicle', 2))).accepted,
        isFalse,
      );
      expect((await companies.loadCompany('company'))!.cashCents, 200000);
    },
  );
  test(
    'bank rejects negative and over-limit amounts, caps repayment at debt',
    () async {
      await create();
      expect(
        (await processor.execute(
          command('borrowMoney', 1, payload: {'amountCents': -1}),
        )).accepted,
        isFalse,
      );
      expect(
        (await processor.execute(
          command('borrowMoney', 1, payload: {'amountCents': 25000001}),
        )).accepted,
        isFalse,
      );
      await processor.execute(
        command('borrowMoney', 1, payload: {'amountCents': 2500000}),
      );
      final repaid = await processor.execute(
        command('repayLoan', 2, payload: {'amountCents': 5000000}),
      );
      expect(repaid.company!.cashCents, 10000000);
      expect(repaid.company!.debtCents, 0);
    },
  );
  test(
    'event replay filters by company and revision and protects payload',
    () async {
      await create();
      await processor.execute(
        command('setSimulationSpeed', 1, payload: {'speed': 'X5'}),
      );
      final replay = await events.eventsAfter('company', 1);
      expect(replay.length, 1);
      expect(replay.single.revision, 2);
      expect(await events.eventsAfter('other-company', 0), isEmpty);
      expect(
        () => replay.single.payload['speed'] = 'X10',
        throwsUnsupportedError,
      );
    },
  );
}
