import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pantree/pantreeUser.dart';

class ExportList extends StatefulWidget {
  final PantreeUser user;
  final DocumentReference list;
  ExportList({this.user, this.list});
  @override
  _ExportListState createState() => _ExportListState(user: user, list: list);
}



class _ExportListState extends State<ExportList> {
  PantreeUser user;
  var items;
  List<QueryDocumentSnapshot> itemsRef;
  List<bool> itemSelected;
  String _selectedPantryName;
  DocumentReference _selectedPantry;
  final DocumentReference list;
  _ExportListState({this.user, this.list});
  Map<String, DocumentReference>
  _pantryMap;

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
      // todo: check for [upcoming] 'primary' boolean val and set _selectedPantry/Name vals to that
      tempPantry = ref; // this will have to do for now
      tempName = pantryName;
      _pantryMap[pantryName] = ref; // map the doc ref to its name
    }


    // very important: se setState() to force a call to build()
    setState(() {
      _selectedPantry = tempPantry;
      _selectedPantryName = tempName;
      list.collection("Ingredients").get().then((value) {
        setState(() {
          itemSelected = List.filled(value.docs.length, false);
          itemsRef = value.docs;
          items = value.docs.map<Widget>((e) {return createCard(e.data()['Item'].id.toString(),0);}).toList();
        });
      });

    });

  }

  Widget createCard(name,index) {
    return new Card(
      child: new Container(
        padding: new EdgeInsets.all(10.0),
        child: Column(
          children: <Widget>[
            new CheckboxListTile(
                activeColor: Colors.pink[300],
                dense: true,
                //font change
                title: new Text(
                  name,
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5
                  ),
                ),
                value: itemSelected[index],
                // secondary: Container(
                //   height: 50,
                //   width: 50,
                //   child: Image.network(
                //     listTileModel[index].img,
                //     fit: BoxFit.cover,
                //   ),
                // ),
                onChanged: (bool val) {
                  setState(() {
                    itemSelected[index] = val;
                  });
                })
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    getData();
  }

  @override
  Widget build(BuildContext context) {
    if(items == null) return const Text('Loading....');
    return Scaffold(
      appBar: AppBar(
        title: Text("Export Items to Pantry!"),
      ),
      body: Column(
        children: [DropdownButtonFormField<String>(
        value: _selectedPantryName,
        decoration: InputDecoration(
          filled: true,
          labelText: 'Pick a Pantry',
        ),
        style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w600),
        icon: Icon(
          Icons.arrow_drop_down,
          color: Colors.black,
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
            _selectedPantry = _pantryMap[newVal];
            _selectedPantryName = newVal;
          });
        },
        hint: Text("Select Pantry"),
        elevation: 0,
        dropdownColor: Colors.lightBlue,
      ),
        Expanded(
          child:
        ListView(
            children:items,))
        ]),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: exportChart,
          label: Text("Export To Pantry!"),
          backgroundColor: Colors.lightBlue,
          icon: const Icon(Icons.add_shopping_cart_outlined),
          //onPressed: (),
        )
    );
  }

bool exportChart(){
    try {
      itemsRef.forEach((element) {
        _selectedPantry.collection("Ingredients").add(
            {
              "Item": element.data()['Item'],
              "Quantity": element.data()['Quantity'],
            }).then((value) {
            element.reference.delete();
          });
        });
    } catch (e){
      return false;
    }
  return true;
}

  showAlertDialog(BuildContext context, String t,String m) async{

    // set up the button
    Widget signButton = TextButton(
      child: Text("Return to Lists"),
      onPressed: () {
        Navigator.of(context, rootNavigator: true).pop();
        Navigator.of(context).pop();
      },
    );

    Widget okButton = TextButton(
      child: Text("Stay"),
      onPressed: () {Navigator.of(context, rootNavigator: true).pop();},
    );
    var a = [
        signButton,
        okButton
      ];
    AlertDialog alert = AlertDialog(
        title: Text(t),
        content: Text(m),
        actions:a
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}