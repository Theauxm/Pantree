import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ShoppingList extends StatefulWidget {
  @override
  _ListState createState() => _ListState();
}

class _ListState extends State<ShoppingList> with AutomaticKeepAliveClientMixin<ShoppingList> {
  List<CheckBoxListTileModel> listTileModel = CheckBoxListTileModel.getListItems();

  // for adding a new list item
  TextEditingController nameController = TextEditingController();

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
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
  }

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
  }

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