import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pantree/pantreeUser.dart';

class AddFriend extends StatefulWidget {
  final PantreeUser user;
  AddFriend({this.user});

  @override
  AddFriendState createState() => AddFriendState(user: user);
}

// https://stackoverflow.com/questions/51607440/horizontally-scrollable-cards-with-snap-effect-in-flutter
class AddFriendState extends State<AddFriend> {
  final PantreeUser user;
  AddFriendState({this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Add Friend!"),
        ),
        body: Column(children: <Widget>[
          Text(user.friends.toString()),
        ]));
  }

  void makeRequest() {
  }
}
