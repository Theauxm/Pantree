import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'home.dart';
import 'package:firebase_auth_ui/firebase_auth_ui.dart';
import 'package:firebase_auth_ui/providers.dart';

import 'package:firebase_core/firebase_core.dart';

class WelcomePage extends StatefulWidget {


  @override
  _WelcomePage createState() => _WelcomePage();
}

class _WelcomePage extends State<WelcomePage> {

  TextEditingController textControllerEmail = TextEditingController();
  TextEditingController textControllerPassword = TextEditingController();

  void signIn() {
    try {
      FirebaseAuth.instance.signInWithEmailAndPassword(
          email: textControllerEmail.text,
          password: textControllerPassword.text
        // email: "treyjlavery@gmail.com",
        // password: "password"
      );
    } catch (e) {
      if (e.code == 'firebase_auth/user-not-found') {
        print('No user found for that email.');
      } else if (e.code == 'firebase_auth/wrong-password') {
        print('Wrong password provided for that user.');
      }
    }
  }

    @override
    Widget build(BuildContext context) {
      return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            title: Text("Welcome!"),
          ),
          body: SingleChildScrollView(
            child: Center(
              child: Column(
                  children: [
                    Image.asset('assets/images/prototype_logo.png'),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Container(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextField(
                                controller: textControllerEmail,
                                decoration: InputDecoration(
                                  labelText: "Email",
                                  border: OutlineInputBorder(
                                  ),)),
                            SizedBox(height: 10),
                            TextField(
                                controller: textControllerPassword,
                                obscureText: true,
                                decoration: InputDecoration(
                                  labelText: "Password",
                                  border: OutlineInputBorder(
                                  ),)),
                            SizedBox(height: 10),
                            Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Flexible(
                                  flex: 1,
                                  child: Container(
                                    width: double.maxFinite,
                                    child: TextButton(
                                      style: TextButton.styleFrom(
                                          backgroundColor: Colors.blue),
                                      onPressed: () {
                                        signIn();
                                      },
                                      child: Text(
                                        'Log in',
                                        style: TextStyle(
                                            fontSize: 14, color: Colors.black),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 10),
                                Flexible(
                                  flex: 1,
                                  child: Container(
                                    width: double.maxFinite,
                                    child: TextButton(
                                      style: TextButton.styleFrom(
                                          backgroundColor: Colors.blue),
                                      onPressed: () {
                                        _navigateToNextScreen(context);
                                      },
                                      child: Text(
                                        'Sign up',
                                        style: TextStyle(
                                            fontSize: 14, color: Colors.black),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            //Center(child: GoogleButton()),
                          ],
                        ),
                      ),
                    ),
                    // TextField(decoration: InputDecoration(
                    //   labelText:"Email"
                    // )),
                    // Text('Password'),
                    // TextField(decoration: InputDecoration(
                    //     labelText:"password"
                    // )),
                  ]
              ),
            ),
          ));
    }
  void _navigateToNextScreen(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => CreateAccount()));
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
      await FirebaseFirestore.instance.collection('users').doc(docID)
          .get()
          .then((doc) {
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



/*
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
 */


class CreateAccount extends StatefulWidget {

  @override
  State<StatefulWidget> createState() => _CreateAccount();
}

class _CreateAccount extends State<CreateAccount> {
  TextEditingController textControllerEmail = TextEditingController();
  TextEditingController textControllerPassword = TextEditingController();
  TextEditingController textControllerUsername = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
        appBar: AppBar(title: Text('New User!')),
        body: SingleChildScrollView(
          child: Center(
            child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextField(
                              controller: textControllerUsername,
                              decoration: InputDecoration(
                                labelText: "User Name",
                                border: OutlineInputBorder(
                                ),)),
                          SizedBox(height: 10),
                          TextField(
                              controller: textControllerEmail,
                              decoration: InputDecoration(
                                labelText: "Email",
                                border: OutlineInputBorder(
                                ),)),
                          SizedBox(height: 10),
                          TextField(
                            controller: textControllerPassword,
                              obscureText: true,
                              decoration: InputDecoration(
                                labelText: "Password",
                                border: OutlineInputBorder(
                                ),)),
                          SizedBox(height: 10),
                          Flexible(
                            flex: 1,
                            child: Container(
                              width: double.maxFinite,
                              child: TextButton(
                                style: TextButton.styleFrom(
                                    backgroundColor: Colors.blue),
                                onPressed: () {
                                  registerUser();
                                  Navigator.of(context).pop();
                                },
                                child: Text(
                                  'Create Account',
                                  style: TextStyle(
                                      fontSize: 14, color: Colors.black),
                                ),
                              ),
                            ),
                          ),
                            ],
                          ),
                          //Center(child: GoogleButton()),
                      ),
                    ),
                ]
            ),
          ),
        ));
  }

  void registerUser() async{
    print("hereo");
    try {
      var result = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: textControllerEmail.text,
          password: textControllerPassword.text
        // email: "treyjlavery@gmail.com",
        // password: "password"
      );
      var uid = result.user.uid;
      result.user.updateProfile(displayName: textControllerUsername.text);
      await FirebaseAuth.instance.signOut();
      await handleNewUsers(uid, textControllerUsername.text);


    } catch (e) {
      if (e.code == 'firebase_auth/user-not-found') {
        print('No user found for that email.');
      } else if (e.code == 'firebase_auth/wrong-password') {
        print('Wrong password provided for that user.');
      }
    }
  }
}