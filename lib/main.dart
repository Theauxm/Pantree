import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pantree/pages/welcome.dart';
import 'pages/home.dart';
import 'package:firebase_auth_ui/firebase_auth_ui.dart';
import 'package:firebase_auth_ui/providers.dart';

import 'package:firebase_core/firebase_core.dart';

// void main() {
//   //await Firsebase.initializedApp();
//   runApp(MyApp());
// }

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Pantree',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      //home: Home(title: 'Pantree Home'), // alt title: myPantree
      home: Home(),
    );
  }

  static Future<bool> _checkExists(String docID) async {
    bool exists = false;
    try {
      await FirebaseFirestore.instance.doc("users/$docID").get().then((doc) {
        if (doc.exists)
          exists = true;
        else
          exists = false;
      });
      return exists;
    } catch (e) {
      return false;
    }
  }

}
