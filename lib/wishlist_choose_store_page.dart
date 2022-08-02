import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lawrence/wishlist_details_page.dart';

class WishListChooseStorePage extends StatefulWidget{

  final String item;

  const WishListChooseStorePage({Key? key, required this.item}) : super(key: key);

  @override
  _WishListChooseStorePageState createState() => _WishListChooseStorePageState();

}

class _WishListChooseStorePageState extends State<WishListChooseStorePage> {

  int countItemFromInventory(Map<String, dynamic> storeData){
    int count = 0;
    // print("countItemFromInventory");
    for(String aisle in storeData["inventory"].keys){
      for(String shelf in storeData["inventory"][aisle].keys){
        // print("aisle $aisle shelf $shelf");
        if(storeData["inventory"][aisle][shelf].keys.contains(widget.item)){
          // print("has ${widget.item} ${storeData["inventory"][aisle][shelf][widget.item]}");
          count += storeData["inventory"][aisle][shelf][widget.item] as int;
        }
      }
    }
    return count;
  }

  void navigateToDetails(storeID, item){
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (BuildContext context) => WishListDetailsPage(storeID:storeID, item:item))
    );
  }

  Widget buildBody(List<QueryDocumentSnapshot> storeDocs){
    List<String> storeIDs = [];
    for (QueryDocumentSnapshot doc in storeDocs){
      storeIDs.add(doc.id);
    }

    return ListView.builder(
      itemCount: storeIDs.length,
      itemBuilder: (context, index){
        Map<String, dynamic> storeData = storeDocs[index].data() as Map<String, dynamic>;
        int stockCount = countItemFromInventory(storeData);
        return ListTile(
          title: Text('Store#${storeIDs[index]}'),
          trailing: Text('$stockCount'),
          onTap: (){
            navigateToDetails(storeIDs[index], widget.item);
          },
        );
      }
    );
  }


  StreamBuilder steamBuilderAllStores() {
    return StreamBuilder(
        stream: FirebaseFirestore.instance.collection("stores").snapshots(),
        builder: (context, AsyncSnapshot snapshot){
          if(snapshot.hasData){

            List<QueryDocumentSnapshot> storeDocs = snapshot.data.docs;


            // Map<String, dynamic> allStoresData = snapshot.data.data();
            return buildBody(storeDocs);
          }
          else if(snapshot.hasError){return const Text('An Error has occurred');}
          return const Text('Loading...');
        }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.item} Stock"),
      ),
      body: steamBuilderAllStores(),
    );
  }
}