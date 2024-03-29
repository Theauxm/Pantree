import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pantree/models/dialogs.dart';
import 'package:pantree/models/modules.dart';
import 'package:pantree/models/drawer.dart';
import '../pantreeUser.dart';
import '../models/exportList.dart';

class ShoppingList extends StatefulWidget {
  final PantreeUser user;
  const ShoppingList({Key key, this.user}) : super(key: key);

  @override
  _ListState createState() => _ListState(user: user);
}

class _ListState extends State<ShoppingList> {
  final PantreeUser user;
  _ListState({this.user});

  final firestoreInstance = FirebaseFirestore.instance;
  DocumentReference _selectedList; // private
  String _selectedListName; // private
  int listsLength;
  Map<String, DocumentReference>
      _listMap; // private NOTE: bad design - it will fuck with users collaborating on multiple lists with the same name
  Map<String, bool> _listMapOwner;
  bool loading = true;
  bool isOwner = false;

  @override
  void initState() {
    super.initState(); // start initState() with this
    getData().then((val) => {setInitList()});
    setListener();
  }

  Future<dynamic> getData() async {
    print('SL GETDATA() CALLED'); // DEBUG
    DocumentReference tempPantry;
    String tempName;
    bool tempBool;
    _listMap = Map<String, DocumentReference>();
    _listMapOwner = Map<String, bool>(); // instantiate the map
    for (DocumentReference ref in user.shoppingLists) {
      // go through each doc ref and add to list of list names + map
      String listName = "";
      bool tempIsOwner = false;
      await ref.get().then((DocumentSnapshot snapshot) {
        if (snapshot.data()['Owner'].id == widget.user.uid) {
          tempIsOwner = true;
        }
        if (ref == user.PSID) {
          listName = snapshot.data()['Name'] + "*";
        } else {
          listName = snapshot.data()['Name']; // get the list name as a string
        }
      });
      /* This will have to do for now */
      tempPantry = ref;
      tempName = listName;
      tempBool = tempIsOwner;
      _listMap[listName] = ref;
      _listMapOwner[listName] = tempIsOwner; // map the doc ref to its name
    }

    // make sure widget hasn't been disposed before rebuild
    if (mounted) {
      setState(() {
        // setState() forces a call to build()
        if (loading) loading = false;
        isOwner = tempBool;
        _selectedList = tempPantry;
        _selectedListName = tempName;
      });
    }
  }

  // Listener for when a user updates their lists collection or changes PSID
  setListener() {
    FirebaseFirestore.instance
        .collection("users")
        .doc(user.uid)
        .snapshots()
        .listen((event) {
      bool update = false;
      if (event.data()['ShoppingIDs'].length != user.shoppingLists.length) {
        user.shoppingLists = event.data()['ShoppingIDs'];
        update = true;
      }
      if (event.data()['PSID'].toString() != user.PSID.toString()) {
        user.PSID = event.data()['PSID'];
      }
      if (update) {
        getData();
      }
    });
  }

