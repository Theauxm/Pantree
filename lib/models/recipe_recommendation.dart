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
    return Scaffold(
      appBar: AppBar(title: Text("Recipe Recommendations"), backgroundColor: Colors.red[400]),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection(this.user.PPID.path + "/ingredients").snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> querySnapshot) {
          if (querySnapshot.connectionState == ConnectionState.waiting)
            return Center(child: CircularProgressIndicator());
          else {
           return ListView.builder(
             itemCount: querySnapshot.data.docs.length,
             itemBuilder: (context, index) {
               QueryDocumentSnapshot ingredient = querySnapshot.data.docs[index];
               return Text(ingredient.id);
             },
           );
          }
        }
      ),
    );
  }


}