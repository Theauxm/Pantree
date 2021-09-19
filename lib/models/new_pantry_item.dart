import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class NewPantryItem extends StatefulWidget {
  final DocumentReference pantry;

  const NewPantryItem({Key key, this.pantry}) : super(key: key);

  @override
  _NewPantryItemState createState() => _NewPantryItemState();
}

class _NewPantryItemState extends State<NewPantryItem> {
  final firestoreInstance = FirebaseFirestore.instance;
  final GlobalKey<FormState> _form = GlobalKey<FormState>();
  TextEditingController _addItemTextController = TextEditingController();
  TextEditingController _addQtyTextController = TextEditingController();

  Future<void> addNewItem(String item, String qty) {
    return firestoreInstance.collection('food').doc(item).get().then((doc) {
      // add item to the DB first if it doesn't exist
      if (!doc.exists) {
        firestoreInstance
            .collection('food')
            .doc(item)
            .set({}); // adds doc with specified name and no fields
      }
      // now add it to the user pantry
      widget.pantry
          .collection('Ingredients')
          .add({'Item': doc.reference, 'Quantity': int.parse(qty)}) // adds doc with auto-ID and fields
          .then((_) => print('$qty $item(s) added to user pantry!'))
          .catchError(
              (error) => print('Failed to add $item to user pantry: $error'));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Color.fromRGBO(255, 190, 50, 1.0),
          title: Text("Add item to your pantry"),
        ),
        body: Container (
          margin: EdgeInsets.all(15.0),
          child: Form (
            key: _form,
            child: Column(children: [
              TextFormField(
                controller: _addItemTextController,
                validator: (value) {
                  if (value.isEmpty || value == null) {
                    return 'Please enter a name';
                  }
                  else if (!RegExp(r"^[a-zA-Z\s\']+$").hasMatch(value)){
                    return "Name can only contain letters";
                  }
                  return null;
                },
                decoration: InputDecoration(
                  hintText: "Item name",
                  border: OutlineInputBorder(),
                ),
                obscureText: false,
              ),
              SizedBox(height: 10.0),
              TextFormField(
                controller: _addQtyTextController,
                validator: (value) {
                  if (value.isEmpty || value == null) {
                    return "Please enter a quantity";
                  }
                  else if (!RegExp(r"^[0-9]*$").hasMatch(value)){
                    return "Quantity must be a number";
                  }
                  return null;
                },
                decoration: InputDecoration(
                  hintText: "Quantity",
                  border: OutlineInputBorder(),
                ),
                obscureText: false,
              ),
              SizedBox(height: 10.0),
              SizedBox(
                height: 40,
                width: 125,
                child: TextButton(
                  style: TextButton.styleFrom(
                      backgroundColor: Colors.lightBlue),
                  onPressed: () {
                    if (_form.currentState.validate()) {
                      addNewItem(_addItemTextController.text, _addQtyTextController.text);
                      Navigator.pop(context);
                    }
                  },
                  child: Text(
                    'Add new item',
                    style: TextStyle(
                        fontSize: 16, color: Colors.white),
                  ),
                ),
              )
            ])
          )
        ));
  }
}
