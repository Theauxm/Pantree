import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pantree/pantreeUser.dart';

class NewShoppingList extends StatelessWidget {
  PantreeUser user;
  final TextEditingController _ListName = TextEditingController();
  final GlobalKey<FormState> _form = GlobalKey<FormState>();

  NewShoppingList({this.user});

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
            style: TextButton.styleFrom(
                backgroundColor: Colors.blue),
            onPressed: (){
              if(_form.currentState.validate()) {
                if(createShoppingList(_ListName.text)){
                  //TODO: POPUP For successful and failed creation
                }
              }
            },
            child: Text(
              'Create Shopping List!',
              style: TextStyle(
                  fontSize: 14, color: Colors.black),
            ),
          ),
        ])),
    );
  }

bool createShoppingList(name){
    try {
      FirebaseFirestore.instance.collection("shopping_lists").add(
          {
            "Name": name,
            "Owner": FirebaseFirestore.instance.collection("users").doc(
                user.uid),
          }).then((value) {
        FirebaseFirestore.instance.collection("users").doc(user.uid).update({
          'ShoppingIDs': FieldValue.arrayUnion([value]),
        });
      });
    } catch (e){
      return false;
    }
  return true;
}

}