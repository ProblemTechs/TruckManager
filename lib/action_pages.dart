import 'package:flutter/material.dart';
import 'operations_pages.dart';

class ActionCenterPage extends StatelessWidget {
  const ActionCenterPage({super.key});
  @override
  Widget build(BuildContext c) => OpsPage('COMPANY ACTION CENTER','Playable company management actions',[
    ActionBox('USED EQUIPMENT MARKET • LEVEL 1',Icons.car_repair,['2019 Cargo Van • 142,000 mi • \$28,000','2018 Box Truck • 238,000 mi • \$54,000','2017 Day Cab Tractor • 612,000 mi • \$72,000','2019 Sleeper Tractor • 498,000 mi • \$96,000'],['DETAILS','BUY']),
    ActionBox('NEW / LEASE EQUIPMENT',Icons.local_shipping,['Cargo Van • \$48,000','Box Truck • \$92,000','Day Cab Tractor • \$148,000','Sleeper Tractor • \$184,000'],['BUY','LEASE']),
    ActionBox('HIRE EMPLOYEES',Icons.person_add,['CDL Driver • \$0.62/mi','Dispatcher • \$58,000/yr','Load Planner • \$64,000/yr','Diesel Technician • \$71,000/yr'],['REVIEW','HIRE']),
    ActionBox('TERMINAL EXPANSION',Icons.add_business,['Dallas HQ • Upgrade available','Phoenix Terminal • Expand parking','Chicago, IL • New terminal candidate','Atlanta, GA • New terminal candidate'],['DETAILS','PURCHASE']),
    ActionBox('LOAD ASSIGNMENT',Icons.route,['TM-000128 • Denver → Kansas City','TM-000130 • Fort Worth → Tulsa','Dry Van / Reefer / Expedited','Auto, Staff or Manual dispatch'],['PLAN','ASSIGN']),
    ActionBox('CONTRACT DECISIONS',Icons.handshake,['Metro Retail • Dedicated','Dallas → Houston network','8 tractors required','\$1.35M annual revenue'],['DECLINE','ACCEPT']),
    ActionBox('SAFETY ACTIONS',Icons.shield,['Renew medical cards','Schedule driver training','Review DOT inspections','Handle out-of-service events'],['REVIEW','HANDLE']),
    ActionBox('MAINTENANCE ACTIONS',Icons.build,['Schedule PM','Roadside repair','Tow to company shop','Swap tractor / transfer load'],['SCHEDULE','AUTHORIZE']),
  ]);
}

class ActionBox extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<String> items, actions;
  const ActionBox(this.title,this.icon,this.items,this.actions,{super.key});
  @override
  Widget build(BuildContext c) => Card(child:Padding(padding:const EdgeInsets.all(16),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Row(children:[Icon(icon,color:green),const SizedBox(width:8),Expanded(child:Text(title,style:const TextStyle(fontWeight:FontWeight.bold,fontSize:17)))]),const Divider(),...items.map((x)=>Padding(padding:const EdgeInsets.symmetric(vertical:3),child:Text(x))),const Spacer(),Row(mainAxisAlignment:MainAxisAlignment.end,children:actions.map((a)=>Padding(padding:const EdgeInsets.only(left:8),child:FilledButton.tonal(onPressed:()=>ScaffoldMessenger.of(c).showSnackBar(SnackBar(content:Text('$a selected'))),child:Text(a)))).toList())])));
}

class MapPage extends StatelessWidget {
  const MapPage({super.key});
  @override
  Widget build(BuildContext c) => Padding(padding:const EdgeInsets.all(16),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[const Text('U.S. OPERATIONS MAP',style:TextStyle(fontSize:25,fontWeight:FontWeight.w800)),const Text('Nationwide terminal, truck and freight network placeholder',style:TextStyle(color:Colors.white54)),const SizedBox(height:12),Expanded(child:Card(child:Stack(children:[Positioned.fill(child:CustomPaint(painter:MapPainter())),const Positioned(left:24,top:20,child:Chip(label:Text('Dallas HQ'))),const Positioned(right:80,top:80,child:Chip(label:Text('Chicago • Planned'))),const Positioned(left:90,bottom:65,child:Chip(label:Text('Phoenix Terminal'))),const Positioned(right:30,bottom:40,child:Chip(label:Text('Atlanta Market')))])))]));
}

class MapPainter extends CustomPainter{@override void paint(Canvas c,Size s){final p=Paint()..color=Colors.white10..style=PaintingStyle.stroke..strokeWidth=2;final r=Rect.fromLTWH(s.width*.08,s.height*.12,s.width*.84,s.height*.70);c.drawRRect(RRect.fromRectAndRadius(r,const Radius.circular(80)),p);final road=Paint()..color=green.withValues(alpha:.45)..strokeWidth=2;for(final y in[.3,.5,.7])c.drawLine(Offset(s.width*.12,s.height*y),Offset(s.width*.88,s.height*y),road);for(final x in[.25,.48,.7])c.drawLine(Offset(s.width*x,s.height*.18),Offset(s.width*x,s.height*.78),road);}@override bool shouldRepaint(covariant CustomPainter old)=>false;}
