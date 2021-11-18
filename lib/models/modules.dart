import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
//import 'package:pantree/models/custom_dropdown.dart';
//import 'package:dropdown_below/dropdown_below.dart';
import '../models/static_functions.dart';
import '../models/extensions.dart';
import '../models/dialogs.dart';
import '../pantreeUser.dart';
import '../models/drawer.dart';
import 'package:pantree/models/recipe_viewer.dart';

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
  //final _focusNode = FocusNode();

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
          'Keywords': getKeywords(item),
          'recipe_ids': []
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
          title: Text("Add item to your " + widget.usedByView),
        ),
        body: Container(
            margin: EdgeInsets.all(30.0),
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
                  SizedBox(height: 30.0),
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
                        width: 100,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                                color: Color.fromRGBO(255, 190, 50, 1.0),
                                width: 1,
                                style: BorderStyle.solid)),
                        child: /*DropdownButtonHideUnderline(
                              child: CustomDropdownButton(
                                value: _selectedUnit,
                                hint: SizedBox(
                                    width: 100.0,
                                    child:
                                    Text("Unit", textAlign: TextAlign.center)),
                                items: units.map<DropdownMenuItem<String>>((val) {
                                  return DropdownMenuItem<String>(
                                    value: val,
                                    child: SizedBox(
                                        width: 100.0,
                                        child:
                                            Text(val, textAlign: TextAlign.center)),
                                  );
                                }).toList(),
                                onChanged: (String newVal) {
                                  setState(() {
                                    _selectedUnit = newVal;
                                  });
                                },
                          ))*/
                            DropdownButton<String>(
                                isDense: false,
                                itemHeight: 58.0,
                                value: _selectedUnit,
                                style: TextStyle(color: Colors.white),
                                icon: Icon(Icons.arrow_drop_down,
                                    color: Colors.black),
                                items:
                                    units.map<DropdownMenuItem<String>>((val) {
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
                                underline: DropdownButtonHideUnderline(
                                    child: Container()),
                                elevation: 0,
                                dropdownColor:
                                    Color.fromRGBO(255, 190, 50, 1.0),
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
                        /*DropdownBelow(
                            itemWidth: 100,
                            itemTextstyle: TextStyle(
                                fontSize: 16.0,
                                fontWeight: FontWeight.w400,
                                color: Colors.black),
                            boxTextstyle: TextStyle(
                                fontSize: 16.0,
                                fontWeight: FontWeight.w400,
                                color: Colors.black),
                            boxPadding: EdgeInsets.fromLTRB(13, 12, 13, 12),
                            boxWidth: 100,
                            boxHeight: 59,
                            boxDecoration: BoxDecoration(
                                color: Colors.transparent,
                                border: Border.all(
                                    width: 1, color: Colors.white54)),
                            icon: Icon(Icons.arrow_drop_down,
                                color: Colors.black),
                            hint: Text('Unit'),
                            value: _selectedUnit,
                            items: units.map<DropdownMenuItem<String>>((val) {
                              return DropdownMenuItem<String>(
                                value: val,
                                child: Text(val),
                              );
                            }).toList(),
                            onChanged: (newVal) {
                              //FocusManager.instance.primaryFocus.unfocus();
                              //FocusScope.of(context).requestFocus(_focusNode);
                              setState(() {
                                _selectedUnit = newVal;
                              });
                            },
                          )*/
                      )
                    ],
                  ),
                  SizedBox(height: 42.0),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        primary: Colors.lightBlue,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 25, vertical: 10),
                        textStyle: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    onPressed: () {
                      if (_form.currentState.validate()) {
                        addNewItem(_addItemTextController.text,
                            _addQtyTextController.text, _selectedUnit);
                        Navigator.pop(context);
                      }
                    },
                    child: const Text("Add Item"),
                  ),
                ]))));
  }
}

