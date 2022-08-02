import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:lawrence/stores/edit_page.dart';
import 'package:lawrence/stores/item_page.dart';
import 'package:async/async.dart';
import 'package:path/path.dart' as path;

class InventoryPage extends StatefulWidget {

  final Map<String,dynamic> inventory;
  final String storeID;
  final String aisleID;
  final String shelfID;


  const InventoryPage({Key? key, required this.inventory, required this.storeID, required this.aisleID, required this.shelfID}) : super(key: key);

  @override
  _InventoryPageState createState() => _InventoryPageState();

}

class _InventoryPageState extends State<InventoryPage> {

  Map<String, dynamic> inventory = {};

  void navigateToItemPage(String item){
    Navigator.push(
        context,
        MaterialPageRoute(builder: (BuildContext context) => ItemPage(
          item: item,
          inventory: inventory,
          shelfID: widget.shelfID,
          aisleID: widget.aisleID,
          storeID: widget.storeID,))
    );
  }


  void navigateToEditPage(Map<String, dynamic> changes, XFile imageFile){

    Map<String, dynamic> shelfInventory = inventory[widget.aisleID][widget.shelfID];

    Navigator.push(
        context,
        MaterialPageRoute(builder: (BuildContext context) => EditPage(
          inventory: shelfInventory,
          changes: changes,
          shelfID: widget.shelfID,
          aisleID: widget.aisleID,
          storeID: widget.storeID,
          imageFile: imageFile,
        ))
    );
  }

  StreamBuilder inventoryStream(){
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance.doc("stores/${widget.storeID}").snapshots(),
      builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>> snapshot){

        if (snapshot.hasError) {
          return const Text("An Error Has Occurred.");
        }

        else if (snapshot.hasData) {
          inventory =  snapshot.data!['inventory'];
          return Expanded(child: buildListView(inventory));
        }

        else{
          return const CircularProgressIndicator();
        }

      }
    );
  }


  void increaseInventory(String key, int current, int increaseAmount ) async {
    DocumentReference ref = FirebaseFirestore.instance.doc("stores/${widget.storeID}");
    DocumentSnapshot<Map<String, dynamic>> snapshot = await ref.get() as DocumentSnapshot<Map<String, dynamic>>;
    Map<String, dynamic> data = snapshot.data()!;
    if( current + increaseAmount <= 0 ){
      data['inventory'][widget.aisleID][widget.shelfID][key] = 0;
    }
    else{
      data['inventory'][widget.aisleID][widget.shelfID][key] = current + increaseAmount;
    }
    ref.update(data);
  }


  Future<void> setInventoryItem(String key, int count) async {
    DocumentReference ref = FirebaseFirestore.instance.doc("stores/${widget.storeID}");
    DocumentSnapshot<Map<String, dynamic>> snapshot = await ref.get() as DocumentSnapshot<Map<String, dynamic>>;
    Map<String, dynamic> data = snapshot.data()!;
    if( count > 0 ){
      data['inventory'][widget.aisleID][widget.shelfID][key] = count;
      print(key);
      print(count);
      await ref.update(data);
    }
  }

  Future<void> setInventory(Map<String, dynamic> cameraInventory) async {
    var keys = cameraInventory.keys.toList();
    for(String key in keys){
      var value = cameraInventory[key];
      if (value is int){
        print('is int');
        await setInventoryItem(key, value);
      }
    }
  }



  Widget buildListView(Map<String,dynamic> inventoryFromSnapshot){

    Map<String,dynamic> inventory = inventoryFromSnapshot[widget.aisleID][widget.shelfID];

    List<String> keys = inventory.keys.toList();
    return ListView.builder(
        itemCount: keys.length,
        itemBuilder: (context, index){
          return ListTile(
            title: Text('${keys[index]}',
                style: Theme.of(context).textTheme.headlineSmall,
            ),
            trailing: Text('${inventory[keys[index]]}',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            onTap: (){
              navigateToItemPage(keys[index]);
            },
            // leading: ElevatedButton(child: const Icon(Icons.remove) , onPressed: (){increaseInventory(keys[index], inventory[keys[index]], -1);},),
            // trailing: ElevatedButton(child: const Icon(Icons.add) , onPressed: (){increaseInventory(keys[index], inventory[keys[index]], 1);},),
          );
        }
    );
  }


  Future<void> getCountFromImage(XFile imageFile) async {
    var request = http.MultipartRequest(
        'POST',
        Uri.parse("http://13.57.7.93:5000/analyze")
    );

    var stream = http.ByteStream(DelegatingStream(imageFile.openRead()));
    var length = await imageFile.length();

    request.files.add(
      http.MultipartFile(
        'image',
        stream,
        length,
        filename: path.basename(imageFile.path),
      ),
    );

    var response = await request.send();

    print(response.statusCode);
    response.stream.transform(utf8.decoder).listen((value) async{
      print(value);
      Map<String, dynamic> jsonValue = json.decode(value);
      print(jsonValue);

      navigateToEditPage(jsonValue, imageFile);

      // await setInventory(jsonValue);
    });
  }

  void cameraButton() async {
    ImagePicker picker = ImagePicker();
    // XFile? _imageFile = await picker.pickImage(source: ImageSource.camera);
    XFile? _imageFile = await picker.pickImage(source: ImageSource.camera);
    if(_imageFile != null){
      // To something
      print('picture was  taken');
      await getCountFromImage(_imageFile);
    }
    else{
      // Do nothing
      print('no picture was taken');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Store ${widget.storeID} - A${widget.aisleID} S${widget.shelfID}",
        ),
      ),
      body: Column(
        children: [
          Center(child: Text('Inventory',
            style: Theme.of(context).textTheme.headlineMedium,
          )),
          inventoryStream(),
          ElevatedButton(onPressed: cameraButton, child: const Icon(Icons.camera_alt))
        ],
      ),
    );
  }

}