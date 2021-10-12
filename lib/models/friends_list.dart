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
    return Scaffold(
        appBar: AppBar(
          title: Text("Export Items to Pantry!"),
        ),
        body: Column(children: <Widget>[
          Text(friendsMap.toString()),
          Flexible(
            flex: 1,
            child: Container(
              width: double.maxFinite,
              child: TextButton(
                style: TextButton.styleFrom(backgroundColor: Colors.blue),
                onPressed: addFriend,
                child: Text(
                  'Add Friend',
                  style: TextStyle(fontSize: 14, color: Colors.black),
                ),
              ),
            ),
          ),
        ]));
  }

  void addFriend() {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
            (AddFriend(user: user))));
  }
}
