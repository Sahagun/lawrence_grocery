import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lawrence/register_page.dart';

import 'home_page.dart';
import 'stores/dashboard_page.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();

}

class _LoginPageState extends State<LoginPage> {

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final emailTextFieldController = TextEditingController();
  final passwordTextFieldController = TextEditingController();

  bool submitLock = false;


  void showSnackBar(String message){
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message))
    );
  }

  void onPressedRegisterButton(){
    Navigator.push(
      context,
      MaterialPageRoute(builder: (BuildContext context) => RegisterPage())
    );
  }

  void onPressedLoginButton() async{
    if(submitLock){
      return;
    }
    submitLock = true;

    try{
      String email = emailTextFieldController.text;
      String password = passwordTextFieldController.text;
      await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);

      showSnackBar('Login Successful.');

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => Dashboard()),
            (route) => false,
      );

    }
    on FirebaseAuthException catch (e) {
      if(e.code == 'user-not-found'){
        showSnackBar('Error: No user found for that email.');
      }
      else if(e.code == 'wrong-password'){
        showSnackBar('Error: Wrong password provided for that email.');
      }
      else{
        showSnackBar('Unknown Error.');
      }
    }

    submitLock = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [

                // Title Text
                const Text(
                  'Inventourious',
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                // Email Field
                TextFormField(
                  controller: emailTextFieldController,
                  decoration: const InputDecoration(
                    labelText: "Email",
                    hintText: 'username@example.com',
                  ),
                ),

                // Password Field
                TextFormField(
                  controller: passwordTextFieldController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: "Password",
                    hintText: 'password',
                  ),
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(onPressed: onPressedLoginButton, child: const Text('Login')),
                    ElevatedButton(onPressed: onPressedRegisterButton, child: const Text('Register')),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}