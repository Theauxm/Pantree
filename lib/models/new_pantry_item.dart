import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/static_functions.dart';

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
  String _selectedUnit = "Unit";
  final List<String> units = ['Cups', 'Oz.', 'Tsp.', 'Tbsp.', 'Unit'];

  @override
  void dispose() {
    _addItemTextController.dispose();
    _addQtyTextController.dispose();
    super.dispose();
  }

  Future<void> addNewItem(String item, String qty, String unit) {
    DateTime now = new DateTime.now();
    DateTime date = new DateTime(now.year, now.month, now.day);
    item = item.toLowerCase();
    unit = unit.toLowerCase();
    return firestoreInstance.collection('food').doc(item).get().then((doc) {
      // add item to the DB first if it doesn't exist
      if (!doc.exists) {
        firestoreInstance.collection('food').doc(item).set({
          'Image': "",
          'Keywords': getKeywords(item)
        }); // adds doc with specified name and no fields
      }
      // now add it to the user pantry
      widget.pantry
          .collection('Ingredients')
          .add({
            'Item': doc.reference,
            'Quantity': int.parse(qty),
            'Unit': unit,
            'DateAdded': date
          }) // adds doc with auto-ID and fields
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
          title: Text("Add Item to Your Pantry"),
        ),
        body: Container(
            margin: EdgeInsets.all(15.0),
            child: Form(
                key: _form,
                child: Column(children: [
                  TextFormField(
                    controller: _addItemTextController,
                    validator: (value) {
                      if (value.isEmpty || value == null) {
                        return 'Please enter a name';
                      } else if (!RegExp(r"^[a-zA-Z0-9\s\']+$")
                          .hasMatch(value)) {
                        return "Name can only contain letters";
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      hintText: "Item Name",
                      border: OutlineInputBorder(),
                    ),
                    obscureText: false,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 10.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 100,
                        child: TextFormField(
                          controller: _addQtyTextController,
                          validator: (value) {
                            if (value.isEmpty || value == null) {
                              return "Please enter a quantity";
                            } else if (value == "0") {
                              return "Quantity cannot be 0";
                            } else if (!RegExp(r"^[0-9]*$").hasMatch(value)) {
                              return "Quantity must be a number";
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            hintText: "Qty",
                            errorMaxLines: 2,
                            border: OutlineInputBorder(),
                          ),
                          obscureText: false,
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                                color: Color.fromRGBO(255, 190, 50, 1.0),
                                width: 1,
                                style: BorderStyle.solid)),
                        child: DropdownButton<String>(
                            isDense: false,
                            itemHeight: 58.0,
                            value: _selectedUnit,
                            style: TextStyle(color: Colors.white),
                            icon: Icon(Icons.arrow_drop_down,
                                color: Colors.black),
                            items: units.map<DropdownMenuItem<String>>((val) {
                              return DropdownMenuItem<String>(
                                value: val,
                                child: Text(val),
                              );
                            }).toList(),
                            onChanged: (String newVal) {
                              setState(() {
                                _selectedUnit = newVal;
                              });
                            },
                            hint: Text("Select unit"),
                            underline: DropdownButtonHideUnderline(child: Container()),
                            elevation: 0,
                            dropdownColor: Color.fromRGBO(255, 190, 50, 1.0),
                            selectedItemBuilder: (BuildContext context) {
                              return units.map((String val) {
                                return Container(
                                    alignment: Alignment.centerRight,
                                    width: 50,
                                    child: Text(
                                      _selectedUnit,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          color: Colors.black54, fontSize: 16.0),
                                    ));
                              }).toList();
                            }),
                      )
                    ],
                  ),
                  SizedBox(height: 100.0),
                  SizedBox(
                    height: 40,
                    width: 125,
                    child: TextButton(
                      style: TextButton.styleFrom(
                          backgroundColor: Colors.lightBlue),
                      onPressed: () {
                        if (_form.currentState.validate()) {
                          addNewItem(_addItemTextController.text,
                              _addQtyTextController.text, _selectedUnit);
                          Navigator.pop(context);
                        }
                      },
                      child: Text(
                        'ADD ITEM',
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
                  )
                ]))));
  }
}
