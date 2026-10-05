import 'fleet_pages.dart';
import 'map_page.dart';
import 'formatters.dart';
import 'package:flutter/material.dart';
import 'operations_pages.dart';
import 'setup_pages.dart';
import 'action_pages.dart';
import 'game_state.dart';
import 'login_page.dart';

void main() => runApp(const TruckManagerApp());
const bg = Color(0xFF08111B);

class TruckManagerApp extends StatefulWidget {
  const TruckManagerApp({super.key});
  @override
  State<TruckManagerApp> createState() => _TruckManagerAppState();
}

class _TruckManagerAppState extends State<TruckManagerApp> {
  bool signedIn = false;
  bool started = false;

  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'Truck Manager',
    theme: ThemeData.dark().copyWith(
      scaffoldBackgroundColor: bg,
      colorScheme: const ColorScheme.dark(primary: green, surface: panel),
      cardTheme: const CardThemeData(color: panel),
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(),
      ),
    ),
    home: !signedIn
        ? LoginPage(
            onSignedIn: () {
              setState(() {
                signedIn = true;
                started = truckGameState.hasCompany;
              });
            },
          )
        : started
        ? Shell(
            onSignOut: () {
              truckGameState.signOut();
              setState(() {
                signedIn = false;
                started = false;
              });
            },
          )
        : NewCompanyPage(onStart: () => setState(() => started = true)),
  );
}

class Shell extends StatefulWidget {
  final VoidCallback onSignOut;
  const Shell({super.key, required this.onSignOut});
  @override
  State<Shell> createState() => _ShellState();
}

class _ShellState extends State<Shell> {
  int page = 0;
  final pages = const [
    'Dashboard',
    'Map',
    'Dispatch',
    'Loads',
    'Fleet',
    'Drivers',
    'Terminals',
    'Staff',
    'Safety',
    'Maintenance',
    'Customers',
    'Finance',
    'Reports',
    'Actions',
    'Alerts',
    'Settings',
  ];

  @override
  void initState() {
    super.initState();
    truckGameState.addListener(_refresh);
  }

  @override
  void dispose() {
    truckGameState.removeListener(_refresh);
    super.dispose();
  }

  void _refresh() {
    if (!mounted) return;
    setState(() {});
    final error = truckGameState.lastError;
    if (error != null)
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error)));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Column(
        children: [
          topBar(),
          Expanded(
            child: Row(
              children: [
                NavigationRail(
                  scrollable: true,
                  backgroundColor: const Color(0xFF0C1722),
                  extended: MediaQuery.sizeOf(context).width > 1200,
                  selectedIndex: page,
                  onDestinationSelected: (v) => setState(() => page = v),
                  destinations: pages
                      .map(
                        (p) => NavigationRailDestination(
                          icon: const Icon(Icons.circle_outlined, size: 16),
                          selectedIcon: const Icon(Icons.local_shipping),
                          label: Text(p),
                        ),
                      )
                      .toList(),
                ),
                Expanded(
                  child: switch (page) {
                    0 => const DashboardPage(),
                    1 => const MapPage(),
                    2 => const DispatchPage(),
                    3 => const LoadsPage(),
                    4 => const FleetPage(),
                    5 => const DriversPage(),
                    6 => const TerminalsPage(),
                    7 => const StaffPage(),
                    8 => const SafetyPage(),
                    9 => const MaintenancePage(),
                    10 => const CustomersPage(),
                    11 => const FinancePage(),
                    12 => const ReportsPage(),
                    13 => const ActionCenterPage(),
                    14 => const NotificationsPage(),
                    _ => const SettingsPage(),
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );

  Widget topBar() => Container(
    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
    color: const Color(0xFF0D1925),
    child: Wrap(
      spacing: 8,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        const Icon(Icons.local_shipping, color: green),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'TRUCK MANAGER',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
            ),
            Text(
              '${truckGameState.playerName} • ${truckGameState.companyName}',
              style: const TextStyle(fontSize: 10, color: Colors.white54),
            ),
          ],
        ),
        IconButton(
          onPressed: widget.onSignOut,
          tooltip: 'Sign out',
          icon: const Icon(Icons.logout),
        ),
        Metric('CASH', money(truckGameState.cashCents)),
        Metric('DEBT', money(truckGameState.debtCents)),
        Metric('LEVEL', '${truckGameState.companyLevel}'),
        Metric('FLEET', '${truckGameState.truckCount}'),
        for (final s in [0, 1, 2, 5, 10])
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: ChoiceChip(
              label: Text(s == 0 ? 'Ⅱ' : '${s}×'),
              selected: truckGameState.speed == s,
              onSelected: (_) => truckGameState.setSpeed(s),
            ),
          ),
      ],
    ),
  );
}

class Metric extends StatelessWidget {
  final String a, b;
  const Metric(this.a, this.b, {super.key});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 10),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(a, style: const TextStyle(fontSize: 10, color: Colors.white54)),
        Text(b, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    ),
  );
}

class PageFrame extends StatelessWidget {
  final String title, subtitle;
  final Widget child;
  const PageFrame(this.title, this.subtitle, this.child, {super.key});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 25, fontWeight: FontWeight.w800),
        ),
        Text(subtitle, style: const TextStyle(color: Colors.white54)),
        const SizedBox(height: 12),
        Expanded(child: child),
      ],
    ),
  );
}

class DispatchPage extends StatelessWidget {
  const DispatchPage({super.key});
  @override
  Widget build(BuildContext context) => const PageFrame(
    'DISPATCH CENTER',
    'Assign drivers, equipment and freight',
    Center(
      child: Text(
        'Buy a truck, hire a driver, then accept freight from the Load Board.',
      ),
    ),
  );
}
