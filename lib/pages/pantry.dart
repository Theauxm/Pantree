import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pantree/models/dialogs.dart';
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
      _pantryMap;// private
  Map<String, bool>
  _pantryMapOwner;// private NOTE: bad design - it will fuck with users collaborating on multiple pantries with the same name
  bool loading = true;
  bool isOwner = false;

  @override
  void initState() {
    super.initState(); // start initState() with this
    getData().then((val) => {setInitPantry()});
    setListener();
  }

  Future<dynamic> getData() async {
    print('PANTRY GETDATA() CALLED');
    DocumentReference tempPantry;
    String tempName;
    bool tempBool;
    _pantryMap = Map<String, DocumentReference>();
    _pantryMapOwner = Map<String, bool>();// instantiate the map
    for (DocumentReference ref in user.pantries) {
      // go through each doc ref and add to list of pantry names + map
      String pantryName = "";
      bool tempIsOwner = false;
      await ref.get().then((DocumentSnapshot snapshot) {

        if(snapshot.data()['Owner'].id == widget.user.uid){
          tempIsOwner = true;
        }
        if (ref == user.PPID) {
          pantryName = snapshot.data()['Name'] + "*";
        } else {
          pantryName =
              snapshot.data()['Name']; // get the pantry name as a string
        }
      });
      tempPantry = ref; // this will have to do for now
      tempName = pantryName;
      tempBool = tempIsOwner;
      _pantryMap[pantryName] = ref;
      _pantryMapOwner[pantryName] = tempIsOwner;// map the doc ref to its name
    }

    // make sure widget hasn't been disposed before rebuild
    if (mounted) {
      setState(() {
        // setState() forces a call to build()
        if (loading) loading = false;
        isOwner = tempBool;
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
      }
      if (update) {
        getData();
      }
    });
  }

  setInitPantry() {
    DocumentReference primary = user.PPID;
    if (primary != null) {
      for (MapEntry e in _pantryMap.entries) {
        if (e.value == primary) {
          setState(() {
            _selectedPantry = e.value;
            _selectedPantryName = e.key;
            isOwner = _pantryMapOwner[e.key];
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
    if(isOwner) {
      if (user.friends.length > 0) {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                (AddNewCollaborator(
                  user: user,
                  usedByView: "Pantry",
                  docRef: _selectedPantry,
                ))));
      } else {
        Dialogs.showError(context, "No Friends", "You can't add a collaborator to this pantry because you don't have any friends!");
      }
    } else{
      Dialogs.showError(context, "Permission Denied", "You are not the owner so you can't add a collaborator to this pantry!");
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
                usedByView: "Pantry",
                isOwner: isOwner))));


    /*String normalizedPantryName = "";
    if (_selectedPantryName.endsWith("*")) {
      normalizedPantryName =
          _selectedPantryName.substring(0, _selectedPantryName.length - 1);
    } else {
      normalizedPantryName = _selectedPantryName;
    }
    print("RAW PANTRY NAME: $_selectedPantryName");
    print("NORMALIZED PANTRY NAME: $normalizedPantryName");*/
    //print("RESULT: $result");
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
    _pantryMapOwner.clear();
    for (DocumentReference ref in user.pantries) {
      // repopulate pantry map
      String pantryName = "";
      bool ownerBool = false;
      await ref.get().then((DocumentSnapshot snapshot) {
        if (ref == user.PPID) {
          pantryName = snapshot.data()['Name'] + "*";
          primaryPantry = ref;
          primaryPantryName = pantryName;
        } else {
          pantryName = snapshot.data()['Name'];
        }
        if(snapshot.data()['Owner'].id == widget.user.uid){
          ownerBool = true;
        }
      });
      _pantryMap[pantryName] = ref;
      _pantryMapOwner[pantryName] = ownerBool;// map the doc ref to its name
    }
    print("REPOPULATED PANTRY MAP: $_pantryMap");

    if (mounted) {
      setState(() {
        if (isPrimary) {
          // covers both primary --> primary and non-primary --> primary cases
          _selectedPantry = primaryPantry;
          _selectedPantryName = primaryPantryName;
          isOwner = _pantryMapOwner[primaryPantryName];

        } else if (!isPrimary && primaryChanged) {
          // primary --> non-primary
          // quietly stops the user from not having a primary pantry
          _selectedPantry = _pantryMap[newName + "*"];
          _selectedPantryName = newName + "*";
          isOwner = _pantryMapOwner[newName + "*"];
        } else {
          // non-primary --> non-primary
          _selectedPantry = _pantryMap[newName];
          _selectedPantryName = newName;
          isOwner = _pantryMapOwner[newName];
        }
      });
    }
  }

   Future<void> deletePantry(DocumentReference doc) async {
    print("INSIDE DELETEPANTRY");
    // delete pantry from list of pantries
     if(isOwner) {
       var snap = await doc.get();
       List altUsers = snap.data()['AltUsers'];
       altUsers.forEach((element) {removePantryFromUser(element.id, doc);});
       await doc
           .delete()
           .then((value) =>
           print("SUCCESS: $doc has been deleted from pantries"))
           .catchError((error) =>
           print("FAILURE: couldn't delete $doc from pantries: $error"));
     }
     removePantryFromUser(user.uid, doc);// delete pantry from user pantries
  }

  removePantryFromUser(id, doc) async{

    // if pantry is primary, remove it from PPID
    var tempUser = await firestoreInstance
        .collection('users')
        .doc(id).get();
    var tempPPID = tempUser.data()['PPID'];
    if (doc == tempUser.data()['PPID']) {
      tempPPID = null;
      for(int i = 0; i< tempUser.data()['PantryIDs'].length; i++){
        if(tempUser.data()['PantryIDs'][i] != doc){
          tempPPID = tempUser.data()['PantryIDs'][i];
          break;
        }
    }
      }
    await firestoreInstance
        .collection('users')
        .doc(id)
        .update({
      'PPID': tempPPID,
      'PantryIDs': FieldValue.arrayRemove([_selectedPantry])
    }).then((value) =>
        print("SUCCESS: $doc has been deleted from user pantries"))
        .catchError((error) =>
        print("FAILURE: couldn't delete $doc from user pantries: $error"));
    }
  showDeleteDialog(
      BuildContext context, String pantryName, DocumentReference doc) {
    Widget cancelButton = TextButton(
        style: TextButton.styleFrom(primary: Colors.red),
        child: Text("NO"),
        onPressed: () {
          Navigator.of(context, rootNavigator: true).pop();
        });

    Widget yesButton = TextButton(
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
            yesButton,
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
            isOwner = _pantryMapOwner[newVal];
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
              case 'Add Collaborator':
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
              'Add Collaborator'
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
              return Container(child: itemCard(doc, context, _selectedPantry));
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
