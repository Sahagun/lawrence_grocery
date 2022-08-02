import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lawrence/camera_page.dart';
import 'package:lawrence/login_page.dart';
import 'package:lawrence/wishlist_page.dart';

class HomePage extends StatefulWidget {

  @override
  _HomePageState createState() => _HomePageState();

}

class _HomePageState extends State<HomePage> {


  void logout() async{
    await FirebaseAuth.instance.signOut();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
          (route) => false,
    );
  }


  void navigateToWishListPage(){
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => WishListPage())
    );
  }

  void navigateToCameraPage(){
    Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => CameraPage())
    );
  }



  Widget navigationSection(){
    return Container(
      color: Colors.green,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Wishlist Button
          ElevatedButton(
              onPressed: navigateToWishListPage,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.playlist_add),
                  Text('Shopping List'),
                ],
              )
          ),

          // Camera Button
          ElevatedButton(
              onPressed: navigateToCameraPage,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.camera_alt),
                  Text('Camera'),
                ],
              )
          ),

        ],
      ),
    );
  }


  Widget wishlist(){
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance.doc("userShoppingList/${FirebaseAuth.instance.currentUser!.uid}").snapshots(),
      builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>> snapshot){
        return Text("TODO");
      }
    );
  }


  @override
  Widget build(context){

    ScaffoldMessenger.of(context).removeCurrentSnackBar();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(onPressed: logout, icon: const Icon(Icons.logout)),
        ],
      ),
      body: Column(
        children: [
          Expanded(child: wishlist()),
          navigationSection(),
        ],
      ),
    );
  }

}