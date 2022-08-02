import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lawrence/product_upload_page.dart';


class CameraPage extends StatefulWidget{

  @override
  _CameraPageState createState() => _CameraPageState();

}

class _CameraPageState extends State<CameraPage>{

  final ImagePicker imagePicker = ImagePicker();
  File? _imageFile;

  bool pictureTaken = false;
  int pictureCount = 0; // <- Delete this!!


  Future getImage() async{
    final XFile? pickedImage = await imagePicker.pickImage(source: ImageSource.camera);

    if (pickedImage == null){
      // no photo was taken
      return;
    }

    setState(() {
      _imageFile = File(pickedImage.path);
      pictureTaken = true;
    });

  }

  Widget photoCameraSection(){
    if (_imageFile != null){
      // Show Picture
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Container(
            child: Image.file(_imageFile!),
          ),
        ),
      );
    }

    // Show camera button
    return Center(
      child: ElevatedButton(
        onPressed: getImage,
        child: const Icon(Icons.camera_alt),
      ),
    );

  }


  Widget detailsSection(){
    if(pictureTaken){
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ElevatedButton(onPressed: getImage, child: Text("Retake Photo")),
          ElevatedButton(
            onPressed: (){
              Navigator.push(context, MaterialPageRoute(builder: (builder) => ProductUploadPage(imageFile: _imageFile!)));
            },
            child: Text("Continue")
          ),
        ],
      );
    }
    return Container();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("CameraPage"),
      ),
      body: Column(
        children: [
          Expanded(child: photoCameraSection()),
          detailsSection()
        ],
      ),
    );
  }

}