import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class PantreeUser {
  var name;
  var email;

  //(the token we need for our database)
  var uid;

  //**Stuff from database
  var friends;
  var pantries;
  var recipes;
  var shoppingLists;
  var posts;
  var PPID;
  var PSID;
  var pendingFriends;
  var friendRequests;


  //this is from the FirebaseAuth, and contains info related from Authentication
  //likely will not change ever.
  PantreeUser() {
    try {
      User u = FirebaseAuth.instance.currentUser;

      this.uid = u.uid;
      this.email = u.email;

    } catch(e){
      print(e.toString());
    }
  }

  //this function is used to update/sync data in the app from the database
  Future<void> updateData() async {
    await FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser.uid).get()
        .then((DocumentSnapshot documentSnapshot) =>
    {
      if (documentSnapshot.exists) {
        this.name = documentSnapshot.data()['Username'],
        this.shoppingLists = documentSnapshot.data()['ShoppingIDs'],
        this.recipes = documentSnapshot.data()['RecipeIDs'],
        this.pantries = documentSnapshot.data()['PantryIDs'],
        this.posts = documentSnapshot.data()['PostIDs'],
        this.PPID = documentSnapshot.data()['PPID'],
        this.PSID = documentSnapshot.data()['PSID'],
      }
    });
  }
}

getUserProfile() async {
  PantreeUser theUser = new PantreeUser();
  DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser.uid).get();
  int count = 0;
  while(documentSnapshot.data() == null){
    documentSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser.uid).get();
    count++;
    //Failing to load in current user document properly 10 times causes signout to prevent unlimited reads
    if (count > 10){
      return FirebaseAuth.instance.signOut();
    }
  }
  while(documentSnapshot.data()['Username'] == null){
    documentSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser.uid).get();
    count++;
    //Failing to load in current user document properly 10 times causes signout to prevent unlimited reads
    if (count > 10){
      return FirebaseAuth.instance.signOut();
    }
  }
  getFriends(documentSnapshot.id, theUser);
  theUser.name = documentSnapshot.data()['Username'];
  theUser.shoppingLists = documentSnapshot.data()['ShoppingIDs'];
  theUser.recipes = documentSnapshot.data()['RecipeIDs'];
  theUser.pantries = documentSnapshot.data()['PantryIDs'];
  theUser.posts = documentSnapshot.data()['PostIDs'];
  theUser.PPID = documentSnapshot.data()['PPID'];
  theUser.PSID = documentSnapshot.data()['PSID'];
  return theUser;
}

getFriends (String id, PantreeUser user) async{
  List friendsList = [];
  List pending = [];
  List requested = [];
  DocumentReference ref = FirebaseFirestore.instance.doc('/users/'+id);
  var friends = await FirebaseFirestore.instance
      .collection('friendships')
      .where('users',  arrayContains: ref).get();
  friends.docs.forEach((element) {
    if(element.data()['accepted']){
      if(element.data()['users'][0] == ref) {
        friendsList.add(element.data()['users'][1]);
      } else{
        friendsList.add(element.data()['users'][0]);
      }
    } else{
      if(element.data()['users'][0] == ref) {
        pending.add(element.data()['users'][1]);
      } else{
        requested.add(element.data()['users'][0]);
      }
    }
  }
  );
  user.friendRequests = requested;
  user.friends = friendsList;
  user.pendingFriends = pending;
}