  // Handler for exporting a list to pantry
  void exportList() {
    if (user.pantries.length > 0) {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => (ExportList(
                  user: user,
                  list: _selectedList,
                  exportList: user.pantries,
                  exportingToName: "Pantry"))));
    } else {
      Dialogs.showError(
          context, "No Pantries", "You don't have any pantries to export to! ");
    }
  }

  // Sets up initial list and PSID
  setInitList() {
    DocumentReference primary = user.PSID;
    if (primary != null) {
      for (MapEntry e in _listMap.entries) {
        if (e.value == primary) {
          setState(() {
            _selectedList = e.value;
            _selectedListName = e.key;
            isOwner = _listMapOwner[e.key];
          });
        }
      }
    }
  }

  // Handler for creating a new list
  void createNewList(bool makePrimary) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => (NewItemList(
                  user: user,
                  usedByView: "Shopping List",
                  makePrimary: makePrimary,
                ))));
  }

  // Handler for adding a list collaborator
  void addCollaborator() {
    if (isOwner) {
      if (user.friends.length > 0) {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => (AddNewCollaborator(
                      user: user,
                      usedByView: "Shopping List",
                      docRef: _selectedList,
                    ))));
      } else {
        Dialogs.showError(context, "No Friends",
            "You can't add a collaborator to this shopping list because you don't have any friends!");
      }
    } else {
      Dialogs.showError(context, "Permission Denied",
          "You are not the owner so you can't add a collaborator to this shopping list!");
    }
  }

  Future<void> editList() async {
    var result = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => (Edit(
                  user: user,
                  itemList: _selectedList,
                  name: _selectedListName,
                  usedByView: "Shopping List",
                  isOwner: isOwner,
                ))));
    if (result is List) {
      updateLists(result[0], result[1], result[2]);
    }
  }

  Future<dynamic> updateLists(
      String newName, bool primaryChanged, bool isPrimary) async {
    DocumentReference primaryList;
    String primaryListName;

    _listMapOwner.clear();
    _listMap.clear();
    for (DocumentReference ref in user.shoppingLists) {
      // repopulate list map
      String listName = "";
      bool ownerBool = false;
      await ref.get().then((DocumentSnapshot snapshot) {
        if (ref == user.PSID) {
          listName = snapshot.data()['Name'] + "*";
          primaryList = ref;
          primaryListName = listName;
        } else {
          listName = snapshot.data()['Name'];
        }
        if (snapshot.data()['Owner'].id == widget.user.uid) {
          ownerBool = true;
        }
      });
      _listMap[listName] = ref; // map the doc ref to its name
      _listMapOwner[listName] = ownerBool;
    }

    if (mounted) {
      setState(() {
        if (isPrimary) {
          // covers both primary --> primary and non-primary --> primary cases
          _selectedList = primaryList;
          _selectedListName = primaryListName;
          isOwner = _listMapOwner[primaryListName];
        } else if (!isPrimary && primaryChanged) {
          // primary --> non-primary
          // quietly stops the user from not having a primary list
          _selectedList = _listMap[newName + "*"];
          _selectedListName = newName + "*";
          isOwner = _listMapOwner[newName + "*"];
        } else {
          // non-primary --> non-primary
          _selectedList = _listMap[newName];
          _selectedListName = newName;
          isOwner = _listMapOwner[newName];
        }
      });
    }
  }

