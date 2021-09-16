import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

class WelcomePage extends StatefulWidget {


  @override
  _WelcomePage createState() => _WelcomePage();
}

class _WelcomePage extends State<WelcomePage> {

  TextEditingController textControllerEmail = TextEditingController();
  TextEditingController textControllerPassword = TextEditingController();

  void signIn() async{
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: textControllerEmail.text,
          password: textControllerPassword.text
        // email: "treyjlavery@gmail.com",
        // password: "password"
      );

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(getMessageFromErrorCode(e)),
          duration: const Duration(seconds: 10),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

    @override
    Widget build(BuildContext context) {
      return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            title: Text("Welcome!"),
          ),
          body:Builder(
          builder: (context) =>
          SingleChildScrollView(
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
                  ]
              ),
            ),
          )));
    }
  void _navigateToNextScreen(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => CreateAccount()));
  }

  }



  Future<void> handleNewUsers(String docID, String displayName) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(docID)
          .get()
          .then((doc) {
        if (!doc.exists)
          FirebaseFirestore.instance.collection('users').doc(docID).set({
            'Username': displayName,
            'PantryIDs': [null],
            'FriendIDs': [null],
            'RecipeIDs': [null],
            'ShoppingIDs': [null],
            'PostsIDs': [null],
            'PPID': null,
            'PSID': null,
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
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
        appBar: AppBar(title: Text('New User!')),
        body: SingleChildScrollView(
          child: Center(
            child: Column(
                children: [
                  SizedBox(height: 20),
                  Text("Create your Pantree Account",
                  style: TextStyle(fontSize:25)),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CreateAccountForm(),

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
}

class CreateAccountForm extends StatefulWidget {
  @override
  _CreateAccountFormState createState() => _CreateAccountFormState();
}

class _CreateAccountFormState extends State<CreateAccountForm> {
  final TextEditingController _Email = TextEditingController();
  final TextEditingController _Password = TextEditingController();
  final TextEditingController _Username = TextEditingController();
  final TextEditingController _PasswordConfirm = TextEditingController();
  final GlobalKey<FormState> _form = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(30),
      child: Form(
          key: _form,
          child: Column(children: <Widget>[

            TextFormField(
                controller: _Username,
                validator: (validator) {
                  if (validator.isEmpty) return 'Empty';
                  return null;
                },
                decoration: InputDecoration(
                  labelText: "User Name",
                  border: OutlineInputBorder(),
                )),
            SizedBox(height: 10),
            TextFormField(
                controller: _Email,
                validator: (validator) {
                  if (validator.isEmpty) return 'Empty';
                  if (RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(validator)) return null;
                  return "Invalid Email Address";
                },
                decoration: InputDecoration(
                  labelText: "Email",
                  border: OutlineInputBorder(),
                )),
            SizedBox(height: 10),
            TextFormField(
                controller: _Password,
                validator: (validator) {
                  if (validator.isEmpty) return 'Empty';
                  return null;
                },
                obscureText: false,
                decoration: InputDecoration(
                  labelText: "Password",
                  border: OutlineInputBorder(),
                )),
           SizedBox(height: 10),
            TextFormField(
                controller: _PasswordConfirm,
              validator: (validator) {
                if (validator.isEmpty) return 'Empty';
                if (validator != _Password.text) return 'The Passwords do not match!';
                return null;
              },
                obscureText: false,
                decoration: InputDecoration(
                  labelText: "Confirm Password",
                  border: OutlineInputBorder(),
                ),),
            SizedBox(height: 10),
            TextButton(
                  style: TextButton.styleFrom(
                      backgroundColor: Colors.blue),
                  onPressed: () async{
                    if(_form.currentState.validate()) {
                      var m = await registerUser();
                      if (m == null) {
                        showAlertDialog(context, "Account Created!","return to login page!");
                      } else {
                        showAlertDialog(context, "Account Creation Failed",m);
                      }
                    }
                    },
                  child: Text(
                    'Create Account',
                    style: TextStyle(
                        fontSize: 14, color: Colors.black),
                  ),
                ),
          ])),
    );
  }

  Future<String> registerUser() async{
    var m;
    try {
      FirebaseApp app = await Firebase.initializeApp(
          name: 'Secondary', options: Firebase.app().options);
      try {
        UserCredential userCredential = await FirebaseAuth.instanceFor(app: app)
            .createUserWithEmailAndPassword(email: _Email.text, password: _Password.text);
        await FirebaseAuth.instanceFor(app: app)
            .currentUser.updateDisplayName(_Username.text);
        await handleNewUsers(userCredential.user.uid, _Username.text);
      }
      on FirebaseAuthException catch (e) {
        String error = getMessageFromErrorCode(e);
        m = error;
      }
      await app.delete();
    } catch (e) {
      return getMessageFromErrorCode(e);
    }
    return m;
  }
}

String getMessageFromErrorCode(e) {
  switch (e.code) {
    case "ERROR_EMAIL_ALREADY_IN_USE":
    case "account-exists-with-different-credential":
    case "email-already-in-use":
      return "Email already used. Go to login page.";
      break;
    case "ERROR_WRONG_PASSWORD":
    case "wrong-password":
      return "Wrong email/password combination.";
      break;
    case "ERROR_USER_NOT_FOUND":
    case "user-not-found":
      return "No user found with this email.";
      break;
    case "ERROR_USER_DISABLED":
    case "user-disabled":
      return "User disabled.";
      break;
    case "ERROR_TOO_MANY_REQUESTS":
    case "operation-not-allowed":
      return "Too many requests to log into this account.";
      break;
    case "ERROR_OPERATION_NOT_ALLOWED":
    case "operation-not-allowed":
      return "Server error, please try again later.";
      break;
    case "ERROR_INVALID_EMAIL":
    case "invalid-email":
      return "Email address is invalid.";
      break;
    case "auth/invalid-password"  :
      return "Password Too Short";
    default:
      return "Failed. Please try again.";
      break;
  }
}

showAlertDialog(BuildContext context, String t,String m) async{

  // set up the button
  Widget signButton = TextButton(
    child: Text("Return"),
    onPressed: () {
      Navigator.of(context).pop();
      Navigator.of(context).pop();
    },
  );

  Widget okButton = TextButton(
    child: Text("OK"),
    onPressed: () {Navigator.of(context).pop(true);},
  );
  var a;
  // set up the AlertDialog
  if(t != "Account Created!"){
    a= [
      okButton
    ];
  }else{
    a = [
      signButton
    ];
  }
  AlertDialog alert = AlertDialog(
    title: Text(t),
    content: Text(m),
    actions:a
  );

  // show the dialog
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}
