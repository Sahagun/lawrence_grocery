import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ItemPage extends StatefulWidget {

  final Map<String,dynamic> inventory;
  final String storeID;
  final String aisleID;
  final String shelfID;
  final String item;

  ItemPage({Key? key,
    required this.item,
    required this.inventory,
    required this.storeID,
    required this.aisleID,
    required this.shelfID});

  @override
  State createState() => _State();
}

class _State extends State<ItemPage>{

  int count = 0;

  void increaseInventory(int increaseAmount ) async {
    DocumentReference ref = FirebaseFirestore.instance.doc("stores/${widget.storeID}");
    DocumentSnapshot<Map<String, dynamic>> snapshot = await ref.get() as DocumentSnapshot<Map<String, dynamic>>;
    Map<String, dynamic> data = snapshot.data()!;
    if( count + increaseAmount <= 0 ){
      data['inventory'][widget.aisleID][widget.shelfID][widget.item] = 0;
    }
    else{
      data['inventory'][widget.aisleID][widget.shelfID][widget.item] = count + increaseAmount;
    }
    ref.update(data);
  }


  StreamBuilder countStream(){
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance.doc("stores/${widget.storeID}").snapshots(),
        builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>> snapshot){

          if (snapshot.hasError) {
            return const Text("An Error Has Occurred.");
          }

          else if (snapshot.hasData) {
            count =  snapshot.data!['inventory'][widget.aisleID][widget.shelfID][widget.item];

            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // ElevatedButton(child: const Icon(Icons.remove) , onPressed: (){
                //   increaseInventory(-1);
                // }),

                Text(
                  'Count: $count',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                // ElevatedButton(child: const Icon(Icons.add) , onPressed: (){
                //   increaseInventory(1);
                // }),
              ],
            );

          }

          else{
            return const CircularProgressIndicator();
          }

        }
    );
  }


  @override
  Widget build(context){
    return Scaffold(
      appBar: AppBar(
        title: Text("Store ${widget.storeID} - A${widget.aisleID} S${widget.shelfID}"),
      ),

      body: Column(
        children: [
          Center(
            child: Text('${widget.item}',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ),

          Expanded(child: Center(child: countStream())),

        ],
      ),
    );
  }

}