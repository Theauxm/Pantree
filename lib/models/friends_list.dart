import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pantree/pantreeUser.dart';
import "package:pantree/models/add_friend.dart";

class FriendsList extends StatefulWidget {
  final PantreeUser user;
  FriendsList({this.user});

  @override
  FriendsListState createState() => FriendsListState(user: user);
}

// https://stackoverflow.com/questions/51607440/horizontally-scrollable-cards-with-snap-effect-in-flutter
class FriendsListState extends State<FriendsList> {
  final PantreeUser user;
  FriendsListState({this.user});

  Map<String, DocumentReference>
      friendsMap; // Friends Map, With their names and Doc Ref!

  Future<dynamic> getFriends() async {
    friendsMap = Map<String, DocumentReference>();
    //await user.updateData(); // important: refreshes the user's data// instantiate the map
    for (DocumentReference ref in user.friends) {
      // go through each doc ref and add to list of pantry names + map
      String friendUsername = "";
      await ref.get().then((DocumentSnapshot snapshot) {
        friendUsername =
            snapshot.data()['Username']; // get the pantry name as a string
      });
      friendsMap[friendUsername] = ref;
    }
    // very important: se setState() to force a call to build()
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    getFriends();
    //setListener();
  }

  @override
  Widget build(BuildContext context) {
    var keys = friendsMap.keys.toList();
    return Scaffold(
        appBar: AppBar(
          title: Text("Your Friends"),
        ),
        body: Column(children: <Widget>[
          Expanded(child:
          ListView.builder(
            itemBuilder: (context, index) {
              return Card(
                elevation: 7.0,
                margin: EdgeInsets.symmetric(horizontal: 15.0, vertical: 3.0),
                child: ListTile(
                  leading: Container(
                      child: Icon(
                    Icons.account_box,
                    size: 50,
                  )),
                  title: Text(
                    keys[index].toString(),
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  trailing: IconButton(
                    icon: Icon(
                      Icons.person_remove_alt_1_outlined,
                      size: 20.0,
                      color: Colors.red,
                    ),
                    onPressed: removeFriend,
                  ),
                ),
              );
            },
            itemCount: keys.length,
          )),
        ]),
      floatingActionButton: FloatingActionButton(
      backgroundColor: Colors.green,
      child: const Icon(Icons.person_add),
      onPressed: addFriend,
    ),);
  }
  void removeFriend(){

  }
  void addFriend() {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                (AddFriend(user: user, friends: friendsMap.keys.toList()))));
  }
}
