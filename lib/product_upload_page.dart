import 'dart:io';

import 'package:flutter/material.dart';
import 'package:lawrence/upload_sucess_page.dart';

class ProductUploadPage extends StatefulWidget{

  final File imageFile;

  const ProductUploadPage({Key? key, required this.imageFile}) : super(key: key);

  @override
  _ProductUploadPageState createState() => _ProductUploadPageState();

}

class _ProductUploadPageState extends State<ProductUploadPage>{

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool submitLock = false;

  final marketTextFieldController = TextEditingController();
  final productnameTextFieldController = TextEditingController();

  void uploadForm() async {
    if(submitLock){
      return;
    }

    submitLock = true;

    if(_formKey.currentState!.validate()){
      Navigator.push(context, MaterialPageRoute(builder: (builder)=>UploadSuccessPage()));
    }

    submitLock = false;
  }

  String? validateField(String? value){
    if(value == null || value.isEmpty){
      return "Please fill this out.";
    }
    return null;

  }

  Widget form(){
    return Expanded(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: productnameTextFieldController,
                  validator: validateField,
                  decoration: const InputDecoration(
                    labelText: "Product Name",
                    hintText: 'e.g. milk, eggs, apples',
                  ),
                ),

                TextFormField(
                  controller: marketTextFieldController,
                  validator: validateField,
                  decoration: const InputDecoration(
                    labelText: "Market Name",
                    hintText: 'e.g. WalMart, Target, Ralphs',
                  ),
                ),


                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Image.file(widget.imageFile),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget body(){
    return Column(
      children: [
        form(),
        Center(
          child: ElevatedButton(onPressed: uploadForm, child: Text("Upload"),),
        )
      ],
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Product Details"),
      ),
      body: body(),
    );
  }

}