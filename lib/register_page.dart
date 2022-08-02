import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lawrence/home_page.dart';

class RegisterPage extends StatefulWidget {

  @override
  _RegisterPageState createState() => _RegisterPageState();

}

class _RegisterPageState extends State<RegisterPage> {

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final emailTextFieldController = TextEditingController();
  final passwordTextFieldController = TextEditingController();
  final confirmPasswordTextFieldController = TextEditingController();

  bool submitLock = false;

  String? validateEmail(String? value){
    RegExp emailRegex = RegExp(r'\w+@\w+\.\w+');

    if(value == null || value.isEmpty || !emailRegex.hasMatch(value)){
      return 'Please enter a valid email.';
    }
    return null;
  }


  String? validatePassword(String? value){
    if(value == null || value.isEmpty){
      return 'Please enter a password.';
    }
    else if(value.length < 6 || value.length > 12){
      return 'Your Password need to have at between 6 and 12 characters.';
    }
    return null;
  }


  String? validateConfirmPassword(String? value) {
    if(value == null || value.isEmpty){
      return 'Please enter your password.';
    }
    else if(value != passwordTextFieldController.text){
      return "Your password don't match.";
    }
    return null;
  }


  void showSnackBar(String message){
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message))
    );
  }

  void onPressedRegisterButton() async{
    if(submitLock){
      return;
    }

    submitLock = true;

    if(_formKey.currentState!.validate()){
      try{
        String email = emailTextFieldController.text;
        String password = passwordTextFieldController.text;

        UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: password);
        showSnackBar('Registration successful');

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
          (route) => false,
        );

      }
      on FirebaseAuthException catch(e){
        if(e.code == 'weak-password'){
          showSnackBar('The provided password is too weak');
        }
        else if (e.code == 'email-already-in-use') {
          showSnackBar("That email is already in use.");
        }
        else if (e.code == 'invalidEmail') {
          showSnackBar("The provided email is invalid.");
        }
        else{
          showSnackBar("Unknown Error.");
        }
      }
    }

    submitLock = false;
  }

  Form signUpForm(){
    return Form(
      key: _formKey,
      child: Column(
        children: [

          // Email Field
          TextFormField(
            controller: emailTextFieldController,
            validator: validateEmail,
            decoration: const InputDecoration(
              labelText: "Email",
              hintText: 'username@example.com',
            ),
          ),

          // Password Field
          TextFormField(
            controller: passwordTextFieldController,
            validator: validatePassword,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: "Password",
              hintText: 'password',
            ),
          ),

          // Confirm Password Field
          TextFormField(
            controller: confirmPasswordTextFieldController,
            validator: validateConfirmPassword,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: "Confirm Password",
              hintText: 'password',
            ),
          ),

          ElevatedButton(onPressed: onPressedRegisterButton, child: const Text("Register")),

        ],
      ),
    );
  }


  @override
  Widget build(context){
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign Up'),
      ),
      body: signUpForm(),
    );
  }

}