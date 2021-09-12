import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
  DocumentReference _selectedPantry; // private
  String _selectedPantryName; // private
  List<DocumentReference> _userPantryRefs; // private
  Map<String, DocumentReference> _pantryMap; // private NOTE: bad design - it will fuck with users collaborating on multiple pantries with the same name
  Stream _stream;
  // DocumentSnapshot cache;

  Future<dynamic> getData() async {
    //_selectedPantry = user.pantries[0]; // default pantry
    DocumentReference tempPantry;
    String tempName;

    await user.updateData();

    _userPantryRefs = List.from(
        user.pantries); // convert user pantry ID to list of pantry doc refs
    _pantryMap = Map<String, DocumentReference>(); // instantiate the map
    for (DocumentReference ref in _userPantryRefs) {
      // go through each doc ref and add to list of pantry names + map
      String pantryName = "";
      await ref.get().then((DocumentSnapshot snapshot) {
        pantryName = snapshot.data()['Name']; // get the pantry name as a string
      });
      // String pantryName = getPantryName(ref);
      // todo: check for [upcoming] 'primary' boolean val and set _selectedPantry/Name vals to that
      tempPantry = ref; // this will have to do for now
      tempName = pantryName;
      _pantryMap[pantryName] = ref; // map the doc ref to its name
    }

    // use setState() to force a call to build(). A very important piece of code.
    setState(() {
      _selectedPantry = tempPantry;
      _selectedPantryName = tempName;
    });
  }

  @override
  void initState() {
    super.initState();
    getData();
    _stream = firestoreInstance.collection('users')
        .doc(user.uid)
        .snapshots();
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

  @override
  Widget build(BuildContext context) {
    if (_selectedPantry == null) {
      // handle user with no pantries case todo: update with loading widget
      return Center(child: Text("No Pantries Found"));
    }

    // User pantry dropdown selector that listens for changes in users
    final makeDropDown = StreamBuilder(
        // initialData: cache,
        stream: _stream,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          // cache = snapshot.data;
          return Container(
              alignment: Alignment.topLeft,
              padding: EdgeInsets.only(left: 17.0),
              child: DropdownButton<String>(
                value: _selectedPantryName,
                items: _pantryMap.keys.map<DropdownMenuItem<String>>((val) {
                  return DropdownMenuItem<String>(
                    value: val,
                    child: Text(val),
                  );
                }).toList(),
                onChanged: (String value) {
                  setState(() {
                    _selectedPantry = _pantryMap[value];
                    _selectedPantryName = value;
                  });
                },
              ));
        });

    final makeAppBar = AppBar(
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
    );

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
                  elevation: 7.0,
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

    return Scaffold(appBar: makeAppBar, body: makeBody);
  }
}
