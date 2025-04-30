import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:miniproject/main.dart';
import 'package:miniproject/screens/auth/showdata.dart';
import 'package:miniproject/screens/auth/signuppage.dart';
import 'package:miniproject/screens/auth/uihelper.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  login(String email, String password) async {
    if (email.isEmpty || password.isEmpty) {
      Uihelper.CustomAlertBox(context, 'Please fill all fields');
      return;
    }
    UserCredential? userCredential;
    try {
      userCredential=await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password).then((value){
            Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => HomeScreen()));
          });
      
    } on FirebaseAuthException catch (e) {
      Uihelper.CustomAlertBox(context, e.code.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login Page'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Uihelper.CustomTextField(emailController, 'Email', Icons.email, false),
            Uihelper.CustomTextField(passwordController, 'Password', Icons.lock, true),
            const SizedBox(height: 20),
            Uihelper.Custombutton(() {
              login(emailController.text.trim(), passwordController.text.trim());
            }, "Login"),
            TextButton(
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => Signuppage()));
              },
              child: const Text("Don't have an account? Sign Up"),
            ),
            SizedBox(height: 20,),
            ElevatedButton(onPressed: (){
              Navigator.push(context, MaterialPageRoute(builder: (context) => Forgetpassword()));
            }, child: Text("Forget Password")),
            
          ],
        ),
      ),
    );
  }
}