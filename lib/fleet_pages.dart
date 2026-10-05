import 'package:flutter/material.dart';
import 'package:truck_manager_backend/core/backend_core.dart';
import 'game_state.dart';
import 'formatters.dart';
import 'operations_pages.dart';

class FleetPage extends StatefulWidget {
  final int initialTab;
  const FleetPage({super.key, this.initialTab = 0});
  @override
  State<FleetPage> createState() => _FleetPageState();
}

class _FleetPageState extends State<FleetPage> {
  bool usedOnly = true;
  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: truckGameState,
    builder: (context, _) => Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Expanded(
                child: Text(
                  'FLEET EQUIPMENT',
                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                ),
              ),
              Text('${truckGameState.truckCount} owned'),
            ],
          ),
        ),
        Expanded(
          child: DefaultTabController(
            length: 2,
            initialIndex: widget.initialTab,
            child: Column(
              children: [
                const TabBar(
                  tabs: [
                    Tab(text: 'OWNED EQUIPMENT'),
                    Tab(text: 'BUY VEHICLES'),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      truckGameState.fleet.isEmpty
                          ? const Center(
                              child: Text(
                                'Your fleet is empty. Open BUY VEHICLES to buy affordable used equipment.',
                              ),
                            )
                          : ListView(
                              children: [
                                for (final vehicle in truckGameState.fleet)
                                  _vehicleCard(vehicle),
                              ],
                            ),
                      Column(
                        children: [
                          SwitchListTile(
                            title: const Text(
                              'Used vehicles — available from day one',
                            ),
                            subtitle: const Text(
                              'Lower purchase prices; higher mileage and wear. Game catalogue prices.',
                            ),
                            value: usedOnly,
                            onChanged: (value) =>
                                setState(() => usedOnly = value),
                          ),
                          Expanded(
                            child: ListView(
                              children: [
                                for (final offer in vehicleCatalog.where(
                                  (v) => !usedOnly || v.used,
                                ))
                                  Card(
                                    child: ListTile(
                                      leading: const Icon(
                                        Icons.local_shipping,
                                        color: green,
                                      ),
                                      title: Text(
                                        '${offer.year} ${offer.name} • ${money(offer.priceCents)}',
                                      ),
                                      subtitle: Text(
                                        '${offer.vehicleClass} • ${grouped(offer.mileage)} mi • Condition ${offer.conditionPercent}%',
                                      ),
                                      trailing: FilledButton(
                                        onPressed:
                                            truckGameState.cashCents >=
                                                offer.priceCents
                                            ? () => truckGameState
                                                  .purchaseVehicle(offer.id)
                                            : null,
                                        child: const Text('BUY'),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );

  Widget _vehicleCard(FleetVehicle vehicle) {
    final assigned = truckGameState.drivers.where(
      (d) => d.truckId == vehicle.id,
    );
    final active = truckGameState.loads.where(
      (l) => l.truckId == vehicle.id && !l.delivered,
    );
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Unit ${vehicle.unitNumber} • ${vehicle.year} ${vehicle.name}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              '${vehicle.vehicleClass} • ${vehicle.used ? 'Purchased used' : 'Purchased new'} • Paid ${money(vehicle.purchasePriceCents)}',
            ),
            const Divider(),
            row(
              'Driver',
              assigned.isEmpty ? 'Unassigned' : assigned.first.name,
            ),
            row('Location', vehicle.city),
            row('Odometer', '${grouped(vehicle.mileage)} mi'),
            row('Condition', '${vehicle.conditionPercent}%'),
            row(
              'Status',
              active.isEmpty
                  ? 'Available'
                  : 'Assigned load → ${active.first.destination}',
            ),
          ],
        ),
      ),
    );
  }
}

class DriversPage extends StatelessWidget {
  const DriversPage({super.key});
  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: truckGameState,
    builder: (context, _) => Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Expanded(
                child: Text(
                  'DRIVERS',
                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                ),
              ),
              FilledButton.icon(
                onPressed: () => _hire(context),
                icon: const Icon(Icons.person_add),
                label: const Text('Hire driver \$1,000'),
              ),
            ],
          ),
        ),
        Expanded(
          child: truckGameState.drivers.isEmpty
              ? const Center(
                  child: Text(
                    'No drivers hired yet. Hire a driver, then assign a vehicle.',
                  ),
                )
              : ListView(
                  children: [
                    for (final driver in truckGameState.drivers)
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                driver.name,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '${driver.cdlClass} • ${grouped(driver.milesDriven)} company miles',
                              ),
                              const SizedBox(height: 10),
                              DropdownButtonFormField<String>(
                                initialValue: driver.truckId,
                                key: ValueKey('${driver.id}:${driver.truckId}'),
                                decoration: const InputDecoration(
                                  labelText: 'Assigned truck / equipment',
                                ),
                                hint: const Text('Unassigned'),
                                items: [
                                  const DropdownMenuItem<String>(
                                    value: null,
                                    child: Text('Unassigned'),
                                  ),
                                  for (final vehicle in truckGameState.fleet)
                                    DropdownMenuItem(
                                      value: vehicle.id,
                                      child: Text(
                                        'Unit ${vehicle.unitNumber} • ${vehicle.name}',
                                      ),
                                    ),
                                ],
                                onChanged: (value) => truckGameState
                                    .assignDriver(driver.id, value),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
        ),
      ],
    ),
  );

  Future<void> _hire(BuildContext context) async {
    final name = TextEditingController();
    final selected = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hire a driver'),
        content: TextField(
          controller: name,
          decoration: const InputDecoration(
            labelText: 'Driver name',
            helperText: 'Hiring cost: \$1,000',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (name.text.trim().isNotEmpty)
                Navigator.pop(context, name.text.trim());
            },
            child: const Text('HIRE'),
          ),
        ],
      ),
    );
    // Dispose after the dialog route finishes its closing animation.
    await Future<void>.delayed(const Duration(milliseconds: 250));
    name.dispose();
    if (selected != null) await truckGameState.hireDriver(name: selected);
  }
}

class LoadsPage extends StatelessWidget {
  const LoadsPage({super.key});
  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: truckGameState,
    builder: (context, _) => Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Expanded(
                child: Text(
                  'LOAD BOARD',
                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                ),
              ),
              FilledButton.icon(
                onPressed: truckGameState.acceptLoad,
                icon: const Icon(Icons.route),
                label: const Text('ACCEPT STARTER LOAD'),
              ),
            ],
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Dispatch assigns an available driver and vehicle. Completing a load moves its vehicle to the destination on the map.',
          ),
        ),
        Expanded(
          child: ListView(
            children: [
              for (final load in truckGameState.loads)
                Card(
                  child: ListTile(
                    title: Text('${load.origin} → ${load.destination}'),
                    subtitle: Text(
                      '${_unit(load.truckId)} • ${_driver(load.driverId)} • ${load.delivered ? 'Delivered' : 'Assigned'} • ${money(load.revenueCents)}',
                    ),
                    trailing: load.delivered
                        ? const Icon(Icons.check_circle, color: green)
                        : FilledButton(
                            onPressed: () =>
                                truckGameState.completeLoad(loadId: load.id),
                            child: const Text('COMPLETE'),
                          ),
                  ),
                ),
            ],
          ),
        ),
      ],
    ),
  );
  String _unit(String id) =>
      'Unit ${truckGameState.fleet.firstWhere((t) => t.id == id).unitNumber}';
  String _driver(String id) =>
      truckGameState.drivers.firstWhere((d) => d.id == id).name;
}
