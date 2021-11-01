import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pantree/pantreeUser.dart';
import "package:pantree/models/add_friend.dart";
import "package:pantree/models/user_profile.dart";

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
  Map<String, DocumentReference>
  pendingFriends;
  Map<String, DocumentReference>
  friendRequests;
  StreamSubscription friendListener;
  bool loading = true;
  Future<dynamic> getFriends() async {
    bool done = await updateFriends(user.uid,user);
    if(done) {
      // very important: se setState() to force a call to build()
      if(mounted) {setState(() {
        loading = false;
      });}
    }
  }

  setListener() {
    friendListener = FirebaseFirestore.instance
        .collection("users")
        .doc(user.uid)
        .snapshots()
        .listen((event) {
      if(event.data()['pendingFriends'] != user.friendsCount || event.data()['Friends'] != user.pendingFriendsCount){
        getFriends();
      }
    });
  }

  @override
  void initState() {
    super.initState();
    getFriends();
    setListener();
  }

  @override
  void dispose(){
    friendListener.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if(loading){
      return Center(child: CircularProgressIndicator());
    }
    return Scaffold(
        appBar: AppBar(
          title: Text("Your Friends"),
        ),
        body: Column(children: <Widget>[
          buildFriends( true,user.friends),
          Text("Pending:"),
          buildFriends(true,user.pendingFriends),
          Text("Requests:"),
          buildFriends( false,user.friendRequests)
        ]),
      floatingActionButton: FloatingActionButton(
      backgroundColor: Colors.green,
      child: const Icon(Icons.person_add),
      onPressed: addFriend,
    ),);
  }

  Widget buildFriends( bool remove, List fl){
    //List keys = map.keys.toList();
    return
    Expanded(child:
    ListView.builder(
      itemBuilder: (context, index) {
        return Card(
          elevation: 7.0,
          margin: EdgeInsets.symmetric(horizontal: 15.0, vertical: 3.0),
          child: ListTile(
            leading: Container(
                child: IconButton(
                  icon: Icon(
                    Icons.account_box,
                    size: 30,
                  ),
                    onPressed:(){
                    profileClicked(map, keys, index);
                    },
                )),
            title: Text(
              fl[index][2].toString(),
              style: const TextStyle(
                  fontSize: 16, fontWeight: FontWeight.w600),
            ),
            trailing: makeIcon(remove, index, fl),
          ),
        );
      },
      itemCount: fl.length,
    ));
  }
  Widget makeIcon(b, index, fl){
    if (b) {
      return IconButton(
        icon: Icon(
          Icons.person_remove_alt_1_outlined,
          size: 20.0,
          color: Colors.red,),
        onPressed: () {
          removeFriend(
              fl[index][0],
              FirebaseFirestore.instance.doc('/users/'+user.uid),
              fl[index][1]);
        },
      );
    } else{
      return IconButton(
        icon: Icon(
          Icons.person_add_alt,
          size: 20.0,
          color: Colors.green,),
        onPressed: (){
          acceptRequest(
              fl[index][0],
              FirebaseFirestore.instance.doc('/users/'+user.uid),
              fl[index][1]);
        }
      );
    }
  }

  void profileClicked(map, keys, index){
    print('clicked');
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
            (user_profile(profileRef: map[keys[index]], status: 'pending'))));
    //TODO route the user to the clicked profile
  }
  void removeFriend(DocumentReference d,DocumentReference u, DocumentReference f){
    u.update({'Friends': FieldValue.increment(-1)});
    d.delete();
  }

  void acceptRequest(DocumentReference d,DocumentReference u, DocumentReference f){
    u.update(
        {
          'PendingFriends': FieldValue.increment(-1),
          'Friends': FieldValue.increment(1)
        });
    f.update(
        {
          'PendingFriends': FieldValue.increment(-1),
          'Friends': FieldValue.increment(1)
        });
    d.update({'accepted': true});
  }
  void addFriend() {
    List allFriends = [];
    for(var i = 0; i < widget.user.friends.length; i++){
      allFriends.add(widget.user.friends[i][2]);
    }
    for(var i = 0; i < widget.user.pendingFriends.length; i++){
      allFriends.add(widget.user.pendingFriends[i][2]);
    }
    for(var i = 0; i < widget.user.friendRequests.length; i++){
      allFriends.add(widget.user.friendRequests[i][2]);
    }
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                (AddFriend(user: user, friends: allFriends))));
  }
}
