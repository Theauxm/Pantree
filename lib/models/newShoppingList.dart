import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pantree/pantreeUser.dart';
import 'dialogs.dart';

class NewShoppingList extends StatelessWidget {
  PantreeUser user;
  final TextEditingController _ListName = TextEditingController();
  final GlobalKey<FormState> _form = GlobalKey<FormState>();

  NewShoppingList({this.user});

  final GlobalKey<State> _keyLoader = new GlobalKey<State>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Create new Shopping list"),
      ),
      body: Form(
          key: _form,
          child: Column(children: <Widget>[
            TextFormField(
                controller: _ListName,
                validator: (validator) {
                  if (validator.isEmpty) return 'Empty';
                  return null;
                },
                decoration: InputDecoration(
                  labelText: "Shopping List Name",
                  border: OutlineInputBorder(),
                )),
            SizedBox(height: 10),
            TextButton(
              style: TextButton.styleFrom(backgroundColor: Colors.blue),
              onPressed: () {
                _handleSubmit(context, _ListName.text);
              },
              child: Text(
                'Create Shopping List!',
                style: TextStyle(fontSize: 14, color: Colors.black),
              ),
            ),
          ])),
    );
  }

  Future<void> _handleSubmit(BuildContext context, name) async {
    try {
      Dialogs.showLoadingDialog(context, _keyLoader);
      bool b = await createShoppingList(name);
      Navigator.of(_keyLoader.currentContext,rootNavigator: true).pop();
      if (b) {
        Dialogs.showDialogCreatePL(context, "Success",
            "Pantry Creation was Successful Return to your Shopping Lists!","Return to Shopping Lists");
      } else{
        Dialogs.showDialogCreatePL(context, "Failed",
            "Something went wrong! Try again later!","Return to Shopping Lists");
      }
      //Navigator.pushReplacementNamed(context, "/home");
    } catch (error) {
      print(error);
    }
  }

  Future<bool> createShoppingList(name) async{
    try {
      await FirebaseFirestore.instance.collection("shopping_lists").add({
        "Name": name,
        "Owner": FirebaseFirestore.instance.collection("users").doc(user.uid),
      }).then((value) {
        FirebaseFirestore.instance.collection("users").doc(user.uid).update({
          'ShoppingIDs': FieldValue.arrayUnion([value]),
        });
      });
    } catch (e) {
      return false;
    }
    return true;
  }

}