import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../pantreeUser.dart';

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
  DocumentReference _selectedPantry; // user's pantry is private, so use the _prefix
  String _selectedPantryName;
  List<DocumentReference> userPantryRefs;
  List<String> pantryNamesStr;
  Map<String, DocumentReference> pantryMap;

  dynamic data;

  Future<dynamic> getData() async {
    QuerySnapshot pantriesCollection = await FirebaseFirestore.instance.collection("pantries").get();
    // final CollectionReference pantriesCollection = FirebaseFirestore.instance.collection("pantries");
    final DocumentReference currPantryDoc = FirebaseFirestore.instance.collection("pantries").doc("Yqxw4fjgA8If7hc49ylF");
    
    userPantryRefs = List.from(user.pantries); // convert user pantry ID to list of pantry doc refs
    pantryNamesStr = <String>[]; // instantiate the list
    pantryMap = Map<String, DocumentReference>(); // instantiate the map
    for (DocumentReference ref in userPantryRefs) { // go through each doc ref and add to list of pantry names + map
      ref.get().then((snapshot) {
        pantryNamesStr.add(snapshot.data()['Name']);
        pantryMap[snapshot.data()['Name']] = ref; // map the doc ref to its name
        _selectedPantryName = snapshot.data()['Name'];
      });
    }

    await currPantryDoc.get().then<dynamic>((DocumentSnapshot snapshot) async {
      setState(() {
        _selectedPantry = currPantryDoc;
        
        if (snapshot.exists) {
          data = snapshot.data();
        }
      });
    });
  }

/*  void initialize() async {
    var document = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
    setState(() {
      _selectedPantry = user.pantries[0];
    });
  }*/

  @override
  void initState() {
    super.initState();
    // initialize();
    getData();
  }

/*  void setPantry(int index) async {
    var document = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
    setState(() {
      _selectedPantry = document['Pantry IDs'][index];
      _selectedIndex = index;
    });
  }*/

  void getPantryName(DocumentReference pantryRef) async {
    var document = pantryRef.get();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (_selectedPantry == null) {
      // handle user with no pantries case
      return Center(child: Text("No Pantries Found"));
    }

    final makeAppBar = AppBar(
      elevation: 0.1,
      backgroundColor: Color.fromRGBO(204, 51, 255, 1.0),
      title: Text("Pantree!"),
      actions: <Widget>[
        IconButton(
          icon: Icon(Icons.list),
          onPressed: () {},
        )
      ],
    );

    // User pantry dropdown selector that listens for changes in users
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
              alignment: Alignment.topLeft,
              padding: EdgeInsets.only(left: 17.0),
              child: DropdownButton<String>(
                value: _selectedPantryName,
                items: pantryMap.keys.map<DropdownMenuItem<String>>((val) {
                  return DropdownMenuItem<String>(
                    value: val,
                    child: Text(val.toString()),
                  );
                }).toList(),
                onChanged: (String value) {
                  setState(() {
                    //_selectedPantry = value;
                    _selectedPantry = pantryMap[value];
                    _selectedPantryName = value;
                  });
                  //setPantry(index);
                },
              ));
        });

    final makeBody = Column(children: [
      // Sets up a stream builder to listen for changes inside the database.
      StreamBuilder(
          stream: _selectedPantry.collection('Ingredients').snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const Text('Loading....');
            return Expanded(
                child: ListView(
                    children: snapshot.data.docs.map<Widget>((doc) {
              return Container(
                child: Card(
                  elevation: 8.0,
                  margin: EdgeInsets.symmetric(horizontal: 15.0, vertical: 3.0),
                  child: ListTile(
                    leading: Container(
                      child: Image.network(
                          "https://i2.wp.com/ceklog.kindel.com/wp-content/uploads/2013/02/firefox_2018-07-10_07-50-11.png"), //replace images with ones in firestore
                    ),
                    title: Text(
                      doc['Item'].id.toString().capitalizeFirstOfEach,
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      "Quantity: " + doc['Quantity'].toString(),
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              );
            }).toList()));
          }),
    ]);

    return Scaffold(
        appBar: AppBar(
          backgroundColor: Color.fromRGBO(255, 204, 102, 1.0),
          title: makeDropDown,
          actions: <Widget>[
            Padding(
              padding: EdgeInsets.only(right: 20.0),
              child: GestureDetector(
                onTap: () {},
                child: Icon(Icons.search, size: 26.0),
              ),
            ),
            PopupMenuButton<String>(
              // onSelected: handleClick,
              itemBuilder: (BuildContext context) {
                return {'Add new item', 'Filter'}.map((String choice) {
                  return PopupMenuItem<String>(
                    value: choice,
                    child: Text(choice),
                  );
                }).toList();
              },
            ),
          ],
        ),
        body: makeBody);
  }
}
