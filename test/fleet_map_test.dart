import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import '../lib/fleet_pages.dart';
import '../lib/formatters.dart';
import '../lib/game_state.dart';
import '../lib/map_page.dart';

void main() {
  test('money groups dollars without losing cents or negative signs', () {
    expect(money(0), '\$0.00');
    expect(money(9), '\$0.09');
    expect(money(123456789), '\$1,234,567.89');
    expect(money(-123456), '-\$1,234.56');
  });
  test('all states, insets and station provenance are bundled', () async {
    TestWidgetsFlutterBinding.ensureInitialized();
    final outlines =
        jsonDecode(await rootBundle.loadString('assets/maps/us_states.json'))
            as Map;
    final states = outlines['states'] as List;
    expect(states.length, 51);
    expect(states.every((s) => (s['rings'] as List).isNotEmpty), isTrue);
    final data =
        jsonDecode(
              await rootBundle.loadString('assets/maps/weigh_stations.json'),
            )
            as Map;
    expect(data['complete'], isFalse);
    final stations = data['stations'] as List;
    expect(stations, isNotEmpty);
    expect(stations.map((s) => s['id']).toSet().length, stations.length);
    for (final station in stations) {
      expect(station['sourceUrl'], startsWith('https://'));
      expect(
        projectUsa(
          (station['latitude'] as num).toDouble(),
          (station['longitude'] as num).toDouble(),
          const Size(1000, 650),
        ),
        isNotNull,
      );
    }
    expect(
      projectUsa(61.2, -149.9, const Size(1000, 650))!.dy,
      greaterThan(450),
    );
    expect(
      projectUsa(21.3, -157.8, const Size(1000, 650))!.dy,
      greaterThan(450),
    );
    expect(projectUsa(0, 0, const Size(1000, 650)), isNull);
  });
  testWidgets('used purchase appears in fleet and driver truck assignment', (
    tester,
  ) async {
    await tester.runAsync(() async {
      truckGameState.signOut();
      await truckGameState.accounts.register(
        'fleettester',
        'fleet test password',
      );
      await truckGameState.selectSignedInAccount();
      expect(
        await truckGameState.createCompany('Small Start Freight', 'Realistic'),
        isTrue,
        reason: truckGameState.lastError,
      );
      expect(truckGameState.cashCents, 5000000);
    });
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: FleetPage(initialTab: 1))),
    );
    await tester.pumpAndSettle();
    expect(find.textContaining('\$8,000.00'), findsOneWidget);
    await tester.runAsync(() async {
      await tester.tap(find.text('BUY').first);
      // Backend futures were created in runAsync during account setup.
      await Future<void>.delayed(Duration.zero);
    });
    await tester.pumpAndSettle();
    expect(truckGameState.fleet.length, 1, reason: truckGameState.lastError);
    await tester.tap(find.text('OWNED EQUIPMENT'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Unit 1001'), findsOneWidget);
    expect(find.textContaining('Paid \$8,000.00'), findsOneWidget);
    await tester.runAsync(() => truckGameState.hireDriver(name: 'Morgan'));
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: DriversPage())),
    );
    await tester.pumpAndSettle();
    expect(find.text('Morgan'), findsOneWidget);
    await tester.tap(find.byType(DropdownButtonFormField<String>));
    await tester.pumpAndSettle();
    await tester.runAsync(() async {
      await tester.tap(find.textContaining('Unit 1001').last);
      await Future<void>.delayed(Duration.zero);
    });
    await tester.pumpAndSettle();
    expect(
      truckGameState.drivers.single.truckId,
      truckGameState.fleet.single.id,
    );
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: MapPage())));
    await tester.pumpAndSettle();
    expect(find.textContaining('Partial coverage:'), findsOneWidget);
    expect(find.textContaining('Unit 1001'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    truckGameState.signOut();
  });
}
