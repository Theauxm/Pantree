import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pantree/pantreeUser.dart';
import 'package:pantree/models/dialogs.dart';
class NewPantry extends StatelessWidget {
  PantreeUser user;
  final TextEditingController _PantryName = TextEditingController();
  final GlobalKey<FormState> _form = GlobalKey<FormState>();

  NewPantry({this.user});

  final GlobalKey<State> _keyLoader = new GlobalKey<State>();


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
                controller: _PantryName,
                validator: (validator) {
                  if (validator.isEmpty) return 'Empty';
                  return null;
                },
                decoration: InputDecoration(
                  labelText: "New Pantry Name",
                  border: OutlineInputBorder(),
                )),
            SizedBox(height: 10),
            TextButton(
              style: TextButton.styleFrom(backgroundColor: Colors.blue),
              onPressed: () {
                _handleSubmit(context, _PantryName.text);
              },
              child: Text(
                'Create Pantry!',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ])),
    );
  }

  Future<void> _handleSubmit(BuildContext context, name) async {
    try {
      Dialogs.showLoadingDialog(context, _keyLoader);
      bool b = await createPantry(name);
      Navigator.of(_keyLoader.currentContext,rootNavigator: true).pop();
      if (b) {
        Dialogs.showDialogCreatePL(context, "Success",
            "Pantry Creation was Successful Return to your Pantries!","Return to Pantries");
      } else{
        Dialogs.showDialogCreatePL(context, "Failed",
            "Something went wrong! Try again later!","Return to Pantries");
      }
      //Navigator.pushReplacementNamed(context, "/home");
    } catch (error) {
      print(error);
    }
  }

  Future<bool> createPantry(name) async{
    try {
      await FirebaseFirestore.instance.collection("pantries").add({
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

}
