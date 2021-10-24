import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pantree/models/modules.dart';
import 'package:pantree/models/drawer.dart';
import '../pantreeUser.dart';
import '../models/exportList.dart';

class ShoppingList extends StatefulWidget {
  final PantreeUser user;
  const ShoppingList({Key key, this.user}) : super(key: key);
  // ShoppingList({this.user});

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
      _listMap; // private NOTE: bad design - it will fuck with users collaborating on multiple pantries with the same name

  @override
  void initState() {
    super.initState(); // start initState() with this
    getData();
    setListener();
  }

  Future<dynamic> getData() async {
    DocumentReference tempPantry;
    String tempName;

    _listMap = Map<String, DocumentReference>(); // instantiate the map
    for (DocumentReference ref in user.shoppingLists) {
      // go through each doc ref and add to list of list names + map
      String listName = "";
      await ref.get().then((DocumentSnapshot snapshot) {
        listName = snapshot.data()['Name']; // get the list name as a string
      });
      tempPantry = ref; // this will have to do for now
      tempName = listName;
      _listMap[listName] = ref; // map the doc ref to its name
    }

    // make sure widget hasn't been disposed before rebuild
    if (mounted) {
      setState(() { // setState() forces a call to build()
        _selectedList = tempPantry;
        _selectedListName = tempName;
      });
    }
  }

  //Listener for when a user changes! Re-Reads all the pantry Data!
  setListener() {
    FirebaseFirestore.instance
        .collection("users")
        .doc(user.uid)
        .snapshots()
        .listen((DocumentSnapshot event) {
      if (event.data()['ShoppingIDs'].length != user.shoppingLists.length) {
        user.shoppingLists = event.data()['ShoppingIDs'];
        getData();
      }
    });
  }

  void exportList() {
    if (user.pantries.length > 0) {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => (ExportList(
                  user: user,
                  list: _selectedList,
                  exportList: user.pantries))));
    } else {
      showError(context);
    }
  }

  void createNewList() {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => (NewItemList(
                  user: user,
                  usedByView: "Shopping List",
                  makePrimary: true,
                ))));
  }

  Future<void> editList() async {
    var result = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => (Edit(
              user: user,
              itemList: _selectedList,
              name: _selectedListName,
            ))));
    if(mounted && result != _selectedListName) {
      setState(() {
        DocumentReference tempRef = _listMap[_selectedListName];
        _listMap.remove(_selectedListName);
        _listMap[result] = tempRef;
        _selectedListName = result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (user.shoppingLists.length == 0) {
      return createLandingPage();
    }
    if (_selectedList == null) {
      return Center(child: CircularProgressIndicator());
    }

    // User pantry dropdown selector that listens for changes in users
    final makeDropDown = Container(
        padding: EdgeInsets.only(left: 17.0),
        child: DropdownButtonHideUnderline(
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
              });
            },
            hint: Text("Select List"),
            elevation: 0,
            dropdownColor: Colors.lightBlue,
          ),
        ));

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
                  createNewList();
                }
                break;
              case 'Edit selected list':
                {
                  editList();
                }
                break;
            }
          },
          itemBuilder: (BuildContext context) {
            return {'Create a new list', 'Edit selected list'}
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

    final makeBody = Column(children: [
      // Sets up a stream builder to listen for changes inside the database.
      StreamBuilder(
          stream: _selectedList.collection('ingredients').snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const Text('Loading....');
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
        drawer: PantreeDrawer(user: this.user),
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

  Widget createLandingPage() {
    return Scaffold(
      appBar: AppBar(title: Text('Shopping Lists')),
      drawer: PantreeDrawer(user: user),
      body: Container(
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              child: Text(
                'Create a Shopping List!',
                style: TextStyle(color: Colors.black, fontSize: 20),
              ),
              margin: EdgeInsets.all(16),
            ),
            TextButton(
              onPressed: () {
                createNewList();
              },
              child: Text('Create Shopping List'),
              style: TextButton.styleFrom(
                  primary: Colors.white,
                  backgroundColor: Colors.lightBlueAccent),
            ),
          ],
        ),
      ),
    );
  }

  showError(BuildContext context) {
    Widget okButton = TextButton(
      style: TextButton.styleFrom(primary: Colors.lightBlue),
      child: Text("Ok"),
      onPressed: () {
        Navigator.of(context, rootNavigator: true).pop();
      },
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("No Pantries"),
          content: Text("You don't have any pantries to export to!"),
          actions: [
            okButton,
          ],
        );
      },
    );
  }
}
