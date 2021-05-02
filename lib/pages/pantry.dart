import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class pantry extends StatefulWidget {

  @override
  _pantryState createState() => _pantryState();
}

class _pantryState extends State<pantry> {


  @override
  Widget build(BuildContext context) {
    return StreamBuilder( //Sets up a stream builder to listen for changes inside the database.
      // stream: FirebaseFirestore.instance.collection('pantries').doc(
      //     _selectedPantry).snapshots(), //Where its listening!
      //stream: FirebaseFirestore.instance.(_selectedPantry).snapshots(),
        //stream: _selectedPantry.collection('Ingredients').snapshots(),
        stream: FirebaseFirestore.instance.collection('pantries').doc('Yqxw4fjgA8If7hc49ylF').collection('Ingredients').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Text('Loading....');
          //return _buildPantry(context, snapshot);
          return new ListView(children: snapshot.data.docs.map<Widget>((doc){
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
          }).toList());
        });
  }
}
