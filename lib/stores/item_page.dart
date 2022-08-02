import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
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


  FutureBuilder _futureImageBuilderHelper(String imagePath){
    return FutureBuilder(
        future: FirebaseStorage.instance.ref(imagePath).getDownloadURL(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            print(snapshot.data);
            if (snapshot.data == null) {
              return const Text('No Image Found');
            }
            else{
              return Image.network(snapshot.data, fit: BoxFit.scaleDown);
              return const Text('Image Found');
            }

          }
          else if(snapshot.hasError){return const Text('No Image Found');}
          return const Text('LoadingImage');
        }
    );
  }

  FutureBuilder futureImageBuilder(){
    String key = '${widget.storeID}_${widget.aisleID}_${widget.shelfID}_${widget.item}';
    return FutureBuilder(
        future: FirebaseDatabase.instance.ref('shelfImages').get(),
        builder: (context, AsyncSnapshot snapshot) {
          if(snapshot.hasData){
            if(snapshot.data.value == null){
              return const Text('No Image Found');
            }

            Map<dynamic, dynamic> data = snapshot.data.value;

            if(data.containsKey(key)){
              String imagePath = data[key];
              print(imagePath);
              return _futureImageBuilderHelper(imagePath);
            }
            else{
              return const Text('No Image Found');
            }

            print(snapshot.data.value);
          }
          else if(snapshot.hasError){return const Text('No Image Found');}
          return const Text('Loading Image...');
        }
    );
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

                Text(
                  'Count: $count',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),


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
        title: Text("Store ${widget.storeID} Aisle ${widget.aisleID} Shelf ${widget.shelfID}"),
      ),

      body: Column(
        children: [
          Center(
            child: Text('${widget.item}',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(23.0),
                child: Center(child: futureImageBuilder())
            )
          ),


        Padding(
          padding: const EdgeInsets.only(bottom: 30),
          child: Center(child: countStream()),
        ),

        ],
      ),
    );
  }

}