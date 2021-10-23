import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:pantree/models/custom_fab.dart';
import 'package:pantree/models/drawer.dart';
import 'package:pantree/models/modules.dart';
import 'package:pantree/models/new_pantry_item.dart';
import '../pantreeUser.dart';
import '../models/drawer.dart';
import '../models/newPantry.dart';
import '../models/edit_pantry.dart';

extension StringExtension on String {
  String get inCaps =>
      this.length > 0 ? '${this[0].toUpperCase()}${this.substring(1)}' : '';
  String get allInCaps => this.toUpperCase();
  String get capitalizeFirstOfEach => this
      .replaceAll(RegExp(' +'), ' ')
      .split(" ")
      .map((str) => str.inCaps)
      .join(" ");
  String get capitalizeFirstLetter => (this?.isNotEmpty ?? false)
      ? '${this[0].toUpperCase()}${this.substring(1)}'
      : this;
  String capitalize() {
    if (this == null || this == "") {
      return "";
    }
    return "${this[0].toUpperCase()}${this.substring(1)}";
  }
}

class Pantry extends StatefulWidget {
  final PantreeUser user;
  Pantry({this.user});

  @override
  _PantryState createState() => _PantryState(user: user);
}

class _PantryState extends State<Pantry> {
  final PantreeUser user;
  _PantryState({this.user});

  final firestoreInstance = FirebaseFirestore.instance;
  DocumentReference _selectedPantry; // private
  String _selectedPantryName; // private
  Map<String, DocumentReference>
      _pantryMap; // private NOTE: bad design - it will fuck with users collaborating on multiple pantries with the same name
  // DocumentSnapshot cache;
  bool loading = true;

  @override
  void initState() {
    super.initState(); // start initState() with this
    getData().then((val) => {setPantry()});
    setListener();
    //pantryMain();
  }

  Future<dynamic> getData() async {
    DocumentReference tempPantry;
    String tempName;

    //await user.updateData(); // important: refreshes the user's data
    _pantryMap = Map<String, DocumentReference>(); // instantiate the map

    for (DocumentReference ref in user.pantries) {
      // go through each doc ref and add to list of pantry names + map
      String pantryName = "";
      await ref.get().then((DocumentSnapshot snapshot) {
        pantryName = snapshot.data()['Name']; // get the pantry name as a string
      });
      tempPantry = ref; // this will have to do for now
      tempName = pantryName;
      _pantryMap[pantryName] = ref; // map the doc ref to its name
    }

    // make sure widget hasn't been disposed before rebuild
    if (mounted) {
      setState(() { // setState() forces a call to build()
        loading = false;
        _selectedPantry = tempPantry;
        _selectedPantryName = tempName;
      });
    }
  }

  setListener() {
    FirebaseFirestore.instance
        .collection("users")
        .doc(user.uid)
        .snapshots()
        .listen((event) {
      if (event.data()['PantryIDs'].length != user.pantries.length) {
        user.pantries = event.data()['PantryIDs'];
        getData();
      }
    });
  }

  setPantry() {
    List<dynamic> primary = user.PPID;
    if (primary != null) {
      _pantryMap.forEach((k, v) => print('${k}: ${v}\n'));
      for (MapEntry e in _pantryMap.entries) {
        if (e.value == primary[0]) {
          setState(() {
            _selectedPantry = e.value;
            _selectedPantryName = e.key;
          });
        }
      }
    }
  }



