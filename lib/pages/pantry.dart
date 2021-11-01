import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pantree/models/modules.dart';
import 'package:pantree/models/custom_fab.dart';
import 'package:pantree/models/drawer.dart';
import '../pantreeUser.dart';

class Pantry extends StatefulWidget {
  final PantreeUser user;
  const Pantry({Key key, this.user}) : super(key: key);

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
    getData().then((val) => {setInitPantry()});
    setListener();
  }

  Future<dynamic> getData() async {
    // print('GETDATA() CALLED');
    DocumentReference tempPantry;
    String tempName;

    _pantryMap = Map<String, DocumentReference>(); // instantiate the map
    for (DocumentReference ref in user.pantries) {
      // go through each doc ref and add to list of pantry names + map
      String pantryName = "";
      await ref.get().then((DocumentSnapshot snapshot) {
        if (ref == user.PPID) {
          pantryName = snapshot.data()['Name'] + "*";
        } else {
          pantryName =
              snapshot.data()['Name']; // get the pantry name as a string
        }
      });
      tempPantry = ref; // this will have to do for now
      tempName = pantryName;
      _pantryMap[pantryName] = ref; // map the doc ref to its name
    }

    // make sure widget hasn't been disposed before rebuild
    if (mounted) {
      setState(() {
        // setState() forces a call to build()
        if (loading) loading = false;
        _selectedPantry = tempPantry;
        _selectedPantryName = tempName;
      });
    }
  }

  // Listener for when a user adds a pantry
  setListener() {
    FirebaseFirestore.instance
        .collection("users")
        .doc(user.uid)
        .snapshots()
        .listen((event) {
      bool update = false;
      if (event.data()['PantryIDs'].length != user.pantries.length) {
        print("INSIDE LISTENER --> PANTRIES");
        user.pantries = event.data()['PantryIDs'];
        update = true;
      }
      if (event.data()['PPID'].toString() != user.PPID.toString()) {
        print("INSIDE LISTENER --> PPID");
        user.PPID = event.data()['PPID'];
        //update = true;
        print("UPDATE: $update");
      }
      if (update) {
        getData();
      }
    });
  }

  setInitPantry() {
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

  void addCollaborator() {
    if(user.friends.length > 0) {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
              (AddNewCollaborator(
                user: user,
                usedByView: "Pantry",
                docRef: _selectedPantry,
              ))));
    } else{
      //TODO: Add popup telling them to get friends
    }
  }

  Future<void> editPantry() async {
    var result = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => (Edit(
                user: user,
                itemList: _selectedPantry,
                name: _selectedPantryName,
                usedByView: "Pantry"))));


    /*String normalizedPantryName = "";
    if (_selectedPantryName.endsWith("*")) {
      normalizedPantryName =
          _selectedPantryName.substring(0, _selectedPantryName.length - 1);
    } else {
      normalizedPantryName = _selectedPantryName;
    }
    print("RAW PANTRY NAME: $_selectedPantryName");
    print("NORMALIZED PANTRY NAME: $normalizedPantryName");*/
    print("RESULT: $result");
    if (result is List) {
      updatePantries(result[0], result[1], result[2]);
    }
  }

  Future<dynamic> updatePantries(
      String newName, bool primaryChanged, bool isPrimary) async {
    // print("PANTRY MAP BEFORE CLEAR: $_pantryMap");
    // print("USER PANTRIES BEFORE MAP CLEAR: ${user.pantries}");
    DocumentReference primaryPantry;
    String primaryPantryName;

    _pantryMap.clear();
    for (DocumentReference ref in user.pantries) {
      // repopulate pantry map
      String pantryName = "";
      await ref.get().then((DocumentSnapshot snapshot) {
        if (ref == user.PPID) {
          pantryName = snapshot.data()['Name'] + "*";
          primaryPantry = ref;
          primaryPantryName = pantryName;
        } else {
          pantryName = snapshot.data()['Name'];
        }
      });
      _pantryMap[pantryName] = ref; // map the doc ref to its name
    }
    print("REPOPULATED PANTRY MAP: $_pantryMap");

    if (mounted) {
      setState(() {
        if (isPrimary) {
          // covers both primary --> primary and non-primary --> primary cases
          _selectedPantry = primaryPantry;
          _selectedPantryName = primaryPantryName;
        } else if (!isPrimary && primaryChanged) {
          // primary --> non-primary
          // quietly stops the user from not having a primary pantry
          _selectedPantry = _pantryMap[newName + "*"];
          _selectedPantryName = newName + "*";
        } else {
          // non-primary --> non-primary
          _selectedPantry = _pantryMap[newName];
          _selectedPantryName = newName;
        }
      });
    }
  }

   Future<void> deletePantry(DocumentReference doc) async {
    // delete pantry from list of pantries
    await doc
        .delete()
        .then((value) => print("SUCCESS: $doc has been deleted from pantries"))
        .catchError((error) =>
            print("FAILURE: couldn't delete $doc from pantries: $error"));
    // delete pantry from user pantries
    await firestoreInstance
        .collection('users')
        .doc(user.uid)
        .update({
          'PantryIDs': FieldValue.arrayRemove([_selectedPantry])
        })
        .then((value) =>
            print("SUCCESS: $doc has been deleted from user pantries"))
        .catchError((error) =>
            print("FAILURE: couldn't delete $doc from user pantries: $error"));
    // if pantry is primary, remove it from PPID
    if (doc == user.PPID) {
      await firestoreInstance
          .collection('users')
          .doc(user.uid)
          .update({'PPID': FieldValue.delete()})
          .then((value) =>
              print("SUCCESS: $doc has been deleted from user pantries"))
          .catchError((error) => print(
              "FAILURE: couldn't delete $doc from user pantries: $error"));
      if (_pantryMap.isNotEmpty) {
        var entryList = _pantryMap.entries.toList();
        FirebaseFirestore.instance
            .collection("users")
            .doc(user.uid)
            .update({
          'PPID': entryList[0].value,
        }).catchError((error) =>
            print("Failed to set new primary pantry: $error"));
          updatePantries(entryList[0].key, true, true);
      }
    }
  }

  showDeleteDialog(
      BuildContext context, String pantryName, DocumentReference doc) {
    Widget cancelButton = TextButton(
        style: TextButton.styleFrom(
            backgroundColor: Colors.lightBlue, primary: Colors.white),
        child: Text("NO"),
        onPressed: () {
          Navigator.of(context, rootNavigator: true).pop();
        });

    Widget okButton = TextButton(
      style: TextButton.styleFrom(primary: Colors.lightBlue),
      child: Text("YES"),
      onPressed: () {
        deletePantry(doc);
        Navigator.of(context, rootNavigator: true).pop();
      },
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Are you sure?"),
          content: Text(
              "Do you really want to remove \"$pantryName\"? This cannot be undone."),
          actions: [
            cancelButton,
            okButton,
          ],
        );
      },
    );
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
      return createLandingPage(user, "Pantry", context);
    }

    // User pantry dropdown selector
    final makeDropDown = Container(
      padding: EdgeInsets.only(left: 17.0),
      child: DropdownButton<String>(
        value: _selectedPantryName,
        style: TextStyle(
            color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600),
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
              case 'Edit this pantry':
                {
                  editPantry();
                }
                break;
              case 'Remove this pantry':
                {
                  showDeleteDialog(context, _selectedPantryName, _selectedPantry);
                }
                break;
              case 'Add Collaborator to this pantry':
                {
                  addCollaborator();
                }
            }
          },
          itemBuilder: (BuildContext context) {
            return {
              'Create a new pantry',
              'Edit this pantry',
              'Remove this pantry',
              'Add Collaborator to this pantry'
            }.map((String choice) {
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
              return Container(child: itemCard(doc, context));
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
                        builder: (context) => NewFoodItem(
                              itemList: _selectedPantry,
                              usedByView: "Pantry",
                            )))
              }),
        ));
  }
}
