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


  PantreeUser() {
    try {
      User u = FirebaseAuth.instance.currentUser;

      this.uid = u.uid;
      this.name = u.displayName;
      this.email = u.email;

      updateData();
    } catch(e){}
  }

  updateData() {
    FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser.uid).get()
        .then((DocumentSnapshot documentSnapshot) =>
    {
      if (documentSnapshot.exists) {
        this.shoppingLists = documentSnapshot.data()['Shopping IDs'],
        this.friends = documentSnapshot.data()['Friend IDs'],
        this.recipes = documentSnapshot.data()['Recipe IDs'],
        this.pantries = documentSnapshot.data()['Pantry IDs'],
      } else
        {
        }
    });
  }
}
