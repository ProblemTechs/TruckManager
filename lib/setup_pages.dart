import 'package:flutter/material.dart';
import 'operations_pages.dart';
import 'game_state.dart';

class NewCompanyPage extends StatefulWidget {
  final VoidCallback onStart;
  const NewCompanyPage({super.key, required this.onStart});
  @override
  State<NewCompanyPage> createState() => _NewCompanyPageState();
}

class _NewCompanyPageState extends State<NewCompanyPage> {
  String city = 'Dallas, TX';
  String difficulty = 'Standard';
  String strategy = 'Dry Van';
  int startingCapital = 10000000;
  final company = TextEditingController(text: 'ProblemTechs Transport');

  @override
  void dispose() {
    company.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(children: [Icon(Icons.local_shipping, color: green, size: 42), SizedBox(width: 12), Text('TRUCK MANAGER', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900))]),
                    const SizedBox(height: 8),
                    const Text('PLAYER: ProblemTechs', style: TextStyle(color: green, fontWeight: FontWeight.bold)),
                    const Text('START A NEW TRUCKING COMPANY', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    const Text('Build a carrier from a small operation into a nationwide transportation company.', style: TextStyle(color: Colors.white60)),
                    const SizedBox(height: 24),
                    TextField(controller: company, decoration: const InputDecoration(labelText: 'Company name')),
                    const SizedBox(height: 14),
                    DropdownButtonFormField<String>(value: city, decoration: const InputDecoration(labelText: 'Starting city'), items: ['Dallas, TX','Atlanta, GA','Chicago, IL','Denver, CO','Phoenix, AZ','Los Angeles, CA','Newark, NJ'].map((x) => DropdownMenuItem(value: x, child: Text(x))).toList(), onChanged: (v) => setState(() => city = v!)),
                    const SizedBox(height: 14),
                    DropdownButtonFormField<String>(value: difficulty, decoration: const InputDecoration(labelText: 'Economy difficulty'), items: ['Relaxed','Standard','Realistic'].map((x) => DropdownMenuItem(value: x, child: Text(x))).toList(), onChanged: (v) => setState(() => difficulty = v!)),
                    const SizedBox(height: 14),
                    DropdownButtonFormField<String>(value: strategy, decoration: const InputDecoration(labelText: 'Starting business'), items: ['Cargo Van / Expedited','Box Truck / Local','Hotshot','Dry Van','Refrigerated'].map((x) => DropdownMenuItem(value: x, child: Text(x))).toList(), onChanged: (v) => setState(() => strategy = v!)),
                    const SizedBox(height: 14),
                    DropdownButtonFormField<int>(value: startingCapital, decoration: const InputDecoration(labelText: 'Starting capital'), items: const [DropdownMenuItem(value: 5000000, child: Text('\$50,000 • Challenge')), DropdownMenuItem(value: 10000000, child: Text('\$100,000 • Balanced')), DropdownMenuItem(value: 25000000, child: Text('\$250,000 • Easier startup'))], onChanged: (v) => setState(() => startingCapital = v!)),
                    const SizedBox(height: 16),
                    const Card(child: Padding(padding: EdgeInsets.all(12), child: Row(children: [Icon(Icons.account_balance, color: green), SizedBox(width: 10), Expanded(child: Text('Bank financing and the used equipment market are available from the start.'))]))),
                    const SizedBox(height: 12),
                    const Text('Version 1: Management Mode', style: TextStyle(color: green, fontWeight: FontWeight.bold)),
                    const Text('You own and operate the company. Your hired drivers operate the equipment. Driver Mode is reserved for a future update.'),
                    const SizedBox(height: 24),
                    SizedBox(width: double.infinity, child: FilledButton.icon(onPressed: () { truckGameState.companyName = company.text.trim().isEmpty ? 'ProblemTechs Transport' : company.text.trim(); truckGameState.setStartingCapital(startingCapital); widget.onStart(); }, icon: const Icon(Icons.business_center), label: const Padding(padding: EdgeInsets.all(14), child: Text('CREATE COMPANY')))),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});
  @override
  Widget build(BuildContext c) => OpsPage('GAME SETTINGS','Interface, simulation and management preferences',[
    Box('Player & Company',Icons.account_circle,[row('Player','ProblemTechs'),row('Company',truckGameState.companyName),row('Company level','${truckGameState.companyLevel}'),row('Company XP','${truckGameState.companyXp}')]),
    Box('Starter Actions',Icons.play_circle,[Padding(padding:const EdgeInsets.all(8),child:Wrap(spacing:8,runSpacing:8,children:[FilledButton.icon(onPressed:()=>truckGameState.purchaseStarterTruck(),icon:const Icon(Icons.local_shipping),label:const Text('Buy Truck \$125,000')),FilledButton.icon(onPressed:()=>truckGameState.hireDriver(),icon:const Icon(Icons.person_add),label:const Text('Hire Driver \$1,000'))]))]),
    Box('Bank & Credit',Icons.account_balance,[row('Debt','\$${truckGameState.debt.toStringAsFixed(2)}'),row('Available credit','\$${truckGameState.availableCredit.toStringAsFixed(2)}'),Padding(padding:const EdgeInsets.all(8),child:Wrap(spacing:8,children:[FilledButton.tonal(onPressed:()=>truckGameState.borrowMoney(2500000),child:const Text('Borrow \$25,000')),FilledButton.tonal(onPressed:()=>truckGameState.repayLoan(500000),child:const Text('Repay \$5,000'))]))]),
    Box('Simulation',Icons.speed,[row('Default speed','1×'),row('Pause on critical events','Enabled'),row('Auto-save','Enabled'),row('Auto-save interval','5 minutes')]),
  ]);
}

class NotificationsPage extends StatelessWidget{const NotificationsPage({super.key});@override Widget build(BuildContext c)=>OpsPage('OPERATIONS ALERTS','Central event and notification center',[Box('CRITICAL • Unit 207',Icons.warning,[row('Event','DOT out-of-service'),row('Cause','Brake defect'),row('Load risk','High'),row('Response','Repair / swap tractor')]),Box('IMPORTANT • Driver D-0240',Icons.medical_information,[row('Event','Medical card expiring'),row('Expires','Sep 28, 2026'),row('Days remaining','13'),row('Action','Schedule DOT physical')]),Box('ATTENTION • Maintenance',Icons.build_circle,[row('PM due','4 units'),row('Overdue','1 unit'),row('Shop capacity','1 bay available'),row('Roadside calls','1')]),Box('INFO • Contract',Icons.handshake,[row('Customer','Metro Retail Network'),row('Performance','98.2% on-time'),row('Target','97%'),row('Status','Above target')])]);}
