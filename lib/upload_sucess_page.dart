import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lawrence/home_page.dart';

class UploadSuccessPage extends StatefulWidget{

  @override
  _UploadSuccessPageState createState() => _UploadSuccessPageState();

}

class _UploadSuccessPageState extends State<UploadSuccessPage>{

  @override
  void initState(){
    super.initState();
    Timer(
      const Duration(seconds: 3),
      (){
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (builder)=>HomePage()),
          (route) => false
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          "Upload Successful!"
        ),
      ),
    );
  }

}