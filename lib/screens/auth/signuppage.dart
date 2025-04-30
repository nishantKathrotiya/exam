import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:miniproject/main.dart';
import 'package:miniproject/screens/auth/uihelper.dart';

class Signuppage extends StatefulWidget {
  const Signuppage({super.key});

  @override
  State<Signuppage> createState() => _SignuppageState();
}

class _SignuppageState extends State<Signuppage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  signUp(String email, String password) async {
    if (email.isEmpty || password.isEmpty) {
      Uihelper.CustomAlertBox(context, 'Please fill all fields');
    } else {
      // Perform signup operation here
      UserCredential? userCredential;
      try {
        userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(email: email, password: password).then((value) {
              Navigator.push(context, MaterialPageRoute(builder: (context) => HomeScreen()));
            } );
      } on FirebaseAuthException catch (e) {
        return Uihelper.CustomAlertBox(context, e.code.toString());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Signup'), backgroundColor: Colors.blue),
      body: Column(
        children: [
          Uihelper.CustomTextField(emailController, 'Email', Icons.mail, false),
          Uihelper.CustomTextField(
            passwordController,
            'Password',
            Icons.lock,
            true,
          ),
          SizedBox(height: 20),
          Uihelper.Custombutton(() {
            signUp(emailController.text.toString(), passwordController.text.toString());
          }, 'Signup'),
        ],
      ),
    );
  }
}