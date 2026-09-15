import 'package:flutter/material.dart';

void main() => runApp(const TruckManagerApp());

class TruckManagerApp extends StatelessWidget {
  const TruckManagerApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'Truck Manager',
    theme: ThemeData.dark().copyWith(
      scaffoldBackgroundColor: const Color(0xFF08111B),
      colorScheme: const ColorScheme.dark(primary: Color(0xFF35D07F), surface: Color(0xFF101C28)),
      cardTheme: const CardThemeData(color: Color(0xFF101C28)),
    ),
    home: const OperationsShell(),
  );
}

class TruckUnit {
  final String unit, name, type, route, driver, coDriver, hos, eta, mode, status;
  final int miles, level;
  const TruckUnit(this.unit, this.name, this.type, this.route, this.driver, this.coDriver, this.hos, this.eta, this.mode, this.status, this.miles, this.level);
}

const trucks = [
  TruckUnit('1001','Big Red','Sleeper Tractor','Dallas, TX → Atlanta, GA','James Wilson','Michael Reed','3h 18m','8h 43m','STAFF','ON TIME',487231,18),
  TruckUnit('1047','Road King','Sleeper Tractor','Phoenix, AZ → Denver, CO','Marcus Reed','—','6h 02m','11h 20m','AUTO','ON TIME',284912,12),
  TruckUnit('207','Blue Line','Box Truck','Houston, TX → Austin, TX','Anthony Carter','—','5h 44m','2h 05m','AUTO','ATTENTION',98124,7),
  TruckUnit('88','Sprinter 88','Cargo Van','Fort Worth, TX → Tulsa, OK','Robert Davis','—','7h 15m','4h 12m','MANUAL','AVAILABLE',62119,5),
];

class OperationsShell extends StatefulWidget {
  const OperationsShell({super.key});
  @override State<OperationsShell> createState() => _OperationsShellState();
}

class _OperationsShellState extends State<OperationsShell> {
  int page = 1, speed = 1;
  final pages = const ['Dashboard','Dispatch','Loads','Fleet','Drivers','Terminals','Staff','Safety','Maintenance','Customers','Finance','Reports'];
  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(child: Column(children:[
      _topBar(),
      Expanded(child: Row(children:[
        NavigationRail(
          backgroundColor: const Color(0xFF0C1722), extended: MediaQuery.sizeOf(context).width > 1050,
          selectedIndex: page, onDestinationSelected:(v)=>setState(()=>page=v),
          destinations: pages.map((p)=>NavigationRailDestination(icon: const Icon(Icons.circle_outlined,size:16),selectedIcon:const Icon(Icons.local_shipping),label:Text(p))).toList(),
        ),
        Expanded(child: page==1 ? const DispatchCenter() : PlaceholderPage(title: pages[page])),
      ]))
    ])),
  );

  Widget _topBar()=>Container(
    padding:const EdgeInsets.symmetric(horizontal:18,vertical:10), color:const Color(0xFF0D1925),
    child:Row(children:[
      const Icon(Icons.local_shipping,color:Color(0xFF35D07F)), const SizedBox(width:10),
      const Text('TRUCK MANAGER',style:TextStyle(fontSize:20,fontWeight:FontWeight.w800)),
      const Spacer(),
      const _Metric('CASH','\$248,630'), const _Metric('TODAY','+\$8,420'), const _Metric('ACTIVE','18 / 24'),
      const SizedBox(width:12),
      for(final s in [0,1,2,5,10]) Padding(padding:const EdgeInsets.only(left:4),child:ChoiceChip(label:Text(s==0?'Ⅱ':'${s}×'),selected:speed==s,onSelected:(_)=>setState(()=>speed=s))),
    ]),
  );
}

class _Metric extends StatelessWidget {
  final String label,value; const _Metric(this.label,this.value);
  @override Widget build(BuildContext context)=>Padding(padding:const EdgeInsets.symmetric(horizontal:12),child:Column(mainAxisSize:MainAxisSize.min,children:[Text(label,style:const TextStyle(fontSize:10,color:Colors.white54)),Text(value,style:const TextStyle(fontWeight:FontWeight.bold))]));
}

