import 'package:flutter/material.dart';
import 'package:miniproject/firebaseoptions.dart';

import 'history_screen.dart';
import 'search_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:miniproject/screens/auth/login.dart';
import 'package:miniproject/screens/invoice/invoiceGenrator.dart';

void main() async{
   WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform,);
  runApp(const AIImageGeneratorApp());
}

class AIImageGeneratorApp extends StatelessWidget {
  const AIImageGeneratorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Invoice Genrator',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const LoginPage(),
    );
  }
}


class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Invoice genarator Generator")),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Text(
                "AI Image Generator",
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.image),
              title: const Text("Generate invoice"),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const gstCalculator()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.history),
              title: const Text("View History"),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const HistoryScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.search),
              title: const Text("Search Image"),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const SearchScreen()));
              },
            ),
          ],
        ),
      ),
      body: const Center(
        child: Text(
          "Welcome! Use the Drawer to Navigate.",
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