  void createPantry(bool makePrimary) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => (NewItemList(
              user: user,
              usedByWidget: "Pantry",
              makePrimary: makePrimary,
            ))));
  }

  Future<void> editPantry(String name) async {
    var result = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => (EditPantry(
                  user: user,
                  pantry: _selectedPantry,
                  name: name,
                  makePrimary: false,
                ))));
    if(mounted) {
      setState(() {
        DocumentReference tempRef = _pantryMap[_selectedPantryName];
        _pantryMap.remove(_selectedPantryName);
        _pantryMap[result] = tempRef;
        _selectedPantryName = result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return pantryMain();
  }

  Widget pantryMain() {
    if (loading) {
      return Center(child: CircularProgressIndicator());
    }

    if (_selectedPantry == null) {
      // handle user with no pantries case - send to create a pantry screen
      return createLandingPage();
    }
    if (_selectedPantry == null) {
      return Center(child: CircularProgressIndicator());
    }

    // User pantry dropdown selector
    final makeDropDown = StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          return Container(
            padding: EdgeInsets.only(left: 17.0),
            child: DropdownButton<String>(
              value: _selectedPantryName,
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w600),
              icon: Icon(
                Icons.arrow_drop_down,
                color: Colors.white,
                size: 30.0,
              ),
              items: _pantryMap.keys.map<DropdownMenuItem<String>>((val) {
                return DropdownMenuItem<String>(
                    value: val,
                    child: Row(
                      //mainAxisAlignment: MainAxisAlignment.spaceAround,
                      //crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                            child: Text(val,
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600)),
                          ),
                        ),
                        /*Align(
                          alignment: Alignment(1.0, 0.5),
                          child: IconButton(
                            icon: Icon(Icons.edit),
                            onPressed: () => {editPantry(val)},
                          ),
                        ),*/
                      ],
                    ));
              }).toList(),
              onChanged: (String newVal) {
                setState(() {
                  _selectedPantry = _pantryMap[newVal];
                  _selectedPantryName = newVal;
                });
              },
              hint: Text("Select Pantry"),
              elevation: 0,
              underline: DropdownButtonHideUnderline(child: Container()),
              dropdownColor: Colors.lightBlue,
            ),
          );
        });

    // top appbar
    final makeAppBar = AppBar(
      backgroundColor: Color.fromRGBO(255, 190, 50, 1.0),
      title: makeDropDown,
      actions: <Widget>[
        Padding(
          padding: EdgeInsets.only(right: 20.0),
          // child: GestureDetector(
          //   onTap: () {},
          //   child: Icon(Icons.search, size: 26.0),
          // ),
        ),
        PopupMenuButton<String>(
          onSelected: (selected) {
            switch (selected) {
              case 'Create a new pantry':
                {
                  createPantry(false);
                }
                break;
              case 'Edit selected pantry':
                {
                  editPantry(_selectedPantryName);
                }
                break;
            }
          },
          itemBuilder: (BuildContext context) {
            return {'Create a new pantry', 'Edit selected pantry'}
                .map((String choice) {
              return PopupMenuItem<String>(
                value: choice,
                child: Text(choice),
              );
            }).toList();
          },
        ),
      ],
    );

    // list of cards
    final makeBody = Column(children: [
      // SizedBox(height: 10),
      // Sets up a stream builder to listen for changes inside the database.
      StreamBuilder(
          stream: _selectedPantry.collection('ingredients').snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData || snapshot.data == null)
              return Center(child: CircularProgressIndicator());
            return Expanded(
                child: ListView(
                    children: snapshot.data.docs.map<Widget>((doc) {
              return Container(
                child: itemCard(doc, context)
              );
            }).toList()));
          }),
    ]);

    return Scaffold(
        appBar: makeAppBar,
        body: makeBody,
        drawer: PantreeDrawer(user: user),
        floatingActionButton: CustomFAB(
          color: Colors.lightBlue,
          icon: const Icon(Icons.add),
          onPressed: (() => {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            NewFoodItem(itemList: _selectedPantry,usedByWidget: "Pantry",)))
              }),
        ));
  }

  Widget createLandingPage() {
    return Scaffold(
      appBar: AppBar(
        title: Text('New Pantry'),
        backgroundColor: Color.fromRGBO(255, 190, 50, 1.0),
      ),
      drawer: PantreeDrawer(user: user),
      body: Container(
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              child: Text(
                'Create your first Pantry!',
                style: TextStyle(color: Colors.black, fontSize: 24),
              ),
              margin: EdgeInsets.all(16),
            ),
            TextButton(
              onPressed: (() {
                createPantry(true);
              }),
              child: Text('Create Pantry'),
              style: TextButton.styleFrom(
                  primary: Colors.white, backgroundColor: Colors.lightBlue),
            ),
          ],
        ),
      ),
    );
  }
}
