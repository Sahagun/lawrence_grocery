import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class WishListDetailsPage extends StatefulWidget{

  final String storeID;
  final String item;

  const WishListDetailsPage({Key? key, required this.storeID, required this.item}) : super(key: key);

  @override
  _WishListDetailsPageState createState() => _WishListDetailsPageState();

}

class _WishListDetailsPageState extends State<WishListDetailsPage> {
  
  String time = "1:02";

  void plus() async{
    DocumentReference ref = FirebaseFirestore.instance.doc("userShoppingList/${FirebaseAuth.instance.currentUser!.uid}");
    DocumentSnapshot doc = await ref.get();
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    if(data.containsKey('storeWishList')){
      if(data['storeWishList'].containsKey(widget.storeID)){
        if(data['storeWishList'][widget.storeID].containsKey(widget.item)){
          data['storeWishList'][widget.storeID][widget.item]++;
        }
        else{
          data['storeWishList'][widget.storeID][widget.item] = 1;
        }
      }
      else{
        data['storeWishList'][widget.storeID] = {
            widget.item: 1
        };
      }
    }
    else{
      data['storeWishList'] = {
        widget.storeID: {
          widget.item: 1
        }
      };
    }
    ref.update(data);
  }

  void minus() async{
    DocumentReference ref = FirebaseFirestore.instance.doc("userShoppingList/${FirebaseAuth.instance.currentUser!.uid}");
    DocumentSnapshot doc = await ref.get();
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    if(data.containsKey('storeWishList')){
      if(data['storeWishList'].containsKey(widget.storeID)){
        if(data['storeWishList'][widget.storeID].containsKey(widget.item)){
          data['storeWishList'][widget.storeID][widget.item]--;
          if(data['storeWishList'][widget.storeID][widget.item] < 0){
            data['storeWishList'][widget.storeID][widget.item] = 0;
          }
          ref.update(data);
        }
      }
    }
  }

  void deleteButton() async{
    DocumentReference ref = FirebaseFirestore.instance.doc("userShoppingList/${FirebaseAuth.instance.currentUser!.uid}");
    DocumentSnapshot doc = await ref.get();
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    if(data.containsKey('storeWishList')){
      if(data['storeWishList'].containsKey(widget.storeID)){
        if(data['storeWishList'][widget.storeID].containsKey(widget.item)){
          data['storeWishList'][widget.storeID].remove(widget.item);
          await ref.update(data);
        }
      }
    }
    Navigator.pop(context);
  }

  Widget body(int inventoryCount, int wishListCount){
    return Column(
      children:[
        // Photo of Product
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(23.0),

            child: Center(child: futureImageBuilder())
            // child: const Image(
            //   image: NetworkImage('https://flutter.github.io/assets-for-api-docs/assets/widgets/owl.jpg'),
            //   fit: BoxFit.scaleDown,
            // ),
          ),
        ),
        // Time
        // Row(
        //     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        //     children:[
        //       Text(
        //         "Time of the Photo: $time",
        //         style: Theme.of(context).textTheme.bodyText2,
        //       ),
        //     ]
        // ),
        // Item Count
        Padding(
          padding: const EdgeInsets.all(5.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children:[
              Text(
                "Inventory Count: $inventoryCount",
                style: Theme.of(context).textTheme.headline5,
              ),
            ],
          ),
        ),
        // Wishlist Quantity Text
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children:const[
            const Text(
              "Wishlist Quantity",
              style: TextStyle(fontSize: 24),
            ),
          ],
        ),
        // Edit Wishlist Quantity
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children:[
            Container(
                color: Colors.green,
                child: IconButton(onPressed: minus, icon: Icon(Icons.remove))
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "$wishListCount",
                  style: Theme.of(context).textTheme.headline5,
                ),
              ],
            ),
            Container(
                color: Colors.green,
                child: IconButton(onPressed: plus, icon: Icon(Icons.add))
            ),
          ],
        ),
        // Add & Delete Buttons
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children:[
            ElevatedButton(
              onPressed: deleteButton,
              child: Column(
                children:const [
                  Icon(Icons.delete),
                  Text("Delete"),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }


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
    String key = '${widget.storeID}_${widget.item}';
    // String key = '0001_apple';
    return FutureBuilder(
        future: FirebaseDatabase.instance.ref('recentImages').get(),
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

  StreamBuilder steamBuilderInventory() {
    return StreamBuilder(
      stream: FirebaseFirestore.instance.doc("stores/${widget.storeID}").snapshots(),
      builder: (context, AsyncSnapshot snapshot){
        if(snapshot.hasData){
          Map<String, dynamic> storeData = snapshot.data.data();
          int itemCount = countItemFromInventory(storeData);
          return steamBuilderUserWishList(itemCount);
        }
        else if(snapshot.hasError){return const Text('An Error has occurred');}
        return const Text('Loading...');
      }
    );
  }

  StreamBuilder steamBuilderUserWishList(int inventoryCount) {
    return StreamBuilder(
        stream: FirebaseFirestore.instance.doc("userShoppingList/${FirebaseAuth.instance.currentUser!.uid}").snapshots(),
        builder: (context, AsyncSnapshot snapshot){
          if(snapshot.hasData){
            Map<String, dynamic> userWishListData = snapshot.data.data();
            Map<String, dynamic> userAllStoresWishList = userWishListData["storeWishList"];
            if(userAllStoresWishList.keys.contains(widget.storeID)){
              //  Store in wishlist exists
              Map<String, dynamic> userStoreWishList = userAllStoresWishList[widget.storeID];
              if(userStoreWishList.keys.contains(widget.item)){
                //  Item exists in wishlist
                int wishListCount =  userStoreWishList[widget.item] as int;
                return body(inventoryCount, wishListCount);
              }
            }

            //  return something here
            return body(inventoryCount, 0);

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
        title: Text('${widget.item} at Store#${widget.storeID}'),
      ),
      body: steamBuilderInventory(),
    );
  }

}