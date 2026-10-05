import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../lib/game_state.dart';
import '../lib/setup_pages.dart';

void main() {
  testWidgets('company setup starts empty and refuses a blank business name', (
    tester,
  ) async {
    await tester.pumpWidget(MaterialApp(home: NewCompanyPage(onStart: () {})));
    expect(find.textContaining('ProblemTechs'), findsNothing);
    final field = tester.widget<TextField>(find.byType(TextField));
    expect(field.controller!.text, isEmpty);
    await tester.ensureVisible(find.text('CREATE COMPANY'));
    await tester.tap(find.text('CREATE COMPANY'));
    await tester.pump();
    expect(
      find.text('Enter a business name (1–80 characters).'),
      findsOneWidget,
    );
  });
  test(
    'account switch isolates companies and restores the right session',
    () async {
      final game = TruckGameState();
      await game.accounts.register('alice', 'a long test password');
      await game.selectSignedInAccount();
      expect(await game.createCompany('Alice Freight', 'Standard'), isTrue);
      expect(await game.purchaseStarterTruck(), isTrue);
      game.signOut();
      await game.accounts.register('bob', 'a different password');
      await game.selectSignedInAccount();
      expect(game.companyName, isEmpty);
      expect(game.truckCount, 0);
      expect(await game.createCompany('Bob Logistics', 'Relaxed'), isTrue);
      game.signOut();
      await game.accounts.signIn('alice', 'a long test password');
      await game.selectSignedInAccount();
      expect(game.companyName, 'Alice Freight');
      expect(game.truckCount, 1);
      expect(game.cashCents, 5200000);
    },
  );
}
