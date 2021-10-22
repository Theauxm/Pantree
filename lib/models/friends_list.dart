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
  Map<String, DocumentReference>
  pendingFriends;
  Map<String, DocumentReference>
  friendRequests;
  Future<dynamic> getFriends() async {
    if(await updateFriends(user.uid,user)) {
      friendsMap = Map<String, DocumentReference>();
      pendingFriends = Map<String, DocumentReference>();
      friendRequests = Map<String, DocumentReference>();
      //await user.updateData(); // important: refreshes the user's data// instantiate the map
      for (DocumentReference ref in user.friends.keys) {
        // go through each doc ref and add to list of pantry names + map
        String friendUsername = "";
        await ref.get().then((DocumentSnapshot snapshot) {
          friendUsername =
          snapshot.data()['Username']; // get the pantry name as a string
        });
        friendsMap[friendUsername] = ref;
      }
      for (DocumentReference ref in user.pendingFriends.keys) {
        // go through each doc ref and add to list of pantry names + map
        String friendUsername = "";
        await ref.get().then((DocumentSnapshot snapshot) {
          friendUsername =
          snapshot.data()['Username']; // get the pantry name as a string
        });
        pendingFriends[friendUsername] = ref;
      }
      for (DocumentReference ref in user.friendRequests.keys) {
        // go through each doc ref and add to list of pantry names + map
        String friendUsername = "";
        await ref.get().then((DocumentSnapshot snapshot) {
          friendUsername =
          snapshot.data()['Username']; // get the pantry name as a string
        });
        friendRequests[friendUsername] = ref;
      }
      // very important: se setState() to force a call to build()
      if(mounted) {setState(() {});}
    }
  }

  setListener() {
    FirebaseFirestore.instance
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
  Widget build(BuildContext context) {
    if(friendRequests == null){
      return Center(child: CircularProgressIndicator());
    }
    return Scaffold(
        appBar: AppBar(
          title: Text("Your Friends"),
        ),
        body: Column(children: <Widget>[
          buildFriends(friendsMap, true,user.friends),
          Text("Pending:"),
          buildFriends(pendingFriends,true,user.pendingFriends),
          Text("Requests:"),
          buildFriends(friendRequests, false,user.friendRequests)
        ]),
      floatingActionButton: FloatingActionButton(
      backgroundColor: Colors.green,
      child: const Icon(Icons.person_add),
      onPressed: addFriend,
    ),);
  }

  Widget buildFriends(Map map, bool remove, Map col){
    List keys = map.keys.toList();
    return
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
            trailing: makeIcon(remove, index, col, map, keys),
          ),
        );
      },
      itemCount: keys.length,
    ));
  }
  Widget makeIcon(b, index, col, map, keys){
    if (b) {
      return IconButton(
        icon: Icon(
          Icons.person_remove_alt_1_outlined,
          size: 20.0,
          color: Colors.red,),
        onPressed: () {
          removeFriend(
              col[map[keys[index]]],
              FirebaseFirestore.instance.doc('/users/'+user.uid),
              map[keys[index]]);
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
              col[map[keys[index]]],
              FirebaseFirestore.instance.doc('/users/'+user.uid),
              map[keys[index]]);
        }
      );
    }
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
    List allFriends = friendsMap.keys.toList();
    allFriends.addAll(pendingFriends.keys.toList());
    allFriends.addAll(friendRequests.keys.toList());
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                (AddFriend(user: user, friends: allFriends))));
  }
}