/*  Future<void> deleteList(DocumentReference doc) async {
    // delete list from list of shopping lists
    await doc
        .delete()
        .then((value) =>
            print("SUCCESS: $doc has been deleted from shopping lists"))
        .catchError((error) =>
            print("FAILURE: couldn't delete $doc from shopping lists: $error"));
    // delete list from user shopping lists
    await firestoreInstance
        .collection('users')
        .doc(user.uid)
        .update({
          'ShoppingIDs': FieldValue.arrayRemove([_selectedList])
        })
        .then((value) =>
            print("SUCCESS: $doc has been deleted from user shopping lists"))
        .catchError((error) => print(
            "FAILURE: couldn't delete $doc from user shopping lists: $error"));
    // if list is primary, remove it from PSID
    if (doc == user.PSID) {
      await firestoreInstance
          .collection('users')
          .doc(user.uid)
          .update({'PSID': FieldValue.delete()})
          .then((value) =>
              print("SUCCESS: $doc has been deleted from user shopping lists"))
          .catchError((error) => print(
              "FAILURE: couldn't delete $doc from user shopping lists: $error"));
      if (_listMap.isNotEmpty) {
        var entryList = _listMap.entries.toList();
        FirebaseFirestore.instance.collection("users").doc(user.uid).update({
          'PSID': entryList[0].value,
        }).catchError(
            (error) => print("Failed to set new primary list: $error"));
        updateLists(entryList[0].key, true, true);
      }
    }
  }*/

  Future<void> deleteList(DocumentReference doc) async {
    if (isOwner) { // only delete if user is owner
      var snap = await doc.get();
      List altUsers = snap.data()['AltUsers'];
      altUsers.forEach((element) { // delete list from collaborators' lists
        removeListFromUser(element.id, doc);
      });
      await doc
          .delete()
          .then((value) =>
              print("SUCCESS: $doc has been deleted from Shopping Lists"))
          .catchError((error) =>
              print("FAILURE: couldn't delete $doc from Shopping Lists: $error"));
    }
    removeListFromUser(user.uid, doc);
  }

  // remove this list from user's lists
  removeListFromUser(id, doc) async {
    // if list is primary, remove it from PSID
    var tempUser = await firestoreInstance.collection('users').doc(id).get();
    var tempPSID = tempUser.data()['PSID'];
    if (doc == tempUser.data()['PSID']) {
      tempPSID = null;
      for (int i = 0; i < tempUser.data()['ShoppingIDs'].length; i++) {
        if (tempUser.data()['ShoppingIDs'][i] != doc) {
          tempPSID = tempUser.data()['ShoppingIDs'][i];
          break;
        }
      }
    }
    await firestoreInstance
        .collection('users')
        .doc(id)
        .update({
          'PSID': tempPSID,
          'ShoppingIDs': FieldValue.arrayRemove([_selectedList])
        })
        .then((value) =>
            print("SUCCESS: $doc has been deleted from user Shopping List"))
        .catchError((error) => print(
            "FAILURE: couldn't delete $doc from user Shopping List: $error"));
  }

  showDeleteDialog(
      BuildContext context, String listName, DocumentReference doc) {
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
        deleteList(doc);
        Navigator.of(context, rootNavigator: true).pop();
      },
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Are you sure?"),
          content: Text(
              "Do you really want to remove \"$listName\"? This cannot be undone."),
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
    return listMain();
  }

  Widget listMain() {
    if (loading) {
      return Center(child: CircularProgressIndicator());
    }
    if (_selectedList == null) {
      // handle user with no lists case - send to create a list screen
      return createLandingPage(user, "Shopping List", context);
    }

    // User list dropdown selector
    final makeDropDown = Container(
      padding: EdgeInsets.only(left: 17.0),
      child: DropdownButton<String>(
        value: _selectedListName,
        style: TextStyle(
            color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600),
        icon: Icon(
          Icons.arrow_drop_down,
          color: Colors.white,
          size: 30.0,
        ),
        items: _listMap.keys.map<DropdownMenuItem<String>>((val) {
          return DropdownMenuItem<String>(
            value: val,
            child: Text(val),
          );
        }).toList(),
        onChanged: (String newVal) {
          setState(() {
            _selectedList = _listMap[newVal];
            _selectedListName = newVal;
            isOwner = _listMapOwner[newVal];
          });
        },
        hint: Text("Select List"),
        elevation: 0,
        underline: DropdownButtonHideUnderline(child: Container()),
        dropdownColor: Colors.lightBlue,
      ),
    );

    // Top appbar
    final makeAppBar = AppBar(
      title: makeDropDown,
      actions: <Widget>[
        Padding(
          padding: EdgeInsets.only(right: 20.0),
          //  child: GestureDetector(
          //    onTap: () {},
          // //   child: Icon(Icons.search, size: 26.0),
          //  ),
        ),
        PopupMenuButton<String>(
          onSelected: (selected) {
            switch (selected) {
              case 'Create a new list':
                {
                  createNewList(false);
                }
                break;
              case 'Edit this list':
                {
                  editList();
                }
                break;
              case 'Remove this list':
                {
                  showDeleteDialog(context, _selectedListName, _selectedList);
                }
                break;
              case 'Add Collaborator':
                {
                  addCollaborator();
                }
                break;
            }
          },
          itemBuilder: (BuildContext context) {
            return {
              'Create a new list',
              'Edit this list',
              'Remove this list',
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

    // List of cards
    final makeBody = Column(children: [
      // Sets up a stream builder to listen for changes inside the database.
      StreamBuilder(
          stream: _selectedList.collection('ingredients').snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData || snapshot.data == null)
              return Center(child: CircularProgressIndicator());
            return Expanded(
                child: ListView(
                    children: snapshot.data.docs.map<Widget>((doc) {
              return Container(child: itemCard(doc, context, _selectedList));
            }).toList()));
          }),
    ]);

    return Scaffold(
        appBar: makeAppBar,
        body: makeBody,
        drawer: PantreeDrawer(user: user),
        floatingActionButton: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              FloatingActionButton(
                backgroundColor: Colors.lightBlue,
                child: const Icon(Icons.shopping_cart),
                onPressed: exportList,
              ),
              SizedBox(
                height: 10,
              ),
              FloatingActionButton(
                backgroundColor: Colors.lightBlue,
                child: const Icon(Icons.add),
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => NewFoodItem(
                                itemList: _selectedList,
                                usedByView: "Shopping List",
                              )));
                },
              ),
            ]));
  }
}
