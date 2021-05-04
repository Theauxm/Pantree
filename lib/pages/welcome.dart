import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'home.dart';
import 'package:firebase_auth_ui/firebase_auth_ui.dart';
import 'package:firebase_auth_ui/providers.dart';

import 'package:firebase_core/firebase_core.dart';

class WelcomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Welcome!"),
      ),
      body: Center(
        child: Column(
          children: [
            Image.asset('assets/images/prototype_logo.png'),
            ElevatedButton(
              onPressed: () {
                // Navigate back to first route when tapped.
                FirebaseAuthUi.instance()
                    .launchAuth(
                  [
                    AuthProvider.email(), // Login/Sign up with Email and password
                    // AuthProvider.google(), // Login with Google
                    // AuthProvider.facebook(), // Login with Facebook
                    // AuthProvider.twitter(), // Login with Twitter
                    // AuthProvider.phone(), // Login with Phone number
                  ],
                  // tosUrl: "https://my-terms-url", // Optional
                  // privacyPolicyUrl: "https://my-privacy-policy", // Optional,
                )
                    .then((firebaseUser) =>
                //print("Logged in user is ${firebaseUser.displayName}"))
                handleNewUsers(firebaseUser.uid, firebaseUser.displayName)
                    .catchError((error) => print("Error $error")));
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Home(title: 'Pantree Home')));
              },
              style: ElevatedButton.styleFrom(
                primary: Colors.amber[800],
                onPrimary: Colors.white,
              ),
              child: Text('Sign in'),
          ),]
        ),
      ),
    );
  }

  // onPressed: () {
  // Navigator.pop(context);
  // }
}

Future<void> handleNewUsers(String docID, String displayName) async {
  try {
    // Get reference to Firestore collection
    //var collectionRef = FirebaseFirestore.instance.collection('users');

    //var doc = await collectionRef.doc(docID).get();
    await FirebaseFirestore.instance.collection('users').doc(docID).get().then((doc) {
      if (!doc.exists)
        FirebaseFirestore.instance.collection('users').doc(docID).set({
          'Username': displayName,
          'Pantry IDs': [null],
          'Friend IDs': [null],
          'Recipe IDs': [null],
          'Shopping IDs': [null],
        });
    });
  } catch (e) {
    throw e;
  }
}