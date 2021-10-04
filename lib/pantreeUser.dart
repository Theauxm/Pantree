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
        this.friends = documentSnapshot.data()['FriendIDs'],
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
  print(documentSnapshot.toString());
  while(documentSnapshot.data() == null){
    documentSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser.uid).get();
  }
  theUser.name = documentSnapshot.data()['Username'];
  theUser.shoppingLists = documentSnapshot.data()['ShoppingIDs'];
  theUser.friends = documentSnapshot.data()['FriendIDs'];
  theUser.recipes = documentSnapshot.data()['RecipeIDs'];
  theUser.pantries = documentSnapshot.data()['PantryIDs'];
  theUser.posts = documentSnapshot.data()['PostIDs'];
  theUser.PPID = documentSnapshot.data()['PPID'];
  theUser.PSID = documentSnapshot.data()['PSID'];
  print(theUser.name);

  return theUser;
}