/// Create Card for Pantry/shopping list
/// [ingredientDS] - Document Reference to either the current Pantry/Shopping list
/// [context] - Name of the view using this widget
Widget itemCard(DocumentSnapshot ingredientDS, BuildContext context,
    DocumentReference itemList) {
  double qty;
  if (ingredientDS['Quantity'] is int) {
    int temp = ingredientDS['Quantity'];
    qty = temp.toDouble();
  } else {
    qty = ingredientDS['Quantity'];
  }

  Future<double> updateQuantity(double newQuantity) {
    try {
      print("UPDATING QUANTITY");
      ingredientDS.reference.update({"Quantity": newQuantity}).catchError(
          (error) =>
              print("Failed to update Pantry/Shopping list name: $error"));
    } catch (e) {
      print(e);
    }
    return null;
  }

  return Card(
    elevation: 7.0,
    margin: EdgeInsets.symmetric(horizontal: 15.0, vertical: 3.0),
    child: ExpansionTile(
      leading: Icon(Icons.fastfood_rounded),
      title: Text(
        ingredientDS['Item'].id.toString().capitalizeFirstOfEach,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        "Quantity: " +
            ingredientDS['Quantity'].toString() +
            " " +
            ingredientDS['Unit'].toString().capitalizeFirstOfEach,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      ),
      trailing: IconButton(
        icon: Icon(Icons.delete, size: 20.0),
        onPressed: (() {
          Dialogs.showDeleteItemDialog(
              context,
              ingredientDS['Item'].id.toString().capitalizeFirstOfEach,
              ingredientDS);
        }),
      ),
      children: <Widget>[
        ListTile(
          leading: Icon(Icons.visibility_off, color: Colors.transparent),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
                Text("Quantity: ",
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w600),
                    textAlign: TextAlign.left),
                QuantityButton(
                  initialQuantity: qty,
                  onQuantityChange: updateQuantity,
                ),
              ]),
              Text(
                "Date Added: " + formatDate(ingredientDS['DateAdded']),
                style:
                    const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                textAlign: TextAlign.left,
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

///Helper method for creating cards
String formatDate(Timestamp time) {
  DateTime date = time.toDate();
  DateFormat formatter = DateFormat("MM/dd/yyyy");
  return formatter.format(date);
}

int getMissingIngredients(
    Set<DocumentReference> pantryIngredients, QuerySnapshot ingredients) {
  int numIngredients = 0;

  for (int i = 0; i < ingredients.docs.length; i++) {
    if (!pantryIngredients.contains(ingredients.docs[i]["Item"])) {
      numIngredients++;
    }
  }
  return numIngredients;
}

Widget addPantryItemDialogue(BuildContext context, PantreeUser user) {
  return Container(
      alignment: Alignment.center,
      child: Column(children: [
        Text(
          "Add some items to a pantry to get recipe recommendations!",
          style: TextStyle(fontSize: 20),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 30),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
              primary: Colors.lightBlue,
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
              textStyle:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => NewFoodItem(
                          itemList: user.PPID,
                          usedByView: "Pantry",
                        )));
          },
          child: const Text("Add Item"),
        ),
      ]));
}

Widget recipeCard(
    Set<DocumentReference> pantryIngredients,
    PantreeUser user,
    DocumentSnapshot recipe,
    BuildContext context,
    QuerySnapshot ingredientsSnapshot,
    {bool recommendRecipe = false}) {
  int missingIngred =
      getMissingIngredients(pantryIngredients, ingredientsSnapshot);

  if (missingIngred > 5 && recommendRecipe) return Container();

  Color cardColor = missingIngred < 3
      ? Colors.green
      : missingIngred >= 3 && missingIngred <= 5
          ? Colors.yellow[700]
          : Colors.red[400];
  return Card(
      margin: const EdgeInsets.only(top: 12.0, right: 8.0, left: 8.0),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
        title: Text(
          recipe["RecipeName"],
          style: TextStyle(fontSize: 20.0),
        ),
        subtitle: SizedBox(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height * 0.18,
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Card(
                  color: cardColor,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.0)),
                  child: Container(
                      padding: const EdgeInsets.only(
                          top: 5.0, right: 5.0, left: 5.0, bottom: 5.0),
                      child: Text(recipe["TotalTime"].toString() + " minutes",
                          style: TextStyle(
                            fontSize: 18.0,
                            color: Colors.white,
                          )))),
              Card(
                  color: cardColor,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.0)),
                  child: Container(
                      padding: const EdgeInsets.only(
                          top: 5.0, right: 5.0, left: 5.0, bottom: 5.0),
                      child: Text(recipe["Credit"].toString(),
                          style: TextStyle(
                            fontSize: 18.0,
                            color: Colors.white,
                          )))),
              Card(
                  color: cardColor,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.0)),
                  child: Container(
                      padding: const EdgeInsets.only(
                          top: 5.0, right: 5.0, left: 5.0, bottom: 5.0),
                      child: Text(
                          "Missing Ingredients: " + missingIngred.toString(),
                          style: TextStyle(
                            fontSize: 18.0,
                            color: Colors.white,
                          ))))
            ])),
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => ViewRecipe(user: user, recipe: recipe)));
        },
      ));
