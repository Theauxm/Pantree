import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../pantreeUser.dart';

extension StringExtension on String {
  String get inCaps => this.length > 0 ?'${this[0].toUpperCase()}${this.substring(1)}':'';
  String get allInCaps => this.toUpperCase();
  String get capitalizeFirstOfEach => this.replaceAll(RegExp(' +'), ' ').split(" ").map((str) => str.inCaps).join(" ");
  String get capitalizeFirstLetter => (this?.isNotEmpty ?? false) ? '${this[0].toUpperCase()}${this.substring(1)}' : this;
  String capitalize() {
    if (this == null || this == "") {return "";}
    return "${this[0].toUpperCase()}${this.substring(1)}";
  }
}
  PantreeUser user;
  pantry({this.user});


class Pantry extends StatefulWidget {
  final User user;
  Pantry({this.user});
  @override
  _PantryState createState() => _PantryState(user: user);
}

class _PantryState extends State<Pantry> {
  int _selectedIndex;
  //Widget _selectedPantry = FirebaseFirestore.instance.collection('pantries').doc('Yqxw4fjgA8If7hc49ylF').collection('Ingredients').snapshots();
  DocumentSnapshot _userDocSnap;
  DocumentReference _selectedPantry;
  List _pantryNames;

  @override
  void initState() {
    _selectedIndex = 0;
    super.initState();
    initialize();
    //setPantryNames();
  }

  void initialize() async {
    var document = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
    setState(() {
      _selectedPantry = document['Pantry IDs'][0];
    });
    //_selectedPantry = document['Pantry IDs'][0];
  }

  void setPantry(int index) async {
    var document = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
    setState(() {
      _selectedPantry = document['Pantry IDs'][index];
      _selectedIndex = index;
    });
  }

  void getPantryName(DocumentReference pantryRef) async {
    var document = pantryRef.get();
    setState(() {});
  }


  PantreeUser user;
  _PantryState({this.user});
  @override
  Widget build(BuildContext context) {
    if (_selectedPantry == null) {
      // handle user with no pantries case
      return Center(child: Text("No Pantries Found"));
    }

    final makeBody = Column(children: [
      // User pantry dropdown selector that listens for changes in users
      StreamBuilder(
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
                child: DropdownButton<DocumentReference>(
                  value: _selectedPantry,
                  items: snapshot.data['Pantry IDs']
                      .map<DropdownMenuItem<DocumentReference>>((value) {
                    return DropdownMenuItem<DocumentReference>(
                      value: value,
                      child: Text(value.path),
                    );
                  }).toList(),
                  onChanged: (DocumentReference value) {
                    setState(() {
                      _selectedPantry = value;
                    });
                    //setPantry(index);
                  },
                ));
          }),

      // Sets up a stream builder to listen for changes inside the database.
      StreamBuilder(
          // stream: FirebaseFirestore.instance.collection('pantries').doc(
          //     _selectedPantry).snapshots(), //Where its listening!
          //stream: FirebaseFirestore.instance.(_selectedPantry).snapshots(),
          stream: _selectedPantry.collection('Ingredients').snapshots(),
          //stream: FirebaseFirestore.instance.collection('pantries').doc('Yqxw4fjgA8If7hc49ylF').collection('Ingredients').snapshots(),
          //stream: FirebaseFirestore.instance.collection('users').doc(user.uid).('Ingredients').snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData)
              return const Text(
                  'Loading....');
            //return _buildPantry(context, snapshot);
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
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      "Quantity: " + doc['Quantity'].toString(),
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              );
            }).toList()));
          }),
    ]);

    return Scaffold(body: makeBody);
  }
}
