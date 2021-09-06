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
    try {

      FirebaseApp app = await Firebase.initializeApp(
          name: 'Secondary', options: Firebase.app().options);
      try {
        UserCredential userCredential = await FirebaseAuth.instanceFor(app: app)
            .createUserWithEmailAndPassword(email: textControllerEmail.text, password: textControllerPassword.text);
        await handleNewUsers(userCredential.user.uid, textControllerUsername.text);
      }
      on FirebaseAuthException catch (e) {
        // Do something with exception. This try/catch is here to make sure
        // that even if the user creation fails, app.delete() runs, if is not,
        // next time Firebase.initializeApp() will fail as the previous one was
        // not deleted.
      }
      await app.delete();
    } catch (e) {
      if (e.code == 'firebase_auth/user-not-found') {
        print('No user found for that email.');
      } else if (e.code == 'firebase_auth/wrong-password') {
        print('Wrong password provided for that user.');
      }
    }
  }
}