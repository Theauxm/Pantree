import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class WelcomePage extends StatefulWidget {
  @override
  _WelcomePage createState() => _WelcomePage();
}

class _WelcomePage extends State<WelcomePage> {
  TextEditingController textControllerEmail = TextEditingController();
  TextEditingController textControllerPassword = TextEditingController();

  void signIn() async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: textControllerEmail.text, password: textControllerPassword.text
          // email: "treyjlavery@gmail.com",
          // password: "password"
          );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(getMessageFromErrorCode(e)),
          duration: const Duration(seconds: 4),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  FocusNode email;
  FocusNode password;
  FocusNode signInButton;

  @override
  void initState() {
    super.initState(); // start initState() with this
    email = FocusNode();
    password = FocusNode();
    signInButton = FocusNode();
  }

  @override
  void dispose() {
    email.dispose();
    password.dispose();
    signInButton.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        // appBar: AppBar(
        //title: Text("Welcome!"),
        // ),
        body: Builder(
            builder: (context) => SingleChildScrollView(
                  child: Center(
                    child: Column(children: [
                      Padding(
                        padding: const EdgeInsets.all(30.0),
                      ),
                      Image.asset('assets/images/pantree.png'),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Container(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              TextFormField(
                                  autofocus: true,
                                  focusNode: email,
                                  controller: textControllerEmail,
                                  decoration: InputDecoration(
                                    labelText: "Email",
                                    border: OutlineInputBorder(),
                                  ),
                                  onFieldSubmitted: (term) {
                                    email.unfocus();
                                    FocusScope.of(context)
                                        .requestFocus(password);
                                  }),
                              SizedBox(height: 10),
                              TextFormField(
                                  focusNode: password,
                                  controller: textControllerPassword,
                                  obscureText: true,
                                  decoration: InputDecoration(
                                    labelText: "Password",
                                    border: OutlineInputBorder(),
                                  ),
                                  onFieldSubmitted: (term) {
                                    password.unfocus();
                                    FocusScope.of(context)
                                        .requestFocus(signInButton);
                                  }),
                              SizedBox(height: 10),
                              Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  Flexible(
                                      flex: 1,
                                      child: Container(
                                          width: double.maxFinite,
                                          child: ElevatedButton(
                                            focusNode: signInButton,
                                            style: ElevatedButton.styleFrom(
                                                primary: Colors.lightBlue,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 25,
                                                        vertical: 10),
                                                textStyle: const TextStyle(
                                                    fontSize: 18,
                                                    fontWeight:
                                                        FontWeight.bold)),
                                            onPressed: () {
                                              signIn();
                                            },
                                            child: const Text("Log in"),
                                          ))),
                                  SizedBox(width: 10),
                                  Flexible(
                                      flex: 1,
                                      child: Container(
                                          width: double.maxFinite,
                                          child: ElevatedButton(
                                            focusNode: signInButton,
                                            style: ElevatedButton.styleFrom(
                                                primary: Colors.lightBlue,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 25,
                                                        vertical: 10),
                                                textStyle: const TextStyle(
                                                    fontSize: 18,
                                                    fontWeight:
                                                        FontWeight.bold)),
                                            onPressed: () {
                                              _navigateToNextScreen(context);
                                            },
                                            child: const Text("Sign up"),
                                          ))),
                                ],
                              ),
                              //Center(child: GoogleButton()),
                            ],
                          ),
                        ),
                      ),
                    ]),
                  ),
                )));
  }

  void _navigateToNextScreen(BuildContext context) {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => CreateAccount()));
  }
}

