import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lawrence/login_page.dart';
import 'package:lawrence/stores/store_info_page.dart';
import 'package:lawrence/wishlist_page.dart';

class Dashboard extends StatefulWidget {

  @override
  _DashboardState createState() => _DashboardState();

}

class _DashboardState extends State<Dashboard> {

  void navigateToStorePage(QueryDocumentSnapshot<Map<String,dynamic>> storeDoc){
    Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => StoreInfoPage(storeDoc:storeDoc, storeID: storeDoc.id,))
    );
  }

  void navigateToWishList(){
    Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => WishListPage())
    );
  }

  Widget buildListView(List<QueryDocumentSnapshot<Map<String,dynamic>>> docs){
    return ListView.builder(
      itemCount: docs.length,
      itemBuilder: (context, index){
        return ListTile(
          title: Text('Store #${docs[index].id}', style: Theme.of(context).textTheme.headlineSmall,),
          onTap: (){ navigateToStorePage(docs[index]); }
        );
      }
    );
  }

  Future<List<QueryDocumentSnapshot<Map<String,dynamic>>>> getStores() async {
    QuerySnapshot<Map<String,dynamic>> snapshot =  await FirebaseFirestore.instance.collection("stores").get();
    return snapshot.docs;
  }

  FutureBuilder futureBody(){
    return FutureBuilder(
      future: getStores(),
      builder: (context, snapshot){
        if (snapshot.hasData) {
          List<QueryDocumentSnapshot<Map<String,dynamic>>> storeDocs = snapshot.data;
          if (storeDocs.isEmpty){
            return const Expanded(child: Center(child: Text('empty')));
          }
          else{
            return Expanded(child: buildListView(storeDocs));
          }
        }
        else if (snapshot.hasError) {
          return const Expanded(child: Center(child: Text('An Error Has Occurred')));
        }
        return const Expanded(child: Center(child: CircularProgressIndicator()));
      }
    );
  }

  void logout(){
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (BuildContext context) => LoginPage()),
            (Route<dynamic> route) => false
    );
  }

  Widget navSection(){
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton(onPressed: (){setState(() {});}, child: const Text("Refresh")),
        ElevatedButton(onPressed: navigateToWishList, child: const Text("Wishlist"))
      ],
    );
  }

  @override
  Widget build(context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Welcome"),
        actions: [
          IconButton(onPressed: logout, icon: Icon(Icons.logout))
        ],
      ),
      body: Column(
        children: [
          Center(child: Text('Stores', style: Theme.of(context).textTheme.headlineMedium,)),
          futureBody(),
          navSection(),
        ],
      ),
    );
  }

}