import 'package:flutter/material.dart';
import 'operations_pages.dart';

class EquipmentListing {
  final String id, seller, sellerType, category, make, model, condition, location;
  final int year, miles, price;
  final bool used;
  const EquipmentListing(this.id,this.seller,this.sellerType,this.category,this.make,this.model,this.condition,this.location,this.year,this.miles,this.price,this.used);
}
const listings=<EquipmentListing>[
  EquipmentListing('D001','Lone Star Commercial Trucks','Dealership','Semi','Freightliner','Cascadia','New','Dallas, TX',2026,0,185000,false),
  EquipmentListing('D002','Texas Used Truck Center','Dealership','Semi','Kenworth','T680','Good','Fort Worth, TX',2021,415000,79500,true),
  EquipmentListing('D003','Metro Commercial Auto','Dealership','Box Truck','Isuzu','NPR-HD','Good','Houston, TX',2020,138000,37900,true),
  EquipmentListing('D004','Work Truck Outlet','Dealership','Hotshot','Ford','F-350','Fair','Dallas, TX',2019,167000,34500,true),
  EquipmentListing('P001','Red River Transport','Player','Semi','Peterbilt','579','Good','Oklahoma City, OK',2022,298000,112000,true),
  EquipmentListing('P002','Bluebird Logistics','Player','Cargo Van','Mercedes-Benz','Sprinter','Fair','Austin, TX',2020,181000,25900,true),
];
class EquipmentMarketplacePage extends StatefulWidget {
  const EquipmentMarketplacePage({super.key});
  @override State<EquipmentMarketplacePage> createState()=>_EquipmentMarketplacePageState();
}
class _EquipmentMarketplacePageState extends State<EquipmentMarketplacePage>{
  String seller='All', category='All', condition='All';
  @override Widget build(BuildContext context){
    final matches=listings.where((l)=>(seller=='All'||l.sellerType==seller)&&(category=='All'||l.category==category)&&(condition=='All'||(condition=='Used'&&l.used)||(condition=='New'&&!l.used))).toList();
    return Padding(padding:const EdgeInsets.all(16),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
      const Text('EQUIPMENT MARKETPLACE',style:TextStyle(fontSize:24,fontWeight:FontWeight.bold)),
      const Text('Browse new and used trucks from dealerships and other players. Example listings only.',style:TextStyle(color:Colors.white70)),
      const SizedBox(height:12),
      Wrap(spacing:10,runSpacing:8,children:[
        _filter('Seller',seller,['All','Dealership','Player'],(v)=>setState(()=>seller=v)),
        _filter('Condition',condition,['All','New','Used'],(v)=>setState(()=>condition=v)),
        _filter('Type',category,['All','Hotshot','Cargo Van','Box Truck','Semi'],(v)=>setState(()=>category=v)),
      ]),
      const SizedBox(height:12),
      Expanded(child:LayoutBuilder(builder:(context,limits)=>GridView.builder(
        gridDelegate:SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount:limits.maxWidth>950?3:limits.maxWidth>570?2:1,mainAxisSpacing:10,crossAxisSpacing:10,mainAxisExtent:315),
        itemCount:matches.length,itemBuilder:(context,i){final l=matches[i];return Card(child:Padding(padding:const EdgeInsets.all(14),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
          Container(height:92,width:double.infinity,decoration:BoxDecoration(color:Colors.white10,borderRadius:BorderRadius.circular(8)),child:const Icon(Icons.local_shipping,size:65,color:green)),
          const SizedBox(height:9),Text('${l.year} ${l.make} ${l.model}',style:const TextStyle(fontWeight:FontWeight.bold,fontSize:17)),
          Text('${l.category} • ${l.used?'Used':'New'} • ${l.condition}'),
          Text('${l.miles} miles • ${l.location}',style:const TextStyle(color:Colors.white70)),
          Text('${l.sellerType}: ${l.seller}',maxLines:1,overflow:TextOverflow.ellipsis),
          const Spacer(),Row(children:[Expanded(child:Text('\$${l.price}',style:const TextStyle(color:green,fontWeight:FontWeight.bold,fontSize:18))),
            FilledButton(onPressed:()=>showDialog<void>(context:context,builder:(c)=>AlertDialog(title:Text('${l.make} ${l.model}'),content:Text('Listing ${l.id} • ${l.seller}\n\nPrice: \$${l.price}\nMileage: ${l.miles}\nCondition: ${l.condition}\n\nPurchasing and player-to-player transfers will be connected to the backend. No purchase has been made.'),actions:[TextButton(onPressed:()=>Navigator.pop(c),child:const Text('CLOSE'))])),child:const Text('DETAILS'))
          ])
        ])));}))),
    ]));
  }
  Widget _filter(String label,String value,List<String> choices,ValueChanged<String> change)=>SizedBox(width:180,child:DropdownButtonFormField<String>(value:value,decoration:InputDecoration(labelText:label,isDense:true),items:choices.map((v)=>DropdownMenuItem(value:v,child:Text(v))).toList(),onChanged:(v){if(v!=null)change(v);}));
}