Future<void> handleNewUsers(String docID, String displayName) async {
  try {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(docID)
        .get()
        .then((doc) {
      if (!doc.exists) {
        FirebaseFirestore.instance.collection('users').doc(docID).set({
          'Username': displayName,
          'PantryIDs': [],
          'Friends': 0,
          'PendingFriends': 0,
          'RecipeIDs': [],
          'ShoppingIDs': [],
          'PostIDs': [],
          'PPID': null,
          'PSID': null,
        });
      }
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
    return Scaffold(
        appBar: AppBar(title: Text('Sign Up')),
        body: SingleChildScrollView(
          child: Center(
            child: Column(children: [
              SizedBox(height: 20),
              Text("Create your Pantree account",
                  style: TextStyle(fontSize: 25)),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CreateAccountForm(),
                  ],
                ),
              ),
            ]),
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

  FocusNode userName;
  FocusNode email;
  FocusNode password;
  FocusNode confirmPassword;
  FocusNode submit;

  bool nameTaken;

  @override
  void initState() {
    super.initState(); // start initState() with this
    userName = FocusNode();
    email = FocusNode();
    password = FocusNode();
    confirmPassword = FocusNode();
    submit = FocusNode();
  }

  @override
  void dispose() {
    userName.dispose();
    email.dispose();
    password.dispose();
    confirmPassword.dispose();
    submit.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(30),
      child: Form(
          key: _form,
          child: Column(children: <Widget>[
            TextFormField(
              autofocus: true,
              focusNode: userName,
              controller: _Username,
              validator: (validator) {
                if (validator.isEmpty) return 'Empty';
                if (!RegExp(r"^\S*$").hasMatch(validator))
                  return "No Spaces Allowed";
                if (!nameTaken) return 'Username Taken';
                return null;
              },
              decoration: InputDecoration(
                labelText: "User Name",
                border: OutlineInputBorder(),
              ),
              onFieldSubmitted: (term) {
                userName.unfocus();
                FocusScope.of(context).requestFocus(email);
              },
            ),
            SizedBox(height: 10),
            TextFormField(
              focusNode: email,
              controller: _Email,
              validator: (validator) {
                if (validator.isEmpty) return 'Empty';
                if (RegExp(
                        r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                    .hasMatch(validator)) return null;
                return "Invalid Email Address";
              },
              decoration: InputDecoration(
                labelText: "Email",
                border: OutlineInputBorder(),
              ),
              onFieldSubmitted: (term) {
                email.unfocus();
                FocusScope.of(context).requestFocus(password);
              },
            ),
            SizedBox(height: 10),
            TextFormField(
              focusNode: password,
              controller: _Password,
              validator: (validator) {
                if (validator.isEmpty) return 'Empty';
                return null;
              },
              obscureText: true,
              decoration: InputDecoration(
                labelText: "Password",
                border: OutlineInputBorder(),
              ),
              onFieldSubmitted: (term) {
                password.unfocus();
                FocusScope.of(context).requestFocus(confirmPassword);
              },
            ),
            SizedBox(height: 10),
            TextFormField(
              focusNode: confirmPassword,
              controller: _PasswordConfirm,
              validator: (validator) {
                if (validator.isEmpty) return 'Empty';
                if (validator != _Password.text)
                  return 'The Passwords do not match!';
                return null;
              },
              obscureText: true,
              decoration: InputDecoration(
                labelText: "Confirm Password",
                border: OutlineInputBorder(),
              ),
              onFieldSubmitted: (term) {
                confirmPassword.unfocus();
                FocusScope.of(context).requestFocus(submit);
              },
            ),
            SizedBox(height: 10),
            ElevatedButton(
              focusNode: submit,
              style: ElevatedButton.styleFrom(
                  primary: Colors.lightBlue,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
                  textStyle: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
              onPressed: () async {
                bool b = await _checkName(_Username.text);
                nameTaken = b;
                if (_form.currentState.validate()) {
                  var m = await registerUser();
                  if (m == null) {
                    Navigator.of(context).pop();
                  } else {
                    showAlertDialog(context, "Account Creation Failed", m);
                  }
                }
              },
              child: const Text("Create Account"),
            ),
          ])),
    );
  }

  Future<bool> _checkName(name) async {
    QuerySnapshot users = await FirebaseFirestore.instance
        .collection('users')
        .where('Username', isEqualTo: name)
        .get();
    if (users.docs.isEmpty) return true;
    return false;
  }

  Future<String> registerUser() async {
    var m;
    try {
      // FirebaseApp app = await Firebase.initializeApp(
      //     name: 'Secondary', options: Firebase.app().options);
      try {
        await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
                email: _Email.text, password: _Password.text)
            .then((value) => {handleNewUsers(value.user.uid, _Username.text)});
      } on FirebaseAuthException catch (e) {
        String error = getMessageFromErrorCode(e);
        m = error;
      }
      //await app.delete();
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
    case "auth/invalid-password":
      return "Password Too Short";
    default:
      return "Failed. Please try again.";
      break;
  }
}

showAlertDialog(BuildContext context, String t, String m) async {
  // set up the button
  Widget signButton = TextButton(
    child: Text("OK"),
    onPressed: () {
      Navigator.of(context).pop();
      Navigator.of(context).pop();
    },
  );

  Widget okButton = TextButton(
    child: Text("OK"),
    onPressed: () {
      Navigator.of(context).pop(true);
    },
  );
  var a;
  // set up the AlertDialog
  if (t != "Account Created!") {
    a = [okButton];
  } else {
    a = [signButton];
  }
  AlertDialog alert = AlertDialog(title: Text(t), content: Text(m), actions: a);

  // show the dialog
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}
