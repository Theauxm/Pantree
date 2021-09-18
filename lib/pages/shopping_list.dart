import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../pantreeUser.dart';
import '../models/drawer.dart';
import '../models/newShoppingList.dart';

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
  var _stream;


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
    _stream = FirebaseFirestore.instance.collection("users").doc(user.uid).snapshots().listen((event) {
        getData();
      }
    );
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

  void addNewItem() {}

  void createNewList() {
    Navigator.push(context, MaterialPageRoute(builder: (context) => (NewShoppingList(user: user,))));
  }

  @override
  Widget build(BuildContext context) {
    if (_selectedList == null) {
      // handle user with no pantries case todo: update with loading widget
      return Center(child: CircularProgressIndicator());
    }

    // User pantry dropdown selector that listens for changes in users
    final makeDropDown =  Container(
              padding: EdgeInsets.only(left: 17.0),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedListName,
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
            child: GestureDetector(
              onTap: () {},
              child: Icon(Icons.search, size: 26.0),
            ),
          ),
          PopupMenuButton<String>(
            onSelected: (selected) { createNewList();},
            itemBuilder: (BuildContext context) {
              return {'New List'}.map((String choice) {
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
          floatingActionButton: FloatingActionButton(
            backgroundColor: Colors.lightBlue,
            child: const Icon(Icons.add),
            onPressed: addNewItem,
          ));
    }
  }


/*

  List<CheckBoxListTileModel> listTileModel = CheckBoxListTileModel
      .getListItems();
Scaffold(
      appBar: AppBar(title: Text(this.user.name)),
      drawer: PantreeDrawer(user: this.user),
      body: Column (
        children: <Widget> [
          Expanded(
            child: ListView.builder(
                itemCount: listTileModel.length,
                itemBuilder: (BuildContext context, int index) {
                  return Dismissible(
                    key: Key(listTileModel[index].title),
                    onDismissed: (direction) {deleteItemFromList(index);},
                    child: new Card(
                      child: new Container(
                        padding: new EdgeInsets.all(10.0),
                        child: Column(
                          children: <Widget>[
                            new CheckboxListTile(
                                activeColor: Colors.pink[300],
                                dense: true,
                                //font change
                                title: new Text(
                                  listTileModel[index].title,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.5
                                  ),
                                ),
                                value: listTileModel[index].isCheck,
                                secondary: Container(
                                  height: 50,
                                  width: 50,
                                  child: Image.network(
                                    listTileModel[index].img,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                onChanged: (bool val) {
                                  itemCheck(val, index);
                                })
                          ],
                        ),
                      ),
                    )
                  );
              }),
          ),
          Padding(
            padding: EdgeInsets.all(20),
            child: TextField(
              controller: nameController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Add item to list',
              ),
              onEditingComplete: () {
                _signOut();//TODO: Remove this lmao once we have a real signout!
                addItemToList();},
            ),
          ),
        ]
      )
    );

      void itemCheck(bool val, int index) {
    setState(() {
      listTileModel[index].isCheck = val;
    });
  }

  void addItemToList() {
    setState(() {
      listTileModel.add(
          CheckBoxListTileModel(
              img: "https://i2.wp.com/ceklog.kindel.com/wp-content/uploads/2013/02/firefox_2018-07-10_07-50-11.png",
              title: nameController.text,
              isCheck: false)
      );
      nameController.clear();
    });
  }

  void deleteItemFromList(int index) {
    setState(() {
      listTileModel.removeAt(index);
    });
  }
}


class CheckBoxListTileModel {
  String img;
  String title;
  bool isCheck;

  CheckBoxListTileModel({this.img, this.title, this.isCheck});

  static List<CheckBoxListTileModel> getListItems() {
    return <CheckBoxListTileModel>[
      CheckBoxListTileModel(
          img: "https://i2.wp.com/ceklog.kindel.com/wp-content/uploads/2013/02/firefox_2018-07-10_07-50-11.png",
          title: "Fruit",
          isCheck: false),
      CheckBoxListTileModel(
          img: "https://i2.wp.com/ceklog.kindel.com/wp-content/uploads/2013/02/firefox_2018-07-10_07-50-11.png",
          title: "Eggs",
          isCheck: false),
      CheckBoxListTileModel(
          img: "https://i2.wp.com/ceklog.kindel.com/wp-content/uploads/2013/02/firefox_2018-07-10_07-50-11.png",
          title: "Bread",
          isCheck: false),
      CheckBoxListTileModel(
          img: "https://i2.wp.com/ceklog.kindel.com/wp-content/uploads/2013/02/firefox_2018-07-10_07-50-11.png",
          title: "Milk",
          isCheck: false),
      CheckBoxListTileModel(
          img: "https://i2.wp.com/ceklog.kindel.com/wp-content/uploads/2013/02/firefox_2018-07-10_07-50-11.png",
          title: "Chips",
          isCheck: false),
    ];
  }
}
 */