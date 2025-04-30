
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:miniproject/screens/auth/uihelper.dart';

class Forgetpassword extends StatefulWidget {
  const Forgetpassword({super.key});

  @override
  State<Forgetpassword> createState() => _ForgetpasswordState();
}

class _ForgetpasswordState extends State<Forgetpassword> {
  TextEditingController emailController = TextEditingController();

  forgetpassword(String email)async{
    if(email.isEmpty){
      Uihelper.CustomAlertBox(context, 'Please fill all fields');
    }else{
      try {
        await FirebaseAuth.instance.sendPasswordResetEmail(email: email).then((value) {
          Uihelper.CustomAlertBox(context, 'Password reset email sent');
        });
      } on FirebaseAuthException catch (e) {
        Uihelper.CustomAlertBox(context, e.code.toString());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Forget Password'),
        backgroundColor: Colors.blue,
      ),
      body:Column(
        children: [
          Uihelper.CustomTextField(emailController, 'Email', Icons.mail, false),
          SizedBox(height: 20),
          Uihelper.Custombutton(() {
            // Call the function to send password reset email
            forgetpassword(emailController.text.toString());
          }, 'Send Password Reset Email'),
        ],
      ),
    );
  }
}