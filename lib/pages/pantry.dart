import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pantree/models/modules.dart';
import 'package:pantree/models/custom_fab.dart';
import 'package:pantree/models/drawer.dart';
import '../pantreeUser.dart';

class Pantry extends StatefulWidget {
  final PantreeUser user;
  const Pantry ({Key key, this.user}) : super(key: key);

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
  bool loading = true;

  @override
  void initState() {
    super.initState(); // start initState() with this
    getData().then((val) => {setPantry()});
    setListener();
  }

  Future<dynamic> getData() async {
    DocumentReference tempPantry;
    String tempName;

    _pantryMap = Map<String, DocumentReference>(); // instantiate the map
    for (DocumentReference ref in user.pantries) {
      // go through each doc ref and add to list of pantry names + map
      String pantryName = "";
      await ref.get().then((DocumentSnapshot snapshot) {
        if (ref == user.PPID) {
          pantryName = snapshot.data()['Name'] + "*";
        }
        else {
          pantryName = snapshot.data()['Name']; // get the pantry name as a string
        }
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
    DocumentReference primary = user.PPID;
    if (primary != null) {
      _pantryMap.forEach((k, v) => print('${k}: ${v}\n'));
      for (MapEntry e in _pantryMap.entries) {
        if (e.value == primary) {
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
              usedByView: "Pantry",
              makePrimary: makePrimary,
            ))));
  }

  Future<void> editPantry() async {
    var result = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => (Edit(
                  user: user,
                  itemList: _selectedPantry,
                  name: _selectedPantryName,
                usedByView: "Pantry"
                ))));
    if(mounted && result != _selectedPantryName) {
      setState(() {
        DocumentReference tempRef = _pantryMap[_selectedPantryName];
        _pantryMap.remove(_selectedPantryName);
        _pantryMap[result] = tempRef;
        _selectedPantryName = result;
        //getData();
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
      return createLandingPage(user,"Pantry", context);
    }

    // User pantry dropdown selector
    final makeDropDown = Container(
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
                  editPantry();
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
                            NewFoodItem(itemList: _selectedPantry,usedByView: "Pantry",)))
              }),
        ));
  }
}
