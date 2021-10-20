import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:pantree/models/custom_fab.dart';
import 'package:pantree/models/drawer.dart';
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

    await user.updateData(); // important: refreshes the user's data
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

    // very important: use setState() to force a call to build()
    setState(() {
      loading = false;
    });
    /*setState(() {
        _selectedPantry = tempPantry;
        _selectedPantryName = tempName;
      });
    */
  }

  setListener() {
    FirebaseFirestore.instance
        .collection("users")
        .doc(user.uid)
        .snapshots()
        .listen((event) {
      getData();
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

  Future<void> deleteItem(DocumentSnapshot ds) async {
    DocumentReference doc = ds.reference;
    await doc
        .delete()
        .then((value) => print("SUCCESS: $doc has been deleted"))
        .catchError((error) => print("FAILURE: couldn't delete $doc: $error"));
  }

  void createPantry(bool makePrimary) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => (NewPantry(
                  user: user,
                  makePrimary: makePrimary,
                ))));
  }

  void editPantry(String name) {
    print("NAME: $name");
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => (EditPantry(
                  user: user,
                  pantry: _selectedPantry,
                  name: name,
                  makePrimary: false,
                ))));
  }

  String formatDate(Timestamp time) {
    DateTime date = time.toDate();
    DateFormat formatter = DateFormat("MM/dd/yyyy");
    return formatter.format(date);
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
          stream: _selectedPantry.collection('Ingredients').snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData || snapshot.data == null)
              return Center(child: CircularProgressIndicator());
            return Expanded(
                child: ListView(
                    children: snapshot.data.docs.map<Widget>((doc) {
              return Container(
                child: Card(
                  elevation: 7.0,
                  margin: EdgeInsets.symmetric(horizontal: 15.0, vertical: 3.0),
                  child: ListTile(
                    leading: Icon(Icons.fastfood_rounded),
                    title: Text(
                      doc['Item'].id.toString().capitalizeFirstOfEach,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    subtitle: Container(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                          Text(
                            "Quantity: " +
                                doc['Quantity'].toString() +
                                " " +
                                doc['Unit'].toString().capitalizeFirstOfEach,
                            style: const TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w600),
                          ),
                          Text(
                            "Date Added: " + formatDate(doc['DateAdded']),
                            style: const TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w600),
                          ),
                        ])),
                    trailing: IconButton(
                      icon: Icon(Icons.delete, size: 20.0),
                      onPressed: (() {
                        showDeleteDialog(
                            context,
                            doc['Item'].id.toString().capitalizeFirstOfEach,
                            doc);
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
        drawer: PantreeDrawer(user: user),
        floatingActionButton: CustomFAB(
          color: Colors.lightBlue,
          icon: const Icon(Icons.add),
          onPressed: (() => {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            NewPantryItem(pantry: _selectedPantry)))
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
