import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../pantreeUser.dart';

// Used from https://www.technicalfeeder.com/2021/09/flutter-add-textfield-dynamically/
class RecipeCreator extends StatelessWidget {
  PantreeUser user;
  RecipeCreator({this.user});

  @override
  Widget build(BuildContext context) {
        return InputForm(user: this.user);
  }
}

class InputForm extends StatefulWidget {
  PantreeUser user;
  InputForm({this.user});

  @override
  State<StatefulWidget> createState() {
    return _InputForm(user: this.user);
  }
}

class _InputForm extends State<InputForm> {
  PantreeUser user;
  _InputForm({this.user});

  List<String> dropDownValues = [
    "teaspoon",
    "tablespoon",
    "cup",
    "ounce",
    "unit",
    "gallon",
    "can",
  ];

  List<TextEditingController> _ingredientControllers = [];
  List<TextFormField> _ingredientFields = [];
  List<TextFormField> _ingredientAmountFields = [];
  List<DropdownButton> _unitFields = [];

  List<TextEditingController> _directionControllers = [];
  List<TextFormField> _directionFields = [];

  TextEditingController recipeController = TextEditingController();
  TextFormField recipeField;

  TextEditingController totalTimeController = TextEditingController();
  TextFormField totalTimeField;

  final firestoreInstance = FirebaseFirestore.instance;

  bool overviewIsVisible = true;
  bool ingredientIsVisible = false;
  bool directionIsVisible = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: Text("Create a Recipe"), backgroundColor: Colors.red[400],
          actions: [
            IconButton(
                onPressed: () {
                  print(recipeController.text);
                  print(totalTimeController.text);

                  for (TextEditingController cont in _ingredientControllers) {
                    print(cont.text);
                  }

                  for (TextEditingController cont in _directionControllers) {
                    print(cont.text);
                  }

                  Navigator.of(context).pop();
                },
              icon: const Icon(Icons.check_box)
            )
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
            border: OutlineInputBorder(), labelText: "Recipe name"),
      );
    }

    if (totalTimeField == null) {
      totalTimeField = TextFormField(
        controller: totalTimeController,
        decoration: InputDecoration(
            border: OutlineInputBorder(), labelText: "Total time to cook (minutes)"),
      );
    }

    return Column(children: [
      SizedBox(height: 20),
      Container(
          width: MediaQuery.of(context).size.width * 0.9,
          child: recipeField
      ),
      SizedBox(height: 20),
      Container(
          width: MediaQuery.of(context).size.width * 0.9,
      child: totalTimeField
      ),
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

  Widget _measurementDropdown(String dropdownValue) {
    return DropdownButton<String>(
      value: dropdownValue,
      style: const TextStyle(color: Colors.red),
      onChanged: (String newValue) {
        setState(() {
          dropdownValue = newValue;
        });
      },
      items: dropDownValues.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    );
  }

  Widget _addTile(String text) {
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
      onTap: () async {
        final controller = TextEditingController();
        final field = TextFormField(
          controller: controller,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            labelText: text,
          ),
        );

        TextEditingController amountController;
        TextFormField amountField;
        DropdownButton unitField;
        if (text == "Ingredient") {
          amountController = TextEditingController();
          amountField = TextFormField(
            controller: amountController,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: "Amount"
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
            margin: EdgeInsets.all(5),
            child: Card(
            child:Column(
              children: [
                Container(
                  width: MediaQuery.of(context).size.width * 0.9,
                  child: _ingredientFields[index],
                ),
                Container(
                    width: MediaQuery.of(context).size.width * 0.25,
                    child: _unitFields[index]),
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
        if (i > j)
          continue;
        keywords.add(word.substring(i, j + 1));
      }

    return keywords;
  }

  Future<void> addToDatabase() {
    DocumentReference newRecipe = firestoreInstance.collection('recipes').doc();
    Set<String> allKeywords = {};
    for (TextEditingController ingred in _ingredientControllers) {
      Set<String> ingredKeywords = getKeywords(ingred.text.toLowerCase());
      allKeywords.addAll(ingredKeywords);
      DocumentReference ingredInstance = firestoreInstance.collection('food').doc(ingred.text.toLowerCase());

      ingredInstance.get()
          .then((docSnapshot) {
            if (docSnapshot.exists) {
              ingredInstance.update({
                  'recipe_ids' : [newRecipe.id]
              });
            } else {
              ingredInstance.set({
                  'recipe_ids' : [newRecipe.id],
                  'Image' : "",
                  'Keywords' : ingredKeywords.toList()
                });
            }
      });
    }

    List<String> directions = [];
    for (TextEditingController dir in _directionControllers) {
      directions.add(dir.text);
    }

    allKeywords.addAll(getKeywords(recipeController.text.toLowerCase()));
    newRecipe.set({
      'CreationDate': FieldValue.serverTimestamp(),
      'Creator': this.user.name,
      'Credit': this.user.name,
      'Directions': directions,
      'DocumentID': [newRecipe.id],
      'Keywords': allKeywords.toList(),
      'RecipeName': recipeController.text,
      'TotalTime': int.parse(totalTimeController.text)
    });
  }

  /*
  Widget _okButton(String text, [Widget nextPage]) {
    return ElevatedButton(
      onPressed: () async {
        String text = _ingredientControllers
            .where((element) => element.text != "")
            .fold("", (acc, element) => acc += "${element.text}\n");
        final alert = AlertDialog(
          title: Text("Count: ${_ingredientControllers.length}"),
          content: Text(text.trim()),
          actions: [
            TextButton(
              onPressed: () {
                if (nextPage == null) {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                } else {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => nextPage));
                }
              },
              child: Text("Next"),
            ),
          ],
        );
        await showDialog(
          context: context,
          builder: (BuildContext context) => alert,
        );
        setState(() {});
      },
      child: Text("Next"),
    );
  }

   */
}