//return Card(child: Text(querySnapshot.data["RecipeName"].toString()));
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
          margin: EdgeInsets.all(30.0),
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
                SizedBox(height: 42),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      primary: Colors.lightBlue,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 25, vertical: 10),
                      textStyle: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                  onPressed: () {
                    if (_form.currentState.validate()) {
                      handleSubmit(context, _listNameTextController.text);
                    }
                  },
                  child: const Text("Create"),
                ),
              ]))),
    );
  }

  Future<void> handleSubmit(BuildContext context, name) async {
    try {
      Dialogs.showLoadingDialog(context, _keyLoader);
      bool b = await createItemList(name);
      Navigator.of(_keyLoader.currentContext, rootNavigator: true).pop();
      if (b) {
        Dialogs.showOKDialog(context, "Great Success!",
            "Your new ${usedByView.toLowerCase()} has been created.");
      } else {
        Dialogs.showOKDialog(context, "Oh no!",
            "Something went wrong trying to create your ${usedByView.toLowerCase()}! Please check your input or try again later.");
      }
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
        "AltUsers": []
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
      print(e);
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
  final bool isOwner;
  const Edit(
      {Key key,
      this.user,
      this.itemList,
      this.name,
      this.usedByView,
      this.isOwner})
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
  bool ogPrimaryVal;

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
        ogPrimaryVal = true;
      } else {
        makePrimary = false;
        ogPrimaryVal = false;
      }
    } else {
      // other case is for usedByView == "Shopping List"
      if (widget.user.PSID == widget.itemList) {
        makePrimary = true;
        ogPrimaryVal = true;
      } else {
        makePrimary = false;
        ogPrimaryVal = false;
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

  List<Widget> buildBody() {
    List<Widget> body = [];
    body.add(SizedBox(height: 10));
    if (widget.isOwner) {
      body.add(TextFormField(
          controller: _pantryNameTextController,
          focusNode: _focusNode,
          validator: (value) {
            if (value.isEmpty || value == null) {
              return 'Please enter a name for your ' +
                  widget.usedByView.toLowerCase();
            } else if (!RegExp(r"^[a-zA-Z0-9\s\']+$").hasMatch(value)) {
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
          )));
      body.add(SizedBox(height: 10));
    }

    body.add(CheckboxListTile(
      title: Text("Make Primary ${widget.usedByView}"),
      checkColor: Colors.white,
      selectedTileColor: Color.fromRGBO(255, 190, 50, 1.0),
      value: makePrimary,
      onChanged: (bool value) {
        setState(() {
          makePrimary = value;
        });
      },
    ));

    body.add(SizedBox(height: 10));
    body.add(TextButton(
      style: TextButton.styleFrom(backgroundColor: Colors.blue),
      onPressed: () {
        String title = "Failed!";
        String message = "${widget.usedByView} edit failed, please try again.";
        if (_form.currentState.validate()) {
          if (editList(_pantryNameTextController.text, makePrimary)) {
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
    ));

    if (widget.isOwner) {
      body.add(SizedBox(height: 10));
      body.add(TextButton(
        style: TextButton.styleFrom(backgroundColor: Colors.red),
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => (ManageUsers(
                        listRef: widget.itemList,
                        usedByView: widget.usedByView,
                      ))));
        },
        child: Text(
          'Manage Users',
          style: TextStyle(color: Colors.white),
        ),
      ));
    }

    return body;
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
          body: Container(
              margin: EdgeInsets.all(17.0),
              child: Form(
                  key: _form,
                  child: Column(
                    children: buildBody(),
                  ))),
        ));
  }

  bool editList(String name, bool makePrimary) {
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
    bool primaryChanged = (makePrimary != ogPrimaryVal) ? true : false;
    // set up the button
    Widget okButton = TextButton(
      child: Text("OK"),
      onPressed: () {
        if (success) {
          Navigator.of(context, rootNavigator: true).pop();
          Navigator.of(context).pop([newName, primaryChanged, makePrimary]);
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
  String text = "";
  if (usedByView == "Pantry") {
    text = "pantries";
  } else {
    text = "shopping lists";
  }
  return Scaffold(
    appBar: AppBar(title: Text("Create a " + usedByView)),
    drawer: PantreeDrawer(user: user),
    body: Container(
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(Icons.sentiment_very_dissatisfied, size: 72),
          Container(
            child: Text(
              'You appear to be devoid of $text',
              style: TextStyle(color: Colors.black, fontSize: 20),
              textAlign: TextAlign.center,
            ),
            margin: EdgeInsets.all(16),
          ),
          SizedBox(height: 30),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                primary: Colors.lightBlue,
                padding:
                    const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
                textStyle:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
            child: const Text("Create"),
          ),
        ],
      ),
    ),
  );
}

///Add a user to a pantry
class AddNewCollaborator extends StatefulWidget {
  final PantreeUser user;
  final String usedByView;
  final DocumentReference docRef;

  const AddNewCollaborator({Key key, this.user, this.usedByView, this.docRef})
      : super(key: key);

  @override
  AddNewCollaboratorState createState() => AddNewCollaboratorState();
}

class AddNewCollaboratorState extends State<AddNewCollaborator> {
  var items;

  void createList() {
    items = [];
    for (var i = 0; i < widget.user.friends.length; i++) {
      items.add(new CheckBoxListTileModel(
          title: widget.user.friends[i][2],
          isCheck: false,
          ref: widget.user.friends[i][1]));
    }
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    createList();
  }

  selectAll() {
    items.forEach((element) {
      element.isCheck = true;
    });
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Select Friends to add!"), actions: <Widget>[
        Padding(
            padding: EdgeInsets.only(right: 20.0),
            child: TextButton(
              child: Text("Select All"),
              style: TextButton.styleFrom(
                  primary: Colors.white, textStyle: TextStyle(fontSize: 18)),
              onPressed: selectAll,
            )),
      ]),
      body: Column(children: [
        Expanded(
          child: ListView.builder(
              itemCount: items.length,
              itemBuilder: (BuildContext context, int index) {
                return new Card(
                  child: new Container(
                    padding: new EdgeInsets.all(10.0),
                    child: Column(
                      children: <Widget>[
                        new CheckboxListTile(
                            activeColor: Colors.pink[300],
                            dense: true,
                            //font change
                            title: new Text(
                              items[index].title,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
                              ),
                            ),
                            value: items[index].isCheck,
                            secondary: Container(
                                child: Icon(
                              Icons.account_box,
                              size: 50,
                            )),
                            onChanged: (bool val) {
                              setState(() {
                                items[index].isCheck = val;
                              });
                            })
                      ],
                    ),
                  ),
                );
              }),
        ),
      ]),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          addPeople();
        },
        label: Text("Add users to ${widget.usedByView}"),
        backgroundColor: Colors.lightBlue,
        icon: const Icon(Icons.add_shopping_cart_outlined),
        //onPressed: (),
      ),
    );
  }

  bool addPeople() {
    bool noneSelected = true;
    String fieldName = "PantryIDs";
    if (widget.usedByView != "Pantry") {
      fieldName = "ShoppingIDs";
    }
    try {
      items.forEach((element) {
        if (element.isCheck) {
          noneSelected = false;
          element.ref.update({
            fieldName: FieldValue.arrayUnion([widget.docRef]),
          });

          widget.docRef.update({
            'AltUsers': FieldValue.arrayUnion([element.ref]),
          });
        }
      });
    } catch (e) {
      return false;
    }

    if (noneSelected) {
      Dialogs.showError(context, "No Friends Selected",
          "Please select at least one friend to add to your ${widget.usedByView.toLowerCase()}.");
    } else {
      Dialogs.showOKDialog(context, "Great Success!",
          "Your friend(s) have been added to your ${widget.usedByView.toLowerCase()}.");
    }

    return true;
  }
}

