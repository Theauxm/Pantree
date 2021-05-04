import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class pantry extends StatefulWidget {

  final User user;
  pantry({this.user});
  @override
  _pantryState createState() => _pantryState(user: user);
}

class _pantryState extends State<pantry> {
  int _selectedIndex;
  //Widget _selectedPantry = FirebaseFirestore.instance.collection('pantries').doc('Yqxw4fjgA8If7hc49ylF').collection('Ingredients').snapshots();
  DocumentSnapshot _userDocSnap;
  DocumentReference _selectedPantry;
  List _pantryNames;

  @override
  void initState(){
    _selectedIndex = 0;
    super.initState();
    initialize();
    //setPantryNames();
  }

  void initialize() async{
    var document = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    setState(() {
      _selectedPantry = document['Pantry IDs'][0];
    });
    //_selectedPantry = document['Pantry IDs'][0];
  }
  void setPantry(int index) async{
    var document = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    setState(() {
      _selectedPantry = document['Pantry IDs'][index];
      _selectedIndex = index;
    });
  }
  void getPantryName (DocumentReference pantryRef)async{
    var document = pantryRef.get();
    setState(() {

    });

  }


  final User user;
  _pantryState({this.user});
  @override
  Widget build(BuildContext context) {
    if(_selectedPantry == null){
      return Center ( child: Text("No Pantries Found"));
    }
    return Scaffold(
      body:
      Column (
       children: [
      StreamBuilder(
        stream: FirebaseFirestore.instance.collection('users').doc(user.uid).snapshots(),
        builder: (context, snapshot) {
          return
            Container(
                alignment: Alignment.topLeft,
                padding: new EdgeInsets.only(left: 17.0),
                child: DropdownButton<DocumentReference>(
            value: _selectedPantry,
            items:  snapshot.data['Pantry IDs'].map<DropdownMenuItem<DocumentReference>>((value) {
              return new DropdownMenuItem<DocumentReference>(
                value: value,
                child: new Text(value.path),
              );
            }).toList(),
            onChanged: (DocumentReference value) {
              setState(() {
                _selectedPantry = value;
              });
              //setPantry(index);
            },
          )
            );
        }
      ),


      StreamBuilder( //Sets up a stream builder to listen for changes inside the database.
      // stream: FirebaseFirestore.instance.collection('pantries').doc(
      //     _selectedPantry).snapshots(), //Where its listening!
      //stream: FirebaseFirestore.instance.(_selectedPantry).snapshots(),
        stream: _selectedPantry.collection('Ingredients').snapshots(),
        //stream: FirebaseFirestore.instance.collection('pantries').doc('Yqxw4fjgA8If7hc49ylF').collection('Ingredients').snapshots(),
        //stream: FirebaseFirestore.instance.collection('users').doc(user.uid).('Ingredients').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Text('Loading....');
          //return _buildPantry(context, snapshot);
          return Expanded(child:
            new ListView(children: snapshot.data.docs.map<Widget>((doc){
            return Container(
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide()),
              ),
              child: ListTile(
                leading: new Container (
                  decoration: BoxDecoration (
                    border: Border.all (
                      width: 2,
                    ),
                  ),
                  child: Image.network("https://i2.wp.com/ceklog.kindel.com/wp-content/uploads/2013/02/firefox_2018-07-10_07-50-11.png"), //replace images with ones in firestore
                ),
                title: new Text(doc['Item'].id),
                subtitle: new Text("Quantity: " + doc['Quantity'].toString()),
              ),
            );
          }).toList())
          );
        }),
        ]
      ),
    );
  }
}
