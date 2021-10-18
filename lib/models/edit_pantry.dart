import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pantree/pantreeUser.dart';
import 'package:flutter/services.dart';

class EditPantry extends StatefulWidget {
  final PantreeUser user;
  final DocumentReference pantry;
  bool makePrimary;
  EditPantry({this.user, this.pantry, this.makePrimary});

  @override
  _EditPantryState createState() => _EditPantryState(user: user, pantry: pantry, makePrimary: makePrimary);
}

class _EditPantryState extends State<EditPantry> {
  final PantreeUser user;
  final DocumentReference pantry;
  bool makePrimary;
  _EditPantryState({this.user, this.pantry, this.makePrimary});

  final TextEditingController _pantryNameTextController = TextEditingController();
  final GlobalKey<FormState> _form = GlobalKey<FormState>();

  // @override
  // void dispose() {
  //   _PantryNameTextController.dispose();
  //   super.dispose(); // NewPantry needs to be Stateful*** for this to properly dispose
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Edit Pantry"),
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
            CheckboxListTile(
              title: Text("Make Primary Pantry"),
              checkColor: Colors.white,
              selectedTileColor: Color.fromRGBO(255, 190, 50, 1.0),
              value: makePrimary,
              onChanged: (bool value) {
                setState(() {
                  makePrimary = value;
                });
              },
            ),
            SizedBox(height: 10),
            TextButton(
              style: TextButton.styleFrom(backgroundColor: Colors.blue),
              onPressed: () {
                String title = "Failed!";
                String message = "Pantry Edit Failed Try again!";
                if (_form.currentState.validate()) {
                  if (editPantry(_pantryNameTextController.text, makePrimary)) {
                    title = "Success!";
                    message =
                        "Pantry Edit was Successful Return to your Pantries!";
                  }
                }
                showAlertDialog(context, title, message);
              },
              child: Text(
                'Save Changes',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ])),
    );
  }

  bool editPantry(String name, bool makePrimary) {
    try {
      if (makePrimary) {
        FirebaseFirestore.instance.collection("users").doc(user.uid).update({
          'PPID': FieldValue.arrayUnion([pantry]),
        });
      }
      FirebaseFirestore.instance.collection("pantries").doc(pantry.id).update({
        "Name": name,
      });
    }
    catch (e) {return false;}

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
