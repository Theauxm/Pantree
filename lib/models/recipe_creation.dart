import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../pantreeUser.dart';

// Used from https://www.technicalfeeder.com/2021/09/flutter-add-textfield-dynamically/
class RecipeCreator extends StatefulWidget {
  PantreeUser user;
  RecipeCreator({this.user});

  @override
  State<StatefulWidget> createState() {
    return _InputForm(user: this.user);
  }
}

class _InputForm extends State<RecipeCreator> {
  PantreeUser user;
  _InputForm({this.user});
  final List<String> units = ['Cups', 'Oz.', 'Tsp.', 'Tbsp.', 'Unit'];

  List<TextEditingController> _ingredientControllers = [];
  List<TextFormField> _ingredientFields = [];
  List<Form> _ingredientAmountFields = [];
  List<Container> _unitFields = [];
  List<TextEditingController> _ingredientAmountControllers = [];
  List<String> _selectedUnits = [];

  List<TextEditingController> _directionControllers = [];
  List<TextFormField> _directionFields = [];

  TextEditingController recipeController = TextEditingController();
  TextFormField recipeField;

  TextEditingController totalTimeController = TextEditingController();
  Form totalTimeField;

  final firestoreInstance = FirebaseFirestore.instance;

  bool overviewIsVisible = true;
  bool ingredientIsVisible = false;
  bool directionIsVisible = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Create a Recipe"),
          backgroundColor: Colors.red[400],
          actions: [
            IconButton(
                onPressed: () {
                  addToDatabase();
                  Navigator.of(context).pop();
                },
                icon: const Icon(Icons.check_box))
          ],
        ),
        body: Column(children: [
          SizedBox(height: 20),
          buttons(),
          if (overviewIsVisible) pageOne(),
          if (ingredientIsVisible) pageTwo(),
          if (directionIsVisible) pageThree(),
        ]));
  }

  Widget buttons() {
    return Row(
      children: [
        Container(
            height: MediaQuery.of(context).size.height * 0.1,
            width: MediaQuery.of(context).size.width * 0.30,
            child: ListTile(
                onTap: () => setState(() {
                      overviewIsVisible = true;
                      ingredientIsVisible = false;
                      directionIsVisible = false;
                    }),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50)),
                tileColor: Colors.red[400],
                title: Center(
                    child: Text("Overview",
                        style: TextStyle(fontSize: 18, color: Colors.white))))),
        SizedBox(width: MediaQuery.of(context).size.width * 0.03),
        Container(
            height: MediaQuery.of(context).size.height * 0.1,
            width: MediaQuery.of(context).size.width * 0.30,
            child: ListTile(
                onTap: () => setState(() {
                      overviewIsVisible = false;
                      ingredientIsVisible = true;
                      directionIsVisible = false;
                    }),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50)),
                tileColor: Colors.red[400],
                title: Center(
                    child: Text("Ingredients",
                        style: TextStyle(fontSize: 18, color: Colors.white))))),
        SizedBox(width: MediaQuery.of(context).size.width * 0.03),
        Container(
            height: MediaQuery.of(context).size.height * 0.1,
            width: MediaQuery.of(context).size.width * 0.30,
            child: ListTile(
                onTap: () => setState(() {
                      overviewIsVisible = false;
                      ingredientIsVisible = false;
                      directionIsVisible = true;
                    }),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50)),
                tileColor: Colors.red[400],
                title: Center(
                    child: Text("Directions",
                        style: TextStyle(fontSize: 18, color: Colors.white))))),
      ],
    );
  }

  Widget pageOne() {
    if (recipeField == null) {
      recipeField = TextFormField(
        controller: recipeController,
        decoration: InputDecoration(
            border: OutlineInputBorder(),
            labelText: "Recipe name"),
      );
    }

    if (totalTimeField == null) {
      final GlobalKey<FormState> _form = GlobalKey<FormState>();
      totalTimeField = Form(key: _form, child: TextFormField(
        validator: (value) {
          if (value.isEmpty || value == null) {
            return "Please enter a quantity";
          } else if (value == "0") {
            return "Cannot be 0";
          } else if (!RegExp(r"^[0-9]*$").hasMatch(value)) {
            return "Must be a number";
          }
          return null;
        },
        onChanged: (String newVal) {
          _form.currentState.validate();
        },
        controller: totalTimeController,
        decoration: InputDecoration(
            border: OutlineInputBorder(),
            labelText: "Total time to cook (minutes)",
        ),
      ));
    }

    return Column(children: [
      SizedBox(height: 20),
      Container(
          width: MediaQuery.of(context).size.width * 0.9, child: recipeField),
      SizedBox(height: 20),
      Container(
          width: MediaQuery.of(context).size.width * 0.9,
          child: totalTimeField),
    ]);
  }

  Widget pageTwo() {
    String text = "Ingredient";
    return Expanded(
        child: Column(children: [
      Expanded(child: _ingredientsListView(text)),
      _addTile(text),
    ]));
  }

  Widget pageThree() {
    String text = "Direction";
    return Expanded(
        child: Column(children: [
      Expanded(child: _directionsListView(text)),
      _addTile(text),
    ]));
  }

  @override
  void dispose() {
    for (final controller in _ingredientControllers) {
      controller.dispose();
    }

    for (final controller in _directionControllers) {
      controller.dispose();
    }

    totalTimeController.dispose();
    recipeController.dispose();

    super.dispose();
  }

  Widget _createDropdownMenu(String _selectedUnit) {
    return Container(
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
    );
  }

  Widget _addTile(String text) {
    String _selectedUnit = units[0];
    return ListTile(
      title: Center(
          child: Container(
              width: MediaQuery.of(context).size.width * 0.5,
              height: MediaQuery.of(context).size.height * 0.1,
              child: Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50)),
                  color: Colors.red[400],
                  child: Center(
                    child: Text("Add " + text,
                        style: TextStyle(fontSize: 20, color: Colors.white)),
                  )))),
      onTap: () {
        final GlobalKey<FormState> _form = GlobalKey<FormState>();
        final controller = TextEditingController();
        final field = TextFormField(
          controller: controller,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            labelText: text,
          ),
        );

        Form amountField;
        TextEditingController amountController;
        Container unitField;
        if (text == "Ingredient") {
          amountController = TextEditingController();
          unitField = Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                    color: Colors.red[400],
                    width: 1,
                    style: BorderStyle.solid)),
            child: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return DropdownButton<String>(
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
                    dropdownColor: Colors.red[400],
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
                    });
              }
            )
          );
          amountField = Form(key: _form, child: TextFormField(
              validator: (value) {
                if (value.isEmpty || value == null) {
                  return "Please enter a quantity";
                } else if (value == "0") {
                  return "Cannot be 0";
                } else if (!RegExp(r"^[0-9]*$").hasMatch(value)) {
                  return "Must be a number";
                }
                return null;
              },
              onChanged: (String newVal) {
              _form.currentState.validate();
              },
            controller: amountController,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              label: Text("Amount",
                style: TextStyle(fontSize: 15),
              )
            )
          )
          );
        }

        setState(() {
          if (text == "Direction") {
            _directionControllers.add(controller);
            _directionFields.add(field);
          } else {
            _ingredientControllers.add(controller);
            _ingredientFields.add(field);
            _ingredientAmountFields.add(amountField);
            _unitFields.add(unitField);
            _ingredientAmountControllers.add(amountController);
            _selectedUnits.add(_selectedUnit);
          }
        });
      },
    );
  }

  Widget _ingredientsListView(String text) {
    return ListView.builder(
      itemCount: _ingredientFields.length,
      itemBuilder: (context, index) {
        return Container(
            margin: EdgeInsets.all(6),
            child: Card(
              elevation: 8,
                child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(7.0),
                  width: MediaQuery.of(context).size.width * 0.9,
                  child: _ingredientFields[index],
                ),
                Container(
                    padding: const EdgeInsets.all(7.0),
                    width: MediaQuery.of(context).size.width * 0.9,
                    child: Row(
                      children: [
                        Container(
                            width: MediaQuery.of(context).size.width * 0.4,
                            child: _ingredientAmountFields[index]
                        ),
                        SizedBox(width: MediaQuery.of(context).size.width * 0.04),
                        Container(
                            width: MediaQuery.of(context).size.width * 0.4,
                            child: _unitFields[index]
                        ),
                      ]
                    )
                )
              ],
            )));
      },
    );
  }

  Widget _directionsListView(String text) {
    return ListView.builder(
      itemCount: _directionFields.length,
      itemBuilder: (context, index) {
        return Container(
          margin: EdgeInsets.all(5),
          child: _directionFields[index],
        );
      },
    );
  }

  Set<String> getKeywords(String word) {
    word = word.toLowerCase();

    Set<String> keywords = {};
    for (int i = 0; i < word.length; i++)
      for (int j = 0; j < word.length; j++) {
        if (i > j) continue;
        keywords.add(word.substring(i, j + 1));
      }

    return keywords;
  }

  Future<void> addToDatabase() {
    DocumentReference newRecipe = firestoreInstance.collection('recipes').doc();
    CollectionReference ingredientCollection =
        newRecipe.collection('ingredients');
    print(newRecipe.id);

    Set<String> allKeywords = {};
    for (int i = 0; i < _ingredientControllers.length; i++) {
      TextEditingController ingred = _ingredientControllers[i];
      if (ingred.text == "") {
        continue;
      }
      String unit = _selectedUnits[i];
      TextEditingController amount = _ingredientAmountControllers[i];

      Set<String> ingredKeywords = getKeywords(ingred.text.toLowerCase());
      allKeywords.addAll(ingredKeywords);
      DocumentReference ingredInstance =
          firestoreInstance.collection('food').doc(ingred.text.toLowerCase());

      ingredInstance.get().then((docSnapshot) {
        if (docSnapshot.exists) {
          ingredInstance.update({
            'recipe_ids': [newRecipe.id]
          });
        } else {
          ingredInstance.set({
            'recipe_ids': [newRecipe.id],
            'Image': "",
            'Keywords': ingredKeywords.toList()
          });
        }
      });

      ingredientCollection
          .add({'Item': firestoreInstance.collection('food').doc(ingredInstance.id), 'Quantity': double.tryParse(amount.text), 'Unit': unit});
    }

    List<String> directions = [];
    for (TextEditingController dir in _directionControllers) {
      directions.add(dir.text);
    }

    allKeywords.addAll(getKeywords(recipeController.text.toLowerCase()));
    newRecipe.set({
      'CreationDate': FieldValue.serverTimestamp(),
      'Creator': firestoreInstance.collection('users').doc(this.user.docID),
      'Credit': this.user.name,
      'Directions': directions,
      'DocumentID': [newRecipe.id],
      'Keywords': allKeywords.toList(),
      'RecipeName': recipeController.text,
      'TotalTime': int.tryParse(totalTimeController.text)
    });
  }
}
