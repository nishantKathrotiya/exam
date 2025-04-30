import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Uihelper {
  static CustomTextField(TextEditingController controller, String text,IconData icon,bool tohide) {
    return TextField(
      controller: controller,
      obscureText: tohide,
      decoration: InputDecoration(
        hintText: text,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        suffixIcon: Icon(icon),
        
      ),
    );

  }

  static Custombutton(VoidCallback VoidCallback,String text){
    return SizedBox(height: 80 ,width: 200, child: ElevatedButton(
      onPressed: (){
        VoidCallback();
        },
      child: Text(text , style: TextStyle(color: Colors.amber,),
    )));
    }

    static CustomAlertBox(BuildContext context, String text) {
      return showDialog(context: context, builder: (BuildContext context) {
        return AlertDialog(
          title: Text(text),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('OK'),
            ),
          ],
        );
      });
    }
  }