import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pantree/pantreeUser.dart';

class ExportList extends StatefulWidget {
  final PantreeUser user;
  final DocumentReference list;
  final List exportList;
  final bool removeItems;
  ExportList({this.user, this.list, this.exportList, this.removeItems = true});
  @override
  _ExportListState createState() => _ExportListState(user: user, list: list, exportList: exportList, removeItems: removeItems);
}

class _ExportListState extends State<ExportList> {
  PantreeUser user;
  final bool removeItems;
  var items;
  String img =
      "https://i2.wp.com/ceklog.kindel.com/wp-content/uploads/2013/02/firefox_2018-07-10_07-50-11.png";
  String _selectedPantryName;
  DocumentReference _selectedPantry;
  List exportList;
  final DocumentReference list;
  _ExportListState({this.user, this.list, this.exportList, this.removeItems});
  Map<String, DocumentReference> _pantryMap;

  Future<dynamic> getData() async {
    DocumentReference tempPantry;
    String tempName;

    await user.updateData(); // important: refreshes the user's data
    _pantryMap = Map<String, DocumentReference>(); // instantiate the map

    for (DocumentReference ref in exportList) {
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
      list.collection("ingredients").get().then((value) {
        setState(() {
          items = value.docs.map<CheckBoxListTileModel>((e) {
            return new CheckBoxListTileModel(
                img: img,
                title: e.data()['Item'].id.toString(),
                isCheck: false,
                ref: e);
          }).toList();
        });
      });
    });
  }

  @override
  void initState() {
    super.initState();
    getData();
  }

  @override
  Widget build(BuildContext context) {
    if (items == null) return const Text('Loading....');
    return Scaffold(
        appBar: AppBar(
          title: Text("Export Items to Pantry!"),
            actions: <Widget>[
              Padding(
                padding: EdgeInsets.only(right: 20.0),
                child: TextButton(
                  child: Text("Select All"),
                  style: TextButton.styleFrom(primary: Colors.white, textStyle: TextStyle(fontSize: 18)),
                  onPressed: selectAll,)
              ),
            ]
        ),
        body: Column(children: [
          DropdownButtonFormField<String>(
            value: _selectedPantryName,
            decoration: InputDecoration(
              filled: true,
              labelText: 'Pick a Pantry',
            ),
            style: TextStyle(
                color: Colors.black, fontSize: 20, fontWeight: FontWeight.w600),
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
            child: ListView.builder(
                itemCount: items.length,
                itemBuilder: (BuildContext context, int index) {
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
                                items[index].title,
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.5,
                                ),
                              ),
                              value: items[index].isCheck,
                              secondary: Container(
                                height: 50,
                                width: 50,
                                child: Image.network(
                                  items[index].img,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              onChanged: (bool val) {
                                setState(() {
                                  items[index].isCheck = val;
                                });
                              })
                        ],
                      ),
                    ),
                  );
                }),
          ),
        ]),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            showExportDialog(context);
          },
          label: Text("Export To Pantry!"),
          backgroundColor: Colors.lightBlue,
          icon: const Icon(Icons.add_shopping_cart_outlined),
          //onPressed: (),
        ));
  }

  bool exportChart() {
    try {
      items.forEach((element) {
        if (element.isCheck) {
          _selectedPantry.collection("ingredients").add({
            "Item": element.ref.data()['Item'],
            "Quantity": element.ref.data()['Quantity'],
          }).then((value) {
            if(removeItems) {
              element.ref.reference.delete();
            }
          });
        }
      });
    } catch (e) {
      return false;
    }
    return true;
  }
  selectAll() {
    items.forEach((element) {
      element.isCheck = true;
    });
    setState(() {

    });
  }
  showExportDialog(BuildContext context) {
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
        Navigator.of(context, rootNavigator: true).pop();
        showSuccessDialog(context, exportChart());
      },
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Are you sure?"),
          content: Text("Do you really want to Export Selected Items?"),
          actions: [
            cancelButton,
            okButton,
          ],
        );
      },
    );
  }

  showSuccessDialog(BuildContext context, bool) {
    Widget okButton = TextButton(
      style: TextButton.styleFrom(primary: Colors.lightBlue),
      child: Text("OK"),
      onPressed: () {
        Navigator.of(context, rootNavigator: true).pop();
        Navigator.of(context).pop();
      },
    );
    String t = "Error!";
    String m = "There was a problem exporting your Items. Try again later.";
    if (bool) {
      t = "Success!";
      m = "Items added to pantry!";
    }
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(t),
          content: Text(m),
          actions: [
            okButton,
          ],
        );
      },
    );
  }
}

class CheckBoxListTileModel {
  String img;
  String title;
  bool isCheck;
  QueryDocumentSnapshot ref;
  CheckBoxListTileModel({this.img, this.title, this.isCheck, this.ref});
}