class CheckBoxListTileModel {
  String title;
  bool isCheck;
  DocumentReference ref;
  CheckBoxListTileModel({this.title, this.isCheck, this.ref});
}

//Remove a user from a pantry
class ManageUsers extends StatefulWidget {
  final DocumentReference listRef;
  final String usedByView;
  ManageUsers({Key key, this.listRef, this.usedByView}) : super(key: key);

  @override
  ManageUsersState createState() => ManageUsersState();
}

// https://stackoverflow.com/questions/51607440/horizontally-scrollable-cards-with-snap-effect-in-flutter
class ManageUsersState extends State<ManageUsers> {
  List altUsers; // Friends Map, With their names and Doc Ref!
  StreamSubscription<DocumentSnapshot> friendListener;
  Future<dynamic> getUsers() async {
    print("IN GETUSERS");
    altUsers = [];
    var listDoc = await widget.listRef.get();
    List altUsersRef = listDoc.data()['AltUsers'];

    for (int i = 0; i < altUsersRef.length; i++) {
      var tempUser = await altUsersRef[i].get();
      String tempName = tempUser.data()['Username'];
      altUsers.add([tempName, altUsersRef[i]]);
    }

    // very important: se setState() to force a call to build()
    if (mounted) {
      setState(() {});
    }
  }

