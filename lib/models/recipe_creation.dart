import 'dart:ffi';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../pantreeUser.dart';


// Used from https://www.technicalfeeder.com/2021/09/flutter-add-textfield-dynamically/
class RecipeCreator extends StatelessWidget {
  PantreeUser user;
  RecipeCreator({this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
          appBar: AppBar(title: Text("Create a Recipe"), backgroundColor: Colors.red[400]),
          body: InputForm(user: this.user)
    );
  }
}

class InputForm extends StatefulWidget {
  PantreeUser user;
  InputForm({this.user});

  @override
  State<StatefulWidget> createState() {return _InputForm(user: this.user);}
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
  List<DropdownButton> _unitFields = [];

  List<TextEditingController> _directionControllers = [];
  List<TextFormField> _directionFields = [];

  List<TextEditingController> _recipeNameControllers = [];
  List<TextFormField> _recipeName;

  List<TextEditingController> _totalTimeControllers = [];
  List<TextFormField> _totalTime;

  Widget pageOne() {
    final _recipeNameController = TextEditingController();
    _recipeNameControllers.add(_recipeNameController);
    final _totalTimeController = TextEditingController();
    _totalTimeControllers.add(_totalTimeController);

    String dropdownValue = dropDownValues[0];
    return Column(
      children: [
        TextFormField(
          controller: _recipeNameController,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            labelText: "Recipe name"
          ),
        ),
        TextFormField(
          controller: _totalTimeController,
          decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: "Total Time"
          ),
        ),
        _okButton("", pageTwo("Ingredient"))
      ]
    );
  }

  Widget pageTwo(String text) {
    return Scaffold(
        appBar: AppBar(title: Text(text), backgroundColor: Colors.red[400]),
        body: Column(
            children: [
              _addTile(text),
              Expanded(child: _ingredientsListView(text)),
              _okButton(text, pageThree("Direction"))
            ]
        )
    );
  }

  Widget pageThree(String text) {
    return Scaffold(
        appBar: AppBar(title: Text(text), backgroundColor: Colors.red[400]),
        body: Column(
            children: [
              _addTile(text),
              Expanded(child: _directionsListView(text)),
              _okButton(text)
            ]
        )
    );
  }

  @override
  Widget build(BuildContext context) {

    return pageOne();
  }

  @override
  void dispose() {
    for (final controller in _ingredientControllers) {
      controller.dispose();
    }

    for (final controller in _directionControllers) {
      controller.dispose();
    }

    for (final controller in _totalTimeControllers) {
      controller.dispose();
    }

    for (final controller in _recipeNameControllers) {
      controller.dispose();
    }

    super.dispose();
  }

  Widget _measurementDropdown() {
    String dropdownValue = dropDownValues[0];
    return DropdownButton<String>(
      value: dropdownValue,
      icon: const Icon(Icons.arrow_downward),
      iconSize: 24,
      elevation: 16,
      style: const TextStyle(color: Colors.deepPurple),
      underline: Container(
        height: 2,
        color: Colors.deepPurpleAccent,
      ),
      onChanged: (String newValue) {
        setState(() {
          dropdownValue = newValue;
        });
      },
      items: dropDownValues
          .map<DropdownMenuItem<String>>((String value) {
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
                borderRadius:
                BorderRadius.circular(50)),
            color: Colors.red[400],
            child: Center(child: Text("Add " + text,
                      style: TextStyle(
                          fontSize: 20,
                          color: Colors.white)),
                )))),
      onTap: () async {
        final controller = TextEditingController();
        final field = TextFormField(
          controller: controller,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            labelText: "Blank " + text,
          ),
        );
        final unit = _measurementDropdown();

        setState(() {
          if (text == "Direction") {
            _directionControllers.add(controller);
            _directionFields.add(field);
          } else {
            _ingredientControllers.add(controller);
            _ingredientFields.add(field);
            _unitFields.add(unit);
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
          child: Row(
            children: [
              Container(
                width: MediaQuery.of(context).size.width * 0.70,
                child: _ingredientFields[index],
              ),
              Container(
                width: MediaQuery.of(context).size.width * 0.25,
                child: _unitFields[index]
              ),
            ],
          )
        );
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

  bool addToDatabase() {
    // Make document for recipe within recipes
    // Get user ID path
    // Add CreationDate, Creator, Credit, Directions, DocumentID, Keywords, RecipeName, TotalTime
    // Create ingredients collection
    //    Create document based on each ingredient,
  }

  Widget _okButton(String text, [Widget nextPage]) {
    return ElevatedButton(
      onPressed: () async {
        if (nextPage == null) {
          addToDatabase();
          Navigator.of(context).pop();
          Navigator.of(context).pop();
          Navigator.of(context).pop();
        } else {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => nextPage));
        }
        setState(() {});
      },
      child: Text("Next"),
    );
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

