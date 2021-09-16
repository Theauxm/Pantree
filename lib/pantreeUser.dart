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
      this.name = u.displayName;
      this.email = u.email;

      updateData();
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
