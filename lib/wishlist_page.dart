import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:custom_searchable_dropdown/custom_searchable_dropdown.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lawrence/wishlist_choose_store_page.dart';
import 'package:lawrence/wishlist_details_page.dart';

import 'add_item_page.dart';


class WishListPage extends StatefulWidget{

  @override
  _WishListPageState createState() => _WishListPageState();

}

class _WishListPageState extends State<WishListPage>{

  String storeID = '0001';
  Stream<DocumentSnapshot<Map<String, dynamic>>> wishListStream = FirebaseFirestore.instance.doc("userShoppingList/${FirebaseAuth.instance.currentUser!.uid}").snapshots();

  List<String> itemsList = [];

  @override
  initState() {
    super.initState();
    _getItems();
  }

  Future<void> _getItems() async{
    final String _itemString = await rootBundle.loadString('assets/items.txt');
    itemsList = _itemString.split('\n');
  }


  void navigateToDetails(storeID, item){
    Navigator.push(
        context,
        MaterialPageRoute(builder: (BuildContext context) => WishListDetailsPage(storeID:storeID, item:item))
    );
  }

  Widget wishListBuilder(Map<String, dynamic> wishListMap){

    List<ListTile> children = [];

    for(String storeIDKey in wishListMap.keys){

      Map<String, dynamic> storeWishListMap = wishListMap[storeID];
      List<String> items = storeWishListMap.keys.toList();

      for(String item in items){
        children.add(
            ListTile(
              title: Text(item),
              subtitle: Text("Store #$storeIDKey"),
              trailing: Text('${storeWishListMap[item]}'),
              onTap: () { navigateToDetails(storeIDKey, item); },
            )
        );
      }
    }

    if(children.isEmpty){
      return const Text('Your Wishlist is Empty');
    }
    else{
      return ListView(
        children: children,
      );
    }
  }


  StreamBuilder wishListStreamBuilder(){
    return StreamBuilder(
        stream: wishListStream,
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot){
          if(snapshot.hasError){
            return const Text('No WishList Found');
          }
          else{
            switch(snapshot.connectionState){
              case ConnectionState.none:
                return const Text('No WishList Found and user does not exisits');
              case ConnectionState.waiting:
                return const CircularProgressIndicator();


              case ConnectionState.active:

                if(snapshot.data!.data() == null){
                  return Text('No WishList Found and does not user exists');
                }
                else{
                  Map<String, dynamic> doc = snapshot.data!.data();
                  if(doc.containsKey('storeWishList')){
                    if(doc['storeWishList'].keys.length == 0){
                      return Text('User exists, a wishlist exists but its empty');
                    }
                    else{
                      return wishListBuilder(doc['storeWishList']);
                    }
                  }
                  else{
                    return Text('No WishList Found but user exists');
                  }
                }



              case ConnectionState.done:
                return const Text('Error');
            }
          }



        },
    );
  }

  void onChangedSearchBar(value){
    if(value!=null){
      Navigator.push(context, MaterialPageRoute(builder: (builder)=> WishListChooseStorePage(item: value) ));
    }
    else{ }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Wishlist"),
      ),
      body: Column(
        children: [
          //TODO add search bar

          Padding(
            padding: const EdgeInsets.all(8.0),
            child: CustomSearchableDropDown(
              items: itemsList,
              label: 'Search',
              onChanged: onChangedSearchBar,
              dropDownMenuItems: itemsList,
              dropdownHintText: 'Search For item Here... ',
              menuMode: true,
            ),
          ),

          Expanded(child: Center(child: wishListStreamBuilder())),
        ],
      )
    );
  }


}
  // List<String> itemsList = [];

//   Future<List<String>> loadItems() async{
//     String itemText = await rootBundle.loadString('assets/items.txt');
//     if(itemText.isEmpty){
//       return [];
//     }
//     itemsList = itemText.split(',');
//     itemsList.sort();
//     return itemsList;
//   }
//
//
//   FutureBuilder<List<String>> itemsBuilder(){
//     return FutureBuilder<List<String>>(
//       future: loadItems(),
//       builder: (context, snapshot){
//         if(snapshot.hasData){
//           if(snapshot.data!.isNotEmpty){
//             return Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: SearchArea(itemsList: itemsList),
//             );
//           }
//           else{
//             return Text('No thing was loaded');
//           }
//         }
//         else if(snapshot.hasError){
//           return Text('Error!');
//         }
//         return Text("Loading");
//       },
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Add Item"),
//       ),
//       body: itemsBuilder(),
//     );
//   }
//
// }
//
//
//
// class SearchArea extends StatefulWidget{
//
//   final List<String> itemsList;
//
//   const SearchArea({Key? key, required this.itemsList}) : super(key: key);
//
//   @override
//   _SearchAreaState createState() => _SearchAreaState();
//
// }
//
// class _SearchAreaState extends State<SearchArea>{
//
//   String filterWord = "";
//   List<String> filteredList = [];
//
//   @override
//   void initState(){
//     super.initState();
//     filteredList = widget.itemsList;
//   }
//
//
//   void filter(String? f){
//     if(f == null || f.isEmpty){
//       filteredList = widget.itemsList;
//     }
//
//     f = f!.trim();
//
//     filteredList = [];
//
//     for(String w in widget.itemsList){
//       if(w.toLowerCase().contains(f.toLowerCase())){
//         filteredList.add(w);
//       }
//     }
//
//     if(filteredList.isEmpty){
//       filteredList.add(f);
//     }
//
//     setState((){});
//   }
//
//
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//         children: [
//           TextFormField(
//             onChanged: filter,
//             decoration: const InputDecoration(
//               labelText: "Search",
//               hintText: 'Search',
//             ),
//           ),
//
//           Expanded(
//             child: ListView.builder(
//                 itemCount: filteredList.length,
//                 itemBuilder: (context, index){
//                   return ListTile(
//                     title: Text(filteredList[index]),
//                     onTap: (){
//                       Navigator.push(context, MaterialPageRoute(builder: (builder)=> AddItemPage(item: filteredList[index])));
//                     },
//                   );
//                 }
//             ),
//           )
//
//         ]
//     );
//   }
// }
