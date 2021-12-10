import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pantree/pantreeUser.dart';

class ExportList extends StatefulWidget {
  final PantreeUser user;
  final DocumentReference list;
  final List exportList;
  final String exportingToName;
  final bool removeItems;
  ExportList(
      {Key key,
      this.user,
      this.list,
      this.exportList,
      this.removeItems = true,
      this.exportingToName})
      : super(key: key);
  @override
  _ExportListState createState() => _ExportListState();
}

class _ExportListState extends State<ExportList> {
  var items;
  String _selectedListName;
  DocumentReference _selectedList;
  Map<String, DocumentReference> _listMap;

  Future<dynamic> getData() async {
    DocumentReference tempList;
    String tempName;

    await widget.user.updateData(); // important: refreshes the user's data
    _listMap = Map<String, DocumentReference>(); // instantiate the map

    for (DocumentReference ref in widget.exportList) {
      // go through each doc ref and add to list of pantry names + map
      String listName = "";
      await ref.get().then((DocumentSnapshot snapshot) {
        listName = snapshot.data()['Name']; // get the pantry name as a string
      });
      tempList = ref; // this will have to do for now
      tempName = listName;
      _listMap[listName] = ref; // map the doc ref to its name
    }

    _selectedList = tempList;
    _selectedListName = tempName;
    widget.list.collection("ingredients").get().then((value) {
      if (mounted) {
        setState(() {
          items = value.docs.map<CheckBoxListTileModel>((e) {
            return new CheckBoxListTileModel(
              title: e.data()['Item'].id.toString(),
              isCheck: false,
              ref: e,
            );
          }).toList();
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    getData();
  }

  @override
  Widget build(BuildContext context) {
    if (items == null) return Center(child: CircularProgressIndicator());
    return Scaffold(
        appBar: AppBar(
            title: Text('Export to ${widget.exportingToName}'),
            actions: <Widget>[
              Padding(
                  padding: EdgeInsets.only(right: 42.0),
                  child: IconButton(
                    icon: Icon(Icons.check_box),
                    onPressed: selectAll,
                  )),
            ]),
        body: Container(
            margin: EdgeInsets.all(17.0),
            child: Column(children: [
              DropdownButtonFormField<String>(
                value: _selectedListName,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  labelText: '${widget.exportingToName} to export to:',
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
                hint: Text("Select ${widget.exportingToName}"),
                elevation: 0,
                dropdownColor: Colors.lightBlue[200],
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
                                    child: Icon(Icons.fastfood_rounded),
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
            ])),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            showExportDialog(context);
          },
          label: Text("Export To ${widget.exportingToName}!"),
          backgroundColor: Colors.lightBlue,
          icon: const Icon(Icons.add_shopping_cart_outlined),
          //onPressed: (),
        ));
  }

  bool exportChart() {
    DateTime now = new DateTime.now();
    DateTime date = new DateTime(now.year, now.month, now.day);
    try {
      items.forEach((element) {
        if (element.isCheck) {
          _selectedList.collection("ingredients").add({
            "Item": element.ref.data()['Item'],
            "Quantity": element.ref.data()['Quantity'],
            'Unit': element.ref.data()['Unit'],
            'DateAdded': date
          }).then((value) {
            if (widget.removeItems) {
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
    bool allTrue = true;
    for (var element in items) {
      if (!element.isCheck) {
        allTrue = false;
        break;
      }
    }

    items.forEach((element) {
      element.isCheck = !allTrue;
    });
    setState(() {});
  }

  showExportDialog(BuildContext context) {
    Widget noButton = TextButton(
        style: TextButton.styleFrom(primary: Colors.red),
        child: Text("NO"),
        onPressed: () {
          Navigator.of(context, rootNavigator: true).pop();
        });

    Widget yesButton = TextButton(
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
          content: Text("Do you really want to export the selected items?"),
          actions: [
            noButton,
            yesButton,
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
      t = "Great Success!";
      m = "The selected items have been added to your ${widget.exportingToName.toLowerCase()}!";
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
  String title;
  bool isCheck;
  QueryDocumentSnapshot ref;
  CheckBoxListTileModel({this.title, this.isCheck, this.ref});
}