  setListener() {
    friendListener = widget.listRef.snapshots().listen((event) {
      print(altUsers.length);

      if (event.data()['AltUsers'].length != altUsers.length) {
        getUsers();
      }
    });
  }

  @override
  void initState() {
    super.initState();
    getUsers().then((val) => {setListener()});
  }

  @override
  void dispose() {
    friendListener.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Remove Users"),
      ),
      body: Column(children: <Widget>[
        buildListUsers(),
      ]),
    );
  }

  Widget buildListUsers() {
    //List keys = map.keys.toList()
    if (altUsers == null) {
      return Center(child: CircularProgressIndicator());
    }

    return Expanded(
        child: ListView.builder(
      itemBuilder: (context, index) {
        return Card(
          elevation: 7.0,
          margin: EdgeInsets.symmetric(horizontal: 15.0, vertical: 3.0),
          child: ListTile(
              leading: Container(
                  child: IconButton(
                icon: Icon(
                  Icons.account_box,
                  size: 30,
                ),
                onPressed: () {
                  //profileClicked(fl, index);
                },
              )),
              title: Text(
                altUsers[index][0].toString(),
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              trailing: TextButton(
                style: TextButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () {
                  //TODO: Are you sure dialog
                  removeUser(altUsers[index][1], altUsers[index][0]);
                },
                child: Text(
                  'REMOVE',
                  style: TextStyle(color: Colors.white),
                ),
              )),
        );
      },
      itemCount: altUsers.length,
    ));
  }

  removeUser(userRef, key) async {
    await widget.listRef.update({
      'AltUsers': FieldValue.arrayRemove([userRef]),
    });
    String fieldName = 'PantryIDs';
    if (widget.usedByView != "Pantry") {
      fieldName = "ShoppingIDs";
    }
    await userRef.update({
      fieldName: FieldValue.arrayRemove([widget.listRef]),
    });

    setState(() {});
  }
}

class QuantityButton extends StatefulWidget {
  final double initialQuantity;
  final Future<double> Function(double) onQuantityChange;
  const QuantityButton({Key key, this.initialQuantity, this.onQuantityChange})
      : super(key: key);

  @override
  _QuantityButtonState createState() =>
      _QuantityButtonState(quantity: initialQuantity);
}

class _QuantityButtonState extends State<QuantityButton> {
  double quantity;
  bool isSaving = false;

  _QuantityButtonState({this.quantity});

  void changeQuantity(double newQuantity) async {
    setState(() {
      isSaving = true;
    });
    newQuantity = await widget.onQuantityChange(newQuantity) ?? newQuantity;
    setState(() {
      quantity = newQuantity;
      isSaving = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      IconButton(
          color: Colors.black,
          onPressed: (isSaving || quantity < 1)
              ? null
              : () => changeQuantity(quantity - 1),
          icon: Icon(Icons.remove_circle_outline, size: 16.0)),
      Text(quantity.toString()),
      IconButton(
          color: Colors.black,
          onPressed: (isSaving) ? null : () => changeQuantity(quantity + 1),
          icon: Icon(Icons.add_circle_outline, size: 16.0)),
    ]);
  }
}
