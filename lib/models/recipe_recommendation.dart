import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pantree/pantreeUser.dart';

import 'drawer.dart';

class RecommendRecipe extends StatefulWidget {
  final PantreeUser user;

  const RecommendRecipe({
    this.user});


  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
    );
  }

  @override
  State<StatefulWidget> createState() => _RecommendRecipeState(this.user);
}

class _RecommendRecipeState extends State<RecommendRecipe> {
  PantreeUser user;

  _RecommendRecipeState(this.user);



  @override
  Widget build(BuildContext context) {

    // Gets each Ingredient reference within a given user's Primary Pantry
    return Scaffold(
      appBar: AppBar(title: Text("Recipe Recommendations"), backgroundColor: Colors.red[400]),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection(this.user.PPID.path + "/ingredients").snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> querySnapshot) {
          if (querySnapshot.connectionState == ConnectionState.waiting)
            return Center(child: CircularProgressIndicator());
          else {
            Set<String> available_recipes = {};
            // Creates list of each ingredient.
           return ListView.builder(
             itemCount: querySnapshot.data.docs.length,
             itemBuilder: (context, index) {
               QueryDocumentSnapshot ingredient = querySnapshot.data.docs[index];

               // Needs another StreamBuilder to get info from reference about each ingredient.
               return StreamBuilder<DocumentSnapshot>(
                 stream: FirebaseFirestore.instance
                     .doc(ingredient["Item"].path)
                     .snapshots(),
                 builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> querySnapshot) {
                   return Text(querySnapshot.data["recipe_ids"].toString());
                 },
               );
             },
           );
          }
        }
      ),
    );
  }


}