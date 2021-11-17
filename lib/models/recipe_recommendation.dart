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

        setState(() {});
      }
    });
  }

  Set<DocumentReference> getIngredientInstances(List<QueryDocumentSnapshot> ingredients) {
    Set<DocumentReference> availableRecipes = {};
    for (int i = 0; i < ingredients.length; i++) {
      print("Adding: " + ingredients[i]["Item"].path);
      availableRecipes.add(ingredients[i]["Item"]);
    }

    return availableRecipes;
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
            print(ingredients);
            return AvailableRecipesListView(
                pantryIngredients: ingredients);
          }
        }
      ),
    );
  }
}

class AvailableRecipesListView extends StatelessWidget {
  Set<DocumentReference> pantryIngredients;

  Set<DocumentReference> availableRecipes;

  AvailableRecipesListView({@required this.pantryIngredients});

  Future<void> getRecipeIds() async {
    for (DocumentReference i in pantryIngredients) {
      await FirebaseFirestore.instance.doc(i.path).get().then(
          (foodID) {
            for (DocumentReference recipe in foodID["recipe_ids"]) {
              availableRecipes.add(recipe);
            }
          });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (this.pantryIngredients == null) {
      print("Pantry Ingredients is null");
      return Center(child: CircularProgressIndicator());
    }

    if (this.availableRecipes == null) {
      this.availableRecipes = {};
      getRecipeIds();
      return Center(child: CircularProgressIndicator());
    } else {
      return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return ListView.builder(
                itemCount: availableRecipes.length,
                itemBuilder: (context, index) {

                }
            );
          }
      );
    }
  }
}

/*
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
 */