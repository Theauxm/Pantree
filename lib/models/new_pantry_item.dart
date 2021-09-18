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
  TextEditingController _addItemTextController = TextEditingController();

  Future<void> addNewItem(String item) {
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
          .add({'Item': doc.reference, 'Quantity': 0}) // adds doc with auto-ID and fields
          .then((_) => print('$item added to user pantry!'))
          .catchError(
              (error) => print('Failed to add $item to user pantry: $error'));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(255, 190, 50, 1.0),
        title: Text("New Pantry Item"),
      ),
      body: TextField(
        controller: _addItemTextController,
        decoration: InputDecoration(
          labelText: "Add item to your pantry",
          border: OutlineInputBorder(),
        ),
        onEditingComplete: () {
          setState(() {
            addNewItem(_addItemTextController.text);
            Navigator.pop(context);
          });
        },
      ),
    );
  }
}
