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
  Stream<QuerySnapshot> _stream;
  Set<dynamic> available_recipes;

  _RecommendRecipeState(this.user);

  @override
  void initState() {
    super.initState();
    _stream = FirebaseFirestore.instance.collection(this.user.PPID.path + "/ingredients").snapshots();
  }

  @override
  Widget build(BuildContext context) {
    // Gets each Ingredient reference within a given user's Primary Pantry
    return Scaffold(
      appBar: AppBar(title: Text("Recipe Recommendations"), backgroundColor: Colors.red[400]),
      body: StreamBuilder<QuerySnapshot>(
        stream: _stream,
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> querySnapshot) {
          if (querySnapshot.connectionState == ConnectionState.waiting)
            return Center(child: CircularProgressIndicator());
          else {

            return ListView.builder(
              itemCount: querySnapshot.data.docs.length,
              itemBuilder: (context, index) {
                QueryDocumentSnapshot ingredient = querySnapshot.data.docs[index];
                if (querySnapshot.connectionState == ConnectionState.waiting)
                  return Center(child: CircularProgressIndicator());
                else {
                  print(ingredient["Item"]);
                  // Needs another StreamBuilder to get info from reference about each ingredient.
                  return StreamBuilder<DocumentSnapshot>(
                    stream: FirebaseFirestore.instance
                        .doc(ingredient["Item"].path)
                        .snapshots(),
                    builder: (BuildContext context,
                        AsyncSnapshot<DocumentSnapshot> querySnapshot) {
                      if (available_recipes == null) {
                        available_recipes = {};
                        for (var x in querySnapshot.data["recipe_ids"]) {
                          available_recipes.add(x);
                          print(available_recipes);
                        }
                      } else {
                        Set<dynamic> temp = {};
                        for (var x in querySnapshot.data["recipe_ids"]) {
                          temp.add(x);
                        }
                        print(temp);
                        available_recipes = available_recipes.intersection(temp);
                      }
                      print("FINAL: " + available_recipes.toString());
                      return Text(available_recipes.toString());
                    },
                  );
                }
              },
            );
          }
        }
      ),
    );
  }
}

/*
            print(available_recipes);
            return ListView.builder(
              itemCount: available_recipes.length,
              itemBuilder: (context, index) {
                print(available_recipes.toString());
                QueryDocumentSnapshot ingredient = querySnapshot.data.docs[index];
                if (querySnapshot.connectionState == ConnectionState.waiting)
                  return Center(child: CircularProgressIndicator());
                else {
                  print(available_recipes.toString());
                  // Needs another StreamBuilder to get info from reference about each ingredient.
                  return StreamBuilder<DocumentSnapshot>(
                    stream: FirebaseFirestore.instance
                        .doc(ingredient["Item"].path)
                        .snapshots(),
                    builder: (BuildContext context,
                        AsyncSnapshot<DocumentSnapshot> querySnapshot) {

                      if (available_recipes.length == 0)
                        available_recipes.addAll(querySnapshot.data["recipe_ids"]);

                      else {
                        available_recipes = available_recipes.intersection(querySnapshot.data["recipe_ids"]);
                      }
                      return Text(available_recipes.toString());
                    },
                  );
                }
              },
            );
 */