import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pantree/pantreeUser.dart';
import 'package:flutter/services.dart';

class NewPantry extends StatelessWidget {
  PantreeUser user;
  final TextEditingController _pantryNameTextController = TextEditingController();
  final GlobalKey<FormState> _form = GlobalKey<FormState>();

  NewPantry({this.user});

  // @override
  // void dispose() {
  //   _PantryNameTextController.dispose();
  //   super.dispose(); // NewPantry needs to be Stateful*** for this to properly dispose
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Create new Pantry"),
      ),
      body: Form(
          key: _form,
          child: Column(children: <Widget>[
            TextFormField(
                controller: _pantryNameTextController,
                validator: (value) {
                  if (value.isEmpty || value == null) {
                    return 'Please enter a name for your pantry';
                  } else if (!RegExp(r"^[a-zA-Z\s\']+$").hasMatch(value)) {
                    return "Name can only contain letters";
                  }
                  return null;
                },
                inputFormatters: [
                  LengthLimitingTextInputFormatter(20),
                ],
                decoration: InputDecoration(
                  labelText: "New Pantry Name",
                  border: OutlineInputBorder(),
                )),
            SizedBox(height: 10),
            TextButton(
              style: TextButton.styleFrom(backgroundColor: Colors.blue),
              onPressed: () {
                String title = "Failed!";
                String message = "Shopping List Creation Failed Try again!";
                if (_form.currentState.validate()) {
                  if (createPantry(_pantryNameTextController.text)) {
                    title = "Success!";
                    message =
                        "Pantry Creation was Successful Return to your Pantries!";
                  }
                }
                showAlertDialog(context, title, message);
              },
              child: Text(
                'Create Pantry!',
                style: TextStyle(fontSize: 14, color: Colors.black),
              ),
            ),
          ])),
    );
  }

  bool createPantry(name) {
    try {
      FirebaseFirestore.instance.collection("pantries").add({
        "Name": name,
        "Owner": FirebaseFirestore.instance.collection("users").doc(user.uid),
      }).then((value) {
        FirebaseFirestore.instance.collection("users").doc(user.uid).update({
          'PantryIDs': FieldValue.arrayUnion([value]),
        });
      });
    } catch (e) {
      return false;
    }
    return true;
  }

  showAlertDialog(BuildContext context, String t, String m) async {
    // set up the button
    Widget signButton = TextButton(
      child: Text("Return to Pantry"),
      onPressed: () {
        Navigator.of(context, rootNavigator: true).pop();
        Navigator.of(context).pop();
      },
    );

    Widget okButton = TextButton(
      child: Text("Stay"),
      onPressed: () {
        Navigator.of(context, rootNavigator: true).pop();
      },
    );
    var a = [signButton, okButton];
    AlertDialog alert =
        AlertDialog(title: Text(t), content: Text(m), actions: a);

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}
