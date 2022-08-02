import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'upload_sucess_page.dart';

class AddItemPage extends StatefulWidget{

  final String item;

  const AddItemPage({Key? key, required this.item}) : super(key: key);

  @override
  _AddItemPageState createState() => _AddItemPageState();

}

class _AddItemPageState extends State<AddItemPage>{

  int qty = 1;
  bool submitLock = false;

  void add(){
    setState(() {
      qty++;
      if(qty>1000){
        qty = 1000;
      }
    });
  }

  void minus(){
    setState(() {
      qty--;
      if(qty<1){
        qty = 0;
      }
    });
  }

  void submit() async{
    if(submitLock == true){
      return;
    }
    submitLock = true;

    DocumentReference<Map<String,dynamic>> docRef = FirebaseFirestore.instance.doc("userShoppingList/${FirebaseAuth.instance.currentUser!.uid}");
    DocumentSnapshot snapshot = await docRef.get();

    if(snapshot.exists){
      Map<String,dynamic> data = snapshot.data() as Map<String,dynamic>;
      if(data.containsKey("shoppingList")){
        Map<String,dynamic> shoppingList = data['shoppingList'];
        shoppingList[widget.item] = qty;
        data['shoppingList'] = shoppingList;
        print(data);
        docRef.update(data);
      }
      else{
        Map<String,dynamic> shoppingList = {widget.item: qty};
        data['shoppingList'] = shoppingList;
        print(data);

        docRef.update(data);
      }
    }
    else{
      var data = {
        'shoppingList':{
          widget.item: qty
        }
      };
      print(data);

      docRef.set(data);
    }

    Navigator.push(context, MaterialPageRoute(builder: (builder) => UploadSuccessPage()));

    submitLock = false;
  }

  Widget body(){
    return Column(
      children: [

        // TODO Image Container
        Container(),

        // Item info
        Text(
          widget.item,
          style: const TextStyle(fontSize: 25),
        ),
        // Text("Description goes here"),


        Expanded(child: Container()),

        // Qty buttons
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children:[
            IconButton(onPressed: minus, icon: const Icon(Icons.remove)),
            Text(
              "$qty",
              style: const TextStyle(fontSize: 50),
            ),
            IconButton(onPressed: add, icon: const Icon(Icons.add)),
          ],
        ),
        Expanded(child: Container()),
        ElevatedButton(onPressed: submit, child: const Text("Submit")),

      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add Item - " + widget.item),
      ),
      body: body(),
    );
  }

}
