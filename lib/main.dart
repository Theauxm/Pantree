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

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}


class MyApp extends StatelessWidget {

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {

    // FirebaseAuthUi.instance()
    //     .launchAuth(
    //   [
    //     AuthProvider.email(), // Login/Sign up with Email and password
    //     // AuthProvider.google(), // Login with Google
    //     // AuthProvider.facebook(), // Login with Facebook
    //     // AuthProvider.twitter(), // Login with Twitter
    //     // AuthProvider.phone(), // Login with Phone number
    //   ],
    //   // tosUrl: "https://my-terms-url", // Optional
    //   // privacyPolicyUrl: "https://my-privacy-policy", // Optional,
    // )
    // .then((firebaseUser) =>
    // //print("Logged in user is ${firebaseUser.displayName}"))
    // handleNewUsers(firebaseUser.uid, firebaseUser.displayName)
    // .catchError((error) => print("Error $error")));

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Pantree',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
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

/// Check If Document Exists
Future<void> handleNewUsers(String docID, String displayName) async {
  print("HANDLENEWUSERS REACHED");
  try {
    // Get reference to Firestore collection
    var collectionRef = FirebaseFirestore.instance.collection('users');

    //var doc = await collectionRef.doc(docID).get();
    await FirebaseFirestore.instance.collection('users').doc(docID).get().then((doc) {
      if (!doc.exists)
        FirebaseFirestore.instance.collection('users').doc(docID).set({'Username': displayName});
    });
    // add new users to 'users' document
/*      if (!doc.exists) {
        FirebaseFirestore.instance.collection('users').doc(docID).set({'Username': FirebaseAuth.instance.currentUser.displayName});
      }*/
  } catch (e) {
    throw e;
  }
}
