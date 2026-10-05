import 'fleet_pages.dart';
import 'game_state.dart';
import 'package:flutter/material.dart';
import 'operations_pages.dart';

class ActionCenterPage extends StatelessWidget {
  const ActionCenterPage({super.key});
  @override
  Widget build(
    BuildContext c,
  ) => OpsPage('COMPANY ACTION CENTER', 'Playable company management actions', [
    Box('BUY FLEET EQUIPMENT', Icons.local_shipping, [
      const Text(
        'Used pickups from \$8,000 and cargo vans from \$12,000. Available from the start.',
      ),
      const SizedBox(height: 12),
      FilledButton.icon(
        onPressed: () => Navigator.of(c).push(
          MaterialPageRoute(
            builder: (_) => Scaffold(
              appBar: AppBar(title: const Text('Vehicle market')),
              body: const SafeArea(child: FleetPage(initialTab: 1)),
            ),
          ),
        ),
        icon: const Icon(Icons.shopping_cart),
        label: const Text('SHOP USED & NEW VEHICLES'),
      ),
    ]),
    ActionBox(
      'HIRE EMPLOYEES',
      Icons.person_add,
      [
        'CDL Driver • \$0.62/mi',
        'Dispatcher • \$58,000/yr',
        'Load Planner • \$64,000/yr',
        'Diesel Technician • \$71,000/yr',
      ],
      ['REVIEW', 'HIRE'],
    ),
    ActionBox(
      'TERMINAL EXPANSION',
      Icons.add_business,
      [
        'Dallas HQ • Upgrade available',
        'Phoenix Terminal • Expand parking',
        'Chicago, IL • New terminal candidate',
        'Atlanta, GA • New terminal candidate',
      ],
      ['DETAILS', 'PURCHASE'],
    ),
    ActionBox(
      'LOAD ASSIGNMENT',
      Icons.route,
      [
        'TM-000128 • Denver → Kansas City',
        'TM-000130 • Fort Worth → Tulsa',
        'Dry Van / Reefer / Expedited',
        'Auto, Staff or Manual dispatch',
      ],
      ['PLAN', 'ASSIGN'],
    ),
    ActionBox(
      'CONTRACT DECISIONS',
      Icons.handshake,
      [
        'Metro Retail • Dedicated',
        'Dallas → Houston network',
        '8 tractors required',
        '\$1.35M annual revenue',
      ],
      ['DECLINE', 'ACCEPT'],
    ),
    ActionBox(
      'SAFETY ACTIONS',
      Icons.shield,
      [
        'Renew medical cards',
        'Schedule driver training',
        'Review DOT inspections',
        'Handle out-of-service events',
      ],
      ['REVIEW', 'HANDLE'],
    ),
    ActionBox(
      'MAINTENANCE ACTIONS',
      Icons.build,
      [
        'Schedule PM',
        'Roadside repair',
        'Tow to company shop',
        'Swap tractor / transfer load',
      ],
      ['SCHEDULE', 'AUTHORIZE'],
    ),
  ]);
}

class ActionBox extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<String> items, actions;
  const ActionBox(this.title, this.icon, this.items, this.actions, {super.key});
  @override
  Widget build(BuildContext c) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: green),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                  ),
                ),
              ),
            ],
          ),
          const Divider(),
          ...items.map(
            (x) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Text(x),
            ),
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: actions
                .map(
                  (a) => Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: FilledButton.tonal(
                      onPressed: () => a == 'HIRE'
                          ? truckGameState.hireDriver()
                          : ScaffoldMessenger.of(c).showSnackBar(
                              SnackBar(content: Text('$a selected')),
                            ),
                      child: Text(a),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    ),
  );
}
