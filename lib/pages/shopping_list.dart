import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../pantreeUser.dart';
import '../models/drawer.dart';
import '../models/newShoppingList.dart';
import '../models/exportList.dart';
import '../models/new_list_item.dart';

class ShoppingList extends StatefulWidget {
  final PantreeUser user;
  ShoppingList({this.user});

  @override
  _ListState createState() => _ListState(user: user);
}

class _ListState extends State<ShoppingList> {
  final PantreeUser user;
  _ListState({this.user});

  final firestoreInstance = FirebaseFirestore.instance;
  DocumentReference _selectedList; // private
  String _selectedListName; // private
  Map<String, DocumentReference>
      _pantryMap; // private NOTE: bad design - it will fuck with users collaborating on multiple pantries with the same name
  // DocumentSnapshot cache;

  Future<dynamic> getData() async {
    DocumentReference tempPantry;
    String tempName;

    await user.updateData(); // important: refreshes the user's data
    _pantryMap = Map<String, DocumentReference>(); // instantiate the map

    for (DocumentReference ref in user.shoppingLists) {
      // go through each doc ref and add to list of pantry names + map
      String pantryName = "";
      await ref.get().then((DocumentSnapshot snapshot) {
        pantryName = snapshot.data()['Name']; // get the pantry name as a string
      });
      // todo: check for [upcoming] 'primary' boolean val and set _selectedPantry/Name vals to that
      tempPantry = ref; // this will have to do for now
      tempName = pantryName;
      _pantryMap[pantryName] = ref; // map the doc ref to its name
    }

    // very important: se setState() to force a call to build()
    setState(() {
      _selectedList = tempPantry;
      _selectedListName = tempName;
    });
  }

  //Listener for when a user changes! Re-Reads all the pantry Data!
  setListener() {
    FirebaseFirestore.instance
        .collection("users")
        .doc(user.uid)
        .snapshots()
        .listen((event) {
      getData();
    });
  }

  @override
  void initState() {
    super.initState();
    getData();
    setListener();
  }

  // for adding a new list item
  TextEditingController nameController = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  void addNewItem() {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => NewListItem(list: _selectedList)));
  }

  void createNewList() {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => (NewShoppingList(
                  user: user,
                ))));
  }

  void exportList() {
    if(user.pantries.length > 0) {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
              (ExportList(user: user, list: _selectedList))));
    } else{
      showError(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_selectedList == null) {
      // handle user with no pantries case todo: update with loading widget
      return createLandingPage();
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
            items: _pantryMap.keys.map<DropdownMenuItem<String>>((val) {
              return DropdownMenuItem<String>(
                value: val,
                child: Text(val),
              );
            }).toList(),
            onChanged: (String newVal) {
              setState(() {
                _selectedList = _pantryMap[newVal];
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
            createNewList();
          },
          itemBuilder: (BuildContext context) {
            return {'Create New List'}.map((String choice) {
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
          stream: _selectedList.collection('Ingredients').snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const Text('Loading....');
            return Expanded(
                child: ListView(
                    children: snapshot.data.docs.map<Widget>((doc) {
              return Container(
                child: Card(
                  elevation: 7.0,
                  margin: EdgeInsets.symmetric(horizontal: 15.0, vertical: 3.0),
                  child: ListTile(
                    leading: Container(
                      child: Image.network(
                          "https://i2.wp.com/ceklog.kindel.com/wp-content/uploads/2013/02/firefox_2018-07-10_07-50-11.png"), //replace images with ones in firestore
                    ),
                    title: Text(
                      doc['Item'].id.toString(),
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      "Quantity: " + doc['Quantity'].toString(),
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.delete, size: 20.0),
                      onPressed: (() {
                        showDeleteDialog(
                            context, doc['Item'].id.toString(), doc);
                      }),
                    ),
                  ),
                ),
              );
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
                onPressed: addNewItem,
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
                'Create A Shopping List!!',
                style: TextStyle(color: Colors.black, fontSize: 20),
              ),
              margin: EdgeInsets.all(16),
            ),
            TextButton(
              onPressed: () {
                createNewList();
              },
              child: Text('Create Shopping List'),
              style: TextButton.styleFrom(primary: Colors.white,
              backgroundColor: Colors.lightBlueAccent),
            ),
          ],
        ),
      ),
    );
  }

  showDeleteDialog(BuildContext context, String item, DocumentSnapshot ds) {
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
        deleteItem(ds);
        Navigator.of(context, rootNavigator: true).pop();
      },
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Are you sure?"),
          content:
              Text("Do you really want to delete \"$item\" from your pantry?"),
          actions: [
            cancelButton,
            okButton,
          ],
        );
      },
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
          content:
          Text("You don't have any pantries to export to!"),
          actions: [
            okButton,
          ],
        );
      },
    );
  }

  Future<void> deleteItem(DocumentSnapshot ds) async {
    DocumentReference doc = ds.reference;
    await doc
        .delete()
        .then((value) => print("SUCCESS: $doc has been deleted"))
        .catchError((error) => print("FAILURE: couldn't delete $doc: $error"));
  }
}