class DispatchCenter extends StatefulWidget { const DispatchCenter({super.key}); @override State<DispatchCenter> createState()=>_DispatchCenterState(); }
class _DispatchCenterState extends State<DispatchCenter>{
  TruckUnit selected=trucks.first;
  @override Widget build(BuildContext context)=>Padding(padding:const EdgeInsets.all(16),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
    Row(children:[const Text('DISPATCH CENTER',style:TextStyle(fontSize:24,fontWeight:FontWeight.w800)),const Spacer(),_stat('Moving','18'),_stat('Available','4'),_stat('Alerts','2')]),
    const SizedBox(height:12),
    Expanded(child:LayoutBuilder(builder:(context,c)=>c.maxWidth>1000?Row(children:[Expanded(flex:3,child:_fleet()),const SizedBox(width:12),Expanded(flex:2,child:_details())]):Column(children:[Expanded(child:_fleet()),const SizedBox(height:8),Expanded(child:_details())]))),
  ]));
  Widget _stat(String a,String b)=>Card(child:Padding(padding:const EdgeInsets.symmetric(horizontal:18,vertical:8),child:Column(children:[Text(b,style:const TextStyle(fontSize:18,fontWeight:FontWeight.bold,color:Color(0xFF35D07F))),Text(a)])));
  Widget _fleet()=>Card(child:Column(children:[
    const ListTile(title:Text('LIVE FLEET',style:TextStyle(fontWeight:FontWeight.bold)),subtitle:Text('Nationwide operations • mock frontend data')),
    Expanded(child:ListView(children:trucks.map((t)=>ListTile(selected:t==selected,selectedTileColor:Colors.white10,onTap:()=>setState(()=>selected=t),leading:const Icon(Icons.local_shipping),title:Text('Unit ${t.unit} • ${t.name}'),subtitle:Text('${t.route}\n${t.driver}${t.coDriver!='—'?' / ${t.coDriver}':''}'),isThreeLine:true,trailing:Column(mainAxisAlignment:MainAxisAlignment.center,children:[Text(t.mode,style:const TextStyle(color:Color(0xFF35D07F),fontWeight:FontWeight.bold)),Text(t.status,style:const TextStyle(fontSize:11))]))).toList()))
  ]));
  Widget _details()=>Card(child:Padding(padding:const EdgeInsets.all(18),child:ListView(children:[
    Text('UNIT ${selected.unit}',style:const TextStyle(fontSize:22,fontWeight:FontWeight.w800)),Text(selected.name,style:const TextStyle(color:Color(0xFF35D07F),fontSize:18)),const Divider(),
    _row('Vehicle',selected.type),_row('Route',selected.route),_row('Driver',selected.driver),_row('Co-driver',selected.coDriver),_row('HOS remaining',selected.hos),_row('ETA',selected.eta),_row('Dispatch mode',selected.mode),_row('Odometer','${selected.miles} mi'),_row('Truck level','Level ${selected.level}'),
    const SizedBox(height:12),const Text('TEAM DRIVER ROTATION',style:TextStyle(fontWeight:FontWeight.bold)),const SizedBox(height:6),Text(selected.coDriver=='—'?'Solo driver assigned':'Automatic switching enabled • co-driver rests while active driver operates.'),
    const SizedBox(height:16),FilledButton.icon(onPressed:(){},icon:const Icon(Icons.manage_search),label:const Text('OPEN FULL TRUCK RECORD'))
  ])));
  Widget _row(String a,String b)=>Padding(padding:const EdgeInsets.symmetric(vertical:6),child:Row(crossAxisAlignment:CrossAxisAlignment.start,children:[SizedBox(width:120,child:Text(a,style:const TextStyle(color:Colors.white54))),Expanded(child:Text(b,style:const TextStyle(fontWeight:FontWeight.w600)))]));
}

class PlaceholderPage extends StatelessWidget { final String title; const PlaceholderPage({super.key,required this.title}); @override Widget build(BuildContext context)=>Center(child:Column(mainAxisSize:MainAxisSize.min,children:[const Icon(Icons.construction,size:52,color:Color(0xFF35D07F)),const SizedBox(height:12),Text(title.toUpperCase(),style:const TextStyle(fontSize:26,fontWeight:FontWeight.bold)),const Text('Frontend module reserved for Truck Manager v0.1') ])); }
