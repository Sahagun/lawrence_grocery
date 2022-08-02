import 'package:flutter/material.dart';
import 'package:lawrence/stores/inventory_page.dart';

class AisleInfoPage extends StatefulWidget {

  final Map<String,dynamic> aisleInfo;
  final String storeID;
  final String aisleID;

  const AisleInfoPage({Key? key, required this.aisleInfo, required this.storeID, required this.aisleID}) : super(key: key);

  @override
  _AisleInfoPageState createState() => _AisleInfoPageState();

}

class _AisleInfoPageState extends State<AisleInfoPage> {

  void navigateToInventoryPage(Map<String,dynamic> inventoryInfo, String shelfID){
    Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => InventoryPage(
          inventory:inventoryInfo,
          shelfID: shelfID,
          aisleID: widget.aisleID,
          storeID: widget.storeID,))
    );
  }

  Widget buildListView(){
    List<String> keys = widget.aisleInfo.keys.toList();
    return ListView.builder(
        itemCount: keys.length,
        itemBuilder: (context, index){
          return ListTile(
              title: Text('Shelf ${keys[index]}', style: Theme.of(context).textTheme.headlineSmall,),
              onTap: (){ navigateToInventoryPage(widget.aisleInfo[keys[index]], keys[index]); }
          );
        }
    );
  }


  Widget createBody(){
    // print(widget.storeDoc.data()['inventory']);
    return Expanded(child: buildListView());
  }

  @override
  Widget build(context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Store ${widget.storeID} - A${widget.aisleID}"),
      ),
      body: Column(
        children: [
          Center(child: Text('Shelves', style: Theme.of(context).textTheme.headlineMedium,)),
          createBody(),
        ],
      ),
    );
  }

}