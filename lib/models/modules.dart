import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/static_functions.dart';
import '../models/extensions.dart';
import 'package:intl/intl.dart';
import '../models/dialogs.dart';
import '../pantreeUser.dart';

 /// Add new Item to Pantry/Shopping list
 /// [itemList]- Document Reference to either the current pantry/ shoppinglist
 /// [usedByWidget]- Name of the view using this widget
class NewFoodItem extends StatefulWidget {
  final DocumentReference itemList;
  final String usedByWidget;// Will be "Shopping list" /"Pantry"
  const NewFoodItem({Key key, this.itemList, this.usedByWidget}) : super(key: key);

  @override
  _NewFoodItemState createState() => _NewFoodItemState();
}

class _NewFoodItemState extends State<NewFoodItem> {
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
    super.dispose(); // end dispose() with this
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
      // now add it to the user pantry/shoppinglist
      widget.itemList
          .collection('ingredients')
          .add({
        'Item': doc.reference,
        'Quantity': int.parse(qty),
        'Unit': unit,
        'DateAdded': date
      }) // adds doc with auto-ID and fields
          .then((_) => print('$qty $item(s) added to user pantry/shoppinglist!'))
          .catchError(
              (error) => print('Failed to add $item to user pantry/shoppinglist: $error'));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Color.fromRGBO(255, 190, 50, 1.0),
          title: Text("Add Item to Your "+ widget.usedByWidget),
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



/// Create Card for Pantry/shopping list
///
Widget itemCard(doc,context){
  return Card(
    elevation: 7.0,
    margin: EdgeInsets.symmetric(horizontal: 15.0, vertical: 3.0),
    child: ListTile(
      leading: Icon(Icons.fastfood_rounded),
      title: Text(
        doc['Item'].id.toString().capitalizeFirstOfEach,
        style: const TextStyle(
            fontSize: 16, fontWeight: FontWeight.w600),
      ),
      subtitle: Container(
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Quantity: " +
                      doc['Quantity'].toString() +
                      " " +
                      doc['Unit'].toString().capitalizeFirstOfEach,
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w600),
                ),
                Text(
                  "Date Added: " + formatDate(doc['DateAdded']),
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w600),
                ),
              ])),
      trailing: IconButton(
        icon: Icon(Icons.delete, size: 20.0),
        onPressed: (() {
          showDeleteDialog(
              context,
              doc['Item'].id.toString().capitalizeFirstOfEach,
              doc);
        }),
      ),
    ),
  );
}
///Helper method for creating cards
String formatDate(Timestamp time) {
  DateTime date = time.toDate();
  DateFormat formatter = DateFormat("MM/dd/yyyy");
  return formatter.format(date);
}



/// Creates popup menu for ShoppingList/Pantry
//
// Widget viewOptions(DocumentReference ){
//   return PopupMenuButton<String>(
//     onSelected: (selected) {
//       switch (selected) {
//         case 'Create a new pantry':
//           {
//             createPantry(false);
//           }
//           break;
//         case 'Edit selected pantry':
//           {
//             editPantry(_selectedPantryName);
//           }
//           break;
//       }
//     },
//     itemBuilder: (BuildContext context) {
//       return {'Create a new pantry', 'Edit selected pantry'}
//           .map((String choice) {
//         return PopupMenuItem<String>(
//           value: choice,
//           child: Text(choice),
//         );
//       }).toList();
//     },
//   );
// }






class NewItemList extends StatelessWidget {
  PantreeUser user;
  final String usedByWidget;
  final TextEditingController _ListName = TextEditingController();
  final GlobalKey<FormState> _form = GlobalKey<FormState>();
  bool makePrimary;
  NewItemList({this.user, this.usedByWidget, this.makePrimary});

  final GlobalKey<State> _keyLoader = new GlobalKey<State>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Create new" +usedByWidget),
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
                  labelText: usedByWidget+ "Name",
                  border: OutlineInputBorder(),
                )),
            SizedBox(height: 10),
            TextButton(
              style: TextButton.styleFrom(backgroundColor: Colors.blue),
              onPressed: () {
                _handleSubmit(context, _ListName.text);
              },
              child: Text(
                'Create'+usedByWidget,
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
            usedByWidget+"Creation was Successful Return to your $usedByWidget!","Return to $usedByWidget");
      } else{
        Dialogs.showDialogCreatePL(context, "Failed",
            "Something went wrong! Try again later!","Return to "+usedByWidget);
      }
      //Navigator.pushReplacementNamed(context, "/home");
    } catch (error) {
      print(error);
    }
  }

  Future<bool> createShoppingList(name) async{
    String collectionName="shopping_lists";
    String fieldname = "ShoppingIDs";
    String primaryField = 'PSID';
    if(usedByWidget == "Pantry"){
      collectionName = "pantries";
      fieldname = "PantryIDs";
      primaryField = 'PPID';
    }
    try {
      await FirebaseFirestore.instance.collection(collectionName).add({
        "Name": name,
        "Owner": FirebaseFirestore.instance.collection("users").doc(user.uid),
      }).then((value) {
        if (makePrimary) {
          FirebaseFirestore.instance.collection("users").doc(user.uid).update({
            primaryField: FieldValue.arrayUnion([value]),
            fieldname: FieldValue.arrayUnion([value]),
          });
        }
        else {
          FirebaseFirestore.instance.collection("users").doc(user.uid).update({
            fieldname: FieldValue.arrayUnion([value]),
          });
        }
      });
    } catch (e) {
      return false;
    }
    return true;
  }

}