import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:custom_searchable_dropdown/custom_searchable_dropdown.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class EditPage extends StatefulWidget {

  final Map<String,dynamic> inventory;
  final Map<String,dynamic> changes;
  final String storeID;
  final String aisleID;
  final String shelfID;
  final XFile imageFile;

  EditPage({Key? key,
    required this.inventory,
    required this.changes,
    required this.storeID,
    required this.aisleID,
    required this.shelfID,
    required this.imageFile,
  });

  @override
  State createState() => _State();
}

class _State extends State<EditPage>{

  late Map<String,dynamic> shelfInventory;

  DateTime timestamp = DateTime.now();
  String? selectedItem;
  int newCount = 0;
  List<String> itemsList = [];

  @override
  initState() {
    super.initState();
    shelfInventory = widget.inventory;
    for(String key in widget.changes.keys.toList()){
      shelfInventory[key] = widget.changes[key];
    }


    if(widget.changes.isNotEmpty){
      itemsList = widget.changes.keys.toList();
      selectedItem = itemsList[0];
      newCount = widget.changes[selectedItem];
    }

  }


  void increaseInventory(String key, int increaseAmount ) async {
    int currentCount = shelfInventory[key];
    if( currentCount + increaseAmount <= 0 ){
      shelfInventory[key] = 0;
    }
    else{
      shelfInventory[key] += increaseAmount;
    }
    setState(() { });
  }


  Future<void> updateDatabase() async {
    DocumentReference ref = FirebaseFirestore.instance.doc("stores/${widget.storeID}");
    DocumentSnapshot<Map<String, dynamic>> snapshot = await ref.get() as DocumentSnapshot<Map<String, dynamic>>;
    Map<String, dynamic> data = snapshot.data()!;

    shelfInventory.removeWhere((key, value) => value == 0);

    data['inventory'][widget.aisleID][widget.shelfID] = shelfInventory;
    await ref.update(data);
    Navigator.pop(context);
  }

  void uploadImagePath(String path) {
    // print(snapshot);
    // print(snapshot.ref.fullPath);

    String shelfkey = '${widget.storeID}_${widget.aisleID}_${widget.shelfID}_$selectedItem';
    String recentKey = '${widget.storeID}_$selectedItem';

    FirebaseDatabase.instance.ref('shelfImages').update({shelfkey:path});
    FirebaseDatabase.instance.ref('recentImages').update({recentKey:path});

  }


  Future<void> uploadImage() async{
    String path = 'images/${widget.storeID}/${widget.aisleID}/${widget.shelfID}/$selectedItem/$timestamp.jpeg';
    var storageRef = FirebaseStorage.instance.ref(path);
    final metadata = SettableMetadata(
      contentType: 'image/jpeg',
      customMetadata: {'picked-file-path': widget.imageFile.path},
    );
    UploadTask uploadTask;
    uploadTask = storageRef.putFile(File(widget.imageFile.path), metadata);
    Future.value(uploadTask).then(
            (value) => {
          uploadImagePath(path)
        }
    ).onError((error, stackTrace) => {
      print('Error')
    });
  }


  Future<void> uploadImageAndUpdateDatabase() async {

    // Update Invetory
    DocumentReference ref = FirebaseFirestore.instance.doc("stores/${widget.storeID}");
    DocumentSnapshot<Map<String, dynamic>> snapshot = await ref.get() as DocumentSnapshot<Map<String, dynamic>>;
    Map<String, dynamic> data = snapshot.data()!;

    shelfInventory.removeWhere((key, value) => value == 0);

    data['inventory'][widget.aisleID][widget.shelfID][selectedItem] = newCount;
    await ref.update(data);

    // Upload Image
    await uploadImage();

    // // Save Image Location
    // if (task != null) {
    // }


    // Navigator.pop(context);
  }


  Widget buildListView(){
    List<String> keys = shelfInventory.keys.toList();

    return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: keys.length,
        itemBuilder: (context, index){
          return ListTile(
            title: Text('${keys[index]}: ${shelfInventory[keys[index]]}',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            // trailing: Text('${inventory[keys[index]]}',
            //   style: Theme.of(context).textTheme.headlineSmall,
            // ),
            leading: ElevatedButton(child: const Icon(Icons.remove) , onPressed: (){
              increaseInventory(keys[index], -1);
            },),
            trailing: ElevatedButton(child: const Icon(Icons.add) , onPressed: (){
              increaseInventory(keys[index], 1);
            },),
          );
        }
    );
  }


  void onChangedSearchBar(value){
    if(value!=null){
      selectedItem = value;
      // setState(() { });
      // Navigator.push(context, MaterialPageRoute(builder: (builder)=> WishListChooseStorePage(item: value) ));
    }
    else{ selectedItem = null; }
  }

  Widget itemSection(){
    if(widget.changes.isEmpty){
      return Column(
        children: [
          Text("No Items Detected",
            style: Theme.of(context).textTheme.headlineMedium,
          ),
        ],
      );
    }
    else{
      print(selectedItem);
      return Column(
        children: [
          Text("$timestamp"),

          Padding(
            padding: const EdgeInsets.all(8.0),
            child: CustomSearchableDropDown(
              items: itemsList,
              label: 'Item',
              onChanged: onChangedSearchBar,
              dropDownMenuItems: itemsList,
              initialIndex: 0,
              menuMode: true,
            ),
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [


              ElevatedButton(child: const Icon(Icons.remove) , onPressed: ()
              {setState(() {
                newCount--;
                if(newCount < 0) {newCount = 0;}
              }); }
              ),

              Text('${newCount}',
                style: Theme.of(context).textTheme.headlineSmall,
              ),

              ElevatedButton(child: const Icon(Icons.add) , onPressed: ()
              {setState(() { newCount++; }); }
              ),

            ],
          ),

          ElevatedButton(
              onPressed: (selectedItem == null) ? null : uploadImageAndUpdateDatabase,
              child: Text("Confirm")
          ),
        ],
      );

    }
  }


  @override
  Widget build(context){
    return Scaffold(
      appBar: AppBar(
        title: Text("Store ${widget.storeID} - A${widget.aisleID} S${widget.shelfID}"),
      ),

      body: SingleChildScrollView(
        physics: ScrollPhysics(),
        child: Column(
          children: [
            // Center(
            //   child: Text('Edit',
            //     style: Theme.of(context).textTheme.headlineMedium,
            //   ),
            // ),

            Padding(
              padding: const EdgeInsets.all(23.0),
              child: Image.file(
                File(widget.imageFile.path),
                fit: BoxFit.scaleDown,
              ),
            ),
            itemSection(),
            // buildListView(),
            // Expanded(child: buildListView()),

            // Center(child: ElevatedButton(onPressed: updateDatabase, child: const Text('Save'))),
          ],
        ),
      ),

    );
  }

}