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
  DocumentReference currentPPID;
  Set<DocumentReference> availableRecipes;
  int numAvailableRecipes;

  _RecommendRecipeState(this.user);

  @override
  void initState() {
    super.initState();
    currentPPID = this.user.PPID;
    setListener();
  }

  setListener() {
    FirebaseFirestore.instance
        .collection("users")
        .doc(user.uid)
        .snapshots()
        .listen((event) {
      if (event.data()['PPID'].toString() != this.currentPPID.toString()) {
        print("INSIDE LISTENER --> PPID peach emoji");
        user.PPID = event.data()['PPID'];
        this.currentPPID = event.data()['PPID'];
        this.availableRecipes = null;
        setState(() {});
      }
    });
  }

  Set<DocumentReference> getIngredientInstances(List<QueryDocumentSnapshot> ingredients) {
    Set<DocumentReference> availableRecipes = {};
    for (int i = 0; i < ingredients.length; i++) {
      availableRecipes.add(ingredients[i]["Item"]);
    }

    return availableRecipes;
  }

  Future<void> getRecipeIds(Set<DocumentReference> pantryIngredients) async {
    for (DocumentReference i in pantryIngredients) {
      await FirebaseFirestore.instance.doc(i.path).get().then(
              (foodID) {
            for (DocumentReference recipe in foodID["recipe_ids"]) {
              this.availableRecipes.add(recipe);
            }
          });
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    // Gets each Ingredient reference within a given user's Primary Pantry
    return Scaffold(
      appBar: AppBar(title: Text("Recipe Recommendations"), backgroundColor: Colors.red[400]),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection(this.currentPPID.path + "/ingredients").snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> querySnapshot) {
          if (querySnapshot.connectionState == ConnectionState.waiting)
            return Center(child: CircularProgressIndicator());
          else {
            Set<DocumentReference> ingredients = getIngredientInstances(querySnapshot.data.docs);

            if (this.availableRecipes == null) {
              this.availableRecipes = {};
              getRecipeIds(ingredients);
            }

            return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return AvailableRecipesListView(
                    availableRecipes : this.availableRecipes,
                    pantryIngredients: ingredients);
              }
            );
          }
        }
      ),
    );
  }
}

class AvailableRecipesListView extends StatelessWidget {
  Set<DocumentReference> availableRecipes;
  Set<DocumentReference> pantryIngredients;

  AvailableRecipesListView({
    @required this.availableRecipes,
    @required this.pantryIngredients,
  });

  @override
  Widget build(BuildContext context) {
    if (this.availableRecipes.length == 0)
      return Center(child: CircularProgressIndicator());

    List<DocumentReference> availableRecipesList = this.availableRecipes.toList();
    return ListView.builder(
      itemCount: availableRecipesList.length,
      itemBuilder: (context, index) {
        return Text(availableRecipesList[index].toString());
      }
    );
  }
}