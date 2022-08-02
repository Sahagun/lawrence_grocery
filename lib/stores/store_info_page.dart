import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'aisle_info_page.dart';

class StoreInfoPage extends StatefulWidget {

  final QueryDocumentSnapshot<Map<String,dynamic>> storeDoc;
  final String storeID;

  const StoreInfoPage({Key? key, required this.storeDoc, required this.storeID}) : super(key: key);

  @override
  _StoreInfoPageState createState() => _StoreInfoPageState();

}

class _StoreInfoPageState extends State<StoreInfoPage> {

  void navigateToStorePage(Map<String,dynamic> aisleInfo, String aisleID){
    Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => AisleInfoPage(aisleInfo:aisleInfo, storeID: widget.storeID, aisleID: aisleID,))
    );
  }

  Widget buildListView(Map<String,dynamic> inventory){
    List<String> keys = inventory.keys.toList();
    return ListView.builder(
        itemCount: keys.length,
        itemBuilder: (context, index){
          return ListTile(
              title: Text('Aisle ${keys[index]}', style: Theme.of(context).textTheme.headlineSmall,),
              onTap: (){ navigateToStorePage( inventory[keys[index]], keys[index]); }
          );
        }
    );
  }


  Widget createBody(){
    // print(widget.storeDoc.data()['inventory']);
    Map<String, dynamic> inventory = widget.storeDoc.data()['inventory'];

    return Expanded(child: buildListView(inventory));
  }

  @override
  Widget build(context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Store ${widget.storeID}"),
      ),
      body: Column(
        children: [
          Center(child: Text('Aisles', style: Theme.of(context).textTheme.headlineMedium)),
          createBody(),
        ],
      ),
    );
  }

}