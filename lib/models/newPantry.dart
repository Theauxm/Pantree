import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pantree/pantreeUser.dart';

class NewPantry extends StatelessWidget {
  PantreeUser user;
  final TextEditingController _PantryName = TextEditingController();
  final GlobalKey<FormState> _form = GlobalKey<FormState>();

  NewPantry({this.user});

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
            style: TextButton.styleFrom(
                backgroundColor: Colors.blue),
            onPressed: (){
              String title = "Failed!";
              String message = "Shopping List Creation Failed Try again!";
              if(_form.currentState.validate()) {
                if(createPantry(_PantryName.text)){
                  title = "Success!";
                  message = "Pantry Creation was Successful Return to your Pantries!";
                }
              }
              showAlertDialog(context, title, message);
            },
            child: Text(
              'Create Pantry!',
              style: TextStyle(
                  fontSize: 14, color: Colors.black),
            ),
          ),
        ])),
    );
  }

bool createPantry(name){
    try {
      FirebaseFirestore.instance.collection("pantries").add(
          {
            "Name": name,
            "Owner": FirebaseFirestore.instance.collection("users").doc(
                user.uid),
          }).then((value) {
        FirebaseFirestore.instance.collection("users").doc(user.uid).update({
          'PantryIDs': FieldValue.arrayUnion([value]),
        });
      });
    } catch (e){
      return false;
    }
  return true;
}

  showAlertDialog(BuildContext context, String t,String m) async{

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
      onPressed: () {Navigator.of(context, rootNavigator: true).pop();},
    );
    var a = [
        signButton,
        okButton
      ];
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
}