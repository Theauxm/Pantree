import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pantree/pantreeUser.dart';
import 'package:material_floating_search_bar/material_floating_search_bar.dart';
import 'package:pantree/models/dialogs.dart';

class AddFriend extends StatefulWidget {
  final PantreeUser user;
  final List friends;
  AddFriend({this.user, this.friends});
  @override
  AddFriendState createState() => AddFriendState(user: user, friends: friends);
}

// https://stackoverflow.com/questions/51607440/horizontally-scrollable-cards-with-snap-effect-in-flutter
class AddFriendState extends State<AddFriend> {
  final PantreeUser user;
  final List friends;
  AddFriendState({this.user, this.friends});
  FloatingSearchBarController controller;
  String searchedFriend;

  @override
  void initState() {
    super.initState();
    controller = FloatingSearchBarController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: FloatingSearchBar(
          controller: controller,
          body: FloatingSearchBarScrollNotifier(
            child: Column(
              children: [
                SizedBox(height: MediaQuery.of(context).size.height * 0.12),
                FriendSearchResultsList(user: user,currentFriends: friends, searchedFriend: searchedFriend,)
              ],
            ),
          ),
          transition: CircularFloatingSearchBarTransition(),
          physics: BouncingScrollPhysics(),
          title: Text(
            'Search for a friend...',
            style: Theme.of(context).textTheme.headline6,
          ),
          hint: 'Begin by typing a friends name....',
          actions: [
            FloatingSearchBarAction.searchToClear(),
          ],
          onSubmitted: (query) {
            setState(() {
              searchedFriend = query;
            });
            controller.close();
          },
          builder: (context, transition) {
            return;//Little floating tab under serach bar.
          },
        ),
        );
  }

}

class FriendSearchResultsList extends StatelessWidget {
  final String searchedFriend;
  final PantreeUser user;
  final List currentFriends;

  const FriendSearchResultsList({
    Key key,
    @required this.searchedFriend,
    @required this.currentFriends,
    @required this.user,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (searchedFriend == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.people_alt,
              size: 64,
            ),
            Text(
              //text in the middle
              '',
              style: Theme.of(context).textTheme.headline5,
            )
          ],
        ),
      );
    }
    List doNotInclude = [];
    doNotInclude.addAll(currentFriends);
    doNotInclude.add(user.name);
    return Expanded(
        child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .limit(10)
                .where('Username',  isGreaterThanOrEqualTo: searchedFriend)
                .where('Username', isLessThan: searchedFriend + 'z')
                .where('Username', whereNotIn: doNotInclude)
                .snapshots(),
            builder: (BuildContext context,
                AsyncSnapshot<QuerySnapshot> querySnapshot) {
              if (querySnapshot.hasError)
                return Text(
                    "Could not show any Friends, please try again in a few seconds");

              if (querySnapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else {
                return ListView.builder(
                  itemBuilder: (context, index) {
                    QueryDocumentSnapshot friend =
                    querySnapshot.data.docs[index];
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
                          friend['Username'].toString(),
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                        trailing: IconButton(
                          icon: Icon(
                              Icons.person_add_alt,
                              size: 20.0,
                              color: Colors.green,),
                          onPressed: ()
                            {
                              makeRequest(context, friend.reference);
                            }
                        ),
                      ),

                    );
                  },
                  itemCount: querySnapshot.data.docs.length,
                );
              }
            }));
  }

  void makeRequest(context, DocumentReference friend) async{
    try {
      DocumentReference currentUser = FirebaseFirestore.instance.doc('/users/'+user.uid);
              await FirebaseFirestore.instance.collection("friendships").add({
                "accepted": false,
                "users": [currentUser, friend],
              }).then((value) =>
              {
                Dialogs.friendRequestSent(context, "Friend Request sent to "+ friend.toString())
              });

    } catch (e) {
    }
  }
}
