import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../models/static_functions.dart';
import '../models/extensions.dart';
import '../models/dialogs.dart';
import '../pantreeUser.dart';
import '../models/drawer.dart';

/// Add new Item to Pantry/Shopping list
/// [itemList] - Document Reference to either the current Pantry/Shopping list
/// [usedByView] - Name of the view using this widget
class NewFoodItem extends StatefulWidget {
  final DocumentReference itemList;
  final String usedByView; // Will be either "Shopping list" or "Pantry"
  const NewFoodItem({Key key, this.itemList, this.usedByView})
      : super(key: key);

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
      // now add it to the user Pantry/Shopping list
      widget.itemList
          .collection('ingredients')
          .add({
            'Item': doc.reference,
            'Quantity': int.parse(qty),
            'Unit': unit,
            'DateAdded': date
          }) // adds doc with auto-ID and fields
          .then(
              (_) => print('$qty $item(s) added to user Pantry/Shopping list!'))
          .catchError((error) => print(
              'Failed to add $item to user Pantry/Shopping list: $error'));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Color.fromRGBO(255, 190, 50, 1.0),
          title: Text("Add Item to Your " + widget.usedByView),
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
                        return "Name must be alphanumeric";
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
                            underline:
                                DropdownButtonHideUnderline(child: Container()),
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
                                          color: Colors.black54,
                                          fontSize: 16.0),
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
/// [doc] - Document Reference to either the current Pantry/Shopping list
/// [context] - Name of the view using this widget
Widget itemCard(doc, context) {
  return Card(
    elevation: 7.0,
    margin: EdgeInsets.symmetric(horizontal: 15.0, vertical: 3.0),
    child: ListTile(
      leading: Icon(Icons.fastfood_rounded),
      title: Text(
        doc['Item'].id.toString().capitalizeFirstOfEach,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
      subtitle: Container(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(
          "Quantity: " +
              doc['Quantity'].toString() +
              " " +
              doc['Unit'].toString().capitalizeFirstOfEach,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        Text(
          "Date Added: " + formatDate(doc['DateAdded']),
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ])),
      trailing: IconButton(
        icon: Icon(Icons.delete, size: 20.0),
        onPressed: (() {
          showDeleteDialog(
              context, doc['Item'].id.toString().capitalizeFirstOfEach, doc);
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

class NewItemList extends StatelessWidget {
  PantreeUser user;
  final String usedByView;
  final TextEditingController _listNameTextController = TextEditingController();
  final GlobalKey<FormState> _form = GlobalKey<FormState>();
  bool makePrimary;
  NewItemList({this.user, this.usedByView, this.makePrimary});

  final GlobalKey<State> _keyLoader = new GlobalKey<State>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Create new " + usedByView),
      ),
      body: Container(
          margin: EdgeInsets.all(15.0),
          child: Form(
              key: _form,
              child: Column(children: [
                TextFormField(
                    controller: _listNameTextController,
                    validator: (value) {
                      if (value.isEmpty || value == null) {
                        return 'Please enter a name for your ${usedByView.toLowerCase()}';
                      } else if (!RegExp(r"^[a-zA-Z0-9\s\']+$")
                          .hasMatch(value)) {
                        return "Name must be alphanumeric";
                      }
                      return null;
                    },
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(18),
                    ],
                    decoration: InputDecoration(
                      labelText:
                          usedByView + " Name (e.g., Theaux's $usedByView)",
                      border: OutlineInputBorder(),
                    )),
                SizedBox(height: 10),
                TextButton(
                  style: TextButton.styleFrom(backgroundColor: Colors.blue),
                  onPressed: () {
                    if (_form.currentState.validate()) {
                      _handleSubmit(context, _listNameTextController.text);
                    }
                  },
                  child: Text(
                    'Create ' + usedByView,
                    style: TextStyle(fontSize: 14, color: Colors.white),
                  ),
                ),
              ]))),
    );
  }

  Future<void> _handleSubmit(BuildContext context, name) async {
    try {
      Dialogs.showLoadingDialog(context, _keyLoader);
      bool b = await createItemList(name);
      Navigator.of(_keyLoader.currentContext, rootNavigator: true).pop();
      if (b) {
        Dialogs.showDialogCreatePL(
            context,
            "Success",
            usedByView + "Creation was Successful Return to your $usedByView!",
            "Return to $usedByView");
      } else {
        Dialogs.showDialogCreatePL(
            context,
            "Failed",
            "Something went wrong! Try again later!",
            "Return to " + usedByView);
      }
      //Navigator.pushReplacementNamed(context, "/home");
    } catch (error) {
      print(error);
    }
  }

  Future<bool> createItemList(name) async {
    String collectionName = "shopping_lists";
    String fieldName = "ShoppingIDs";
    String primaryField = 'PSID';
    if (usedByView == "Pantry") {
      collectionName = "pantries";
      fieldName = "PantryIDs";
      primaryField = 'PPID';
    }
    try {
      await FirebaseFirestore.instance.collection(collectionName).add({
        "Name": name,
        "Owner": FirebaseFirestore.instance.collection("users").doc(user.uid),
      }).then((value) {
        if (makePrimary) {
          FirebaseFirestore.instance.collection("users").doc(user.uid).update({
            primaryField: value,
            fieldName: FieldValue.arrayUnion([value]),
          });
        } else {
          FirebaseFirestore.instance.collection("users").doc(user.uid).update({
            fieldName: FieldValue.arrayUnion([value]),
          });
        }
      });
    } catch (e) {
      return false;
    }
    return true;
  }
}

var globalContext;

/// Edit a Pantry/Shopping list
/// [user] - The current user
/// [itemList] - Document Reference to either the current Pantry/Shopping list
/// [usedByView] - Name of the view using this widget
/// [name] - The original Pantry/Shopping list name
class Edit extends StatefulWidget {
  final PantreeUser user;
  final DocumentReference itemList;
  final String usedByView; // Will be either "Shopping list" or "Pantry"
  final String name;
  const Edit({Key key, this.user, this.itemList, this.name, this.usedByView})
      : super(key: key);

  @override
  _EditState createState() => _EditState();
}

class _EditState extends State<Edit> {
  TextEditingController _pantryNameTextController;
  final GlobalKey<FormState> _form = GlobalKey<FormState>();
  final _focusNode = FocusNode();
  String newName = "";
  bool makePrimary;

  @override
  void dispose() {
    _pantryNameTextController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    newName = widget.name;
    if (newName.endsWith("*"))
      newName = newName.substring(0, newName.length - 1);
    _pantryNameTextController = TextEditingController(text: newName);
    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        _pantryNameTextController.selection = TextSelection(
            baseOffset: 0, extentOffset: _pantryNameTextController.text.length);
      }
    });
    if (widget.usedByView == "Pantry") {
      if (widget.user.PPID == widget.itemList) {
        makePrimary = true;
      } else {
        makePrimary = false;
      }
    } else {
      // other case is for usedByView == "Shopping List"
      if (widget.user.PSID == widget.itemList) {
        makePrimary = true;
      } else {
        makePrimary = false;
      }
    }
  }

  Future<bool> _onWillPop() async {
    return (await showDialog(
          context: context,
          builder: (context) => new AlertDialog(
            title: new Text('Discard Changes?'),
            content: new Text(
                'Changes to your ${widget.usedByView.toLowerCase()} will not be saved.'),
            actions: <Widget>[
              TextButton(
                onPressed: () =>
                    Navigator.of(context, rootNavigator: true).pop(false),
                child: new Text('No'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context, rootNavigator: true).pop();
                  Navigator.of(globalContext).pop(true);
                },
                child: new Text('Yes'),
              ),
            ],
          ),
        )) ??
        false; // return false in case it's null (due to async)
  }

  @override
  Widget build(BuildContext context) {
    globalContext = context;
    return WillPopScope(
        onWillPop: _onWillPop,
        child: Scaffold(
          appBar: AppBar(
            title: Text("Edit " + widget.usedByView),
          ),
          body: Form(
              key: _form,
              child: Column(children: <Widget>[
                SizedBox(height: 10),
                TextFormField(
                    controller: _pantryNameTextController,
                    focusNode: _focusNode,
                    validator: (value) {
                      if (value.isEmpty || value == null) {
                        return 'Please enter a name for your ' +
                            widget.usedByView.toLowerCase();
                      } else if (!RegExp(r"^[a-zA-Z0-9\s\']+$")
                          .hasMatch(value)) {
                        return "Name must be alphanumeric";
                      }
                      return null;
                    },
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(18),
                    ],
                    decoration: InputDecoration(
                      labelText: "New ${widget.usedByView} Name",
                      border: OutlineInputBorder(),
                    )),
                SizedBox(height: 10),
                CheckboxListTile(
                  title: Text("Make Primary ${widget.usedByView}"),
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
                    String message =
                        "${widget.usedByView} edit failed, please try again.";
                    if (_form.currentState.validate()) {
                      if (editPantry(
                          _pantryNameTextController.text, makePrimary)) {
                        title = "Success!";
                        message =
                            "Your ${widget.usedByView} has been edited. \nPress OK to return to your ${widget.usedByView}!";
                        showAlertDialog(context, title, message, true);
                      } else {
                        showAlertDialog(context, title, message, false);
                      }
                    }
                  },
                  child: Text(
                    'Save Changes',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ])),
        ));
  }

  bool editPantry(String name, bool makePrimary) {
    String primaryField = 'PSID';
    if (widget.usedByView == "Pantry") {
      primaryField = 'PPID';
    }
    try {
      if (name != widget.name) {
        newName = name;
        widget.itemList.update({
          "Name": name,
        }).catchError((error) =>
            print("Failed to update Pantry/Shopping list name: $error"));
      }

      if (makePrimary) {
        FirebaseFirestore.instance
            .collection("users")
            .doc(widget.user.uid)
            .update({
          primaryField: widget.itemList,
        }).catchError((error) =>
                print("Failed to update default Pantry/Shopping list: $error"));
      }
    } catch (e) {
      print(e);
      return false;
    }
    return true;
  }

  showAlertDialog(
      BuildContext context, String t, String m, bool success) async {
    // set up the button
    Widget okButton = TextButton(
      child: Text("OK"),
      onPressed: () {
        if (success) {
          Navigator.of(context, rootNavigator: true).pop();
          Navigator.of(context).pop(newName);
        } else {
          Navigator.of(context, rootNavigator: true).pop();
        }
      },
    );

    AlertDialog alert =
        AlertDialog(title: Text(t), content: Text(m), actions: [okButton]);

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}

///Create the Landing pages for ShoppingList/Pantry
Widget createLandingPage(user, usedByView, context) {
  return Scaffold(
    appBar: AppBar(title: Text(usedByView + "s")),
    drawer: PantreeDrawer(user: user),
    body: Container(
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            child: Text(
              'Create a $usedByView!',
              style: TextStyle(color: Colors.black, fontSize: 20),
            ),
            margin: EdgeInsets.all(16),
          ),
          TextButton(
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => (NewItemList(
                            user: user,
                            usedByView: usedByView,
                            makePrimary: true,
                          ))));
            },
            child: Text('Create $usedByView'),
            style: TextButton.styleFrom(
                primary: Colors.white, backgroundColor: Colors.lightBlueAccent),
          ),
        ],
      ),
    ),
  );
}
