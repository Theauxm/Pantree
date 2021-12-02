import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pantree/pantreeUser.dart';
import 'package:pantree/models/modules.dart';

/*
 * This class allows for users to view recommended recipes based on what is in their Primary Pantry
 * Each time the class is opened, the amount of database reads is as follows:
 *  Number ingredients in a Primary Pantry: p
 *  Number of unique recipes for each ingredient: r
 *  Number of ingredients per recipe: i
 *
 * Total reads = p * 2r * i
 */
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

/*
 * This will be the only state required for the page
 */
class _RecommendRecipeState extends State<RecommendRecipe> {
  PantreeUser user;
  DocumentReference currentPPID;

  // This is the concatenated set of "recipe_ids" for each food item in a given pantry
  Set<DocumentReference> availableRecipes;

  _RecommendRecipeState(this.user);

  @override
  void initState() {
    super.initState();

    // Initializes primary pantry and sets listener in the event that the user changes primary pantries
    currentPPID = this.user.PPID;
    setListener();
  }

  /*
   * Listener setup in the event that the user changes their primary pantry
   */
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

  /*
   * Creates set of all ingredients within a Collection
   * Each DocumentSnapshot must have an "Item" field
   * Arguments:
   *  ingredients : Collection of Document Snapshots that represent a list of Ingredient Instances
   */
  Set<DocumentReference> getIngredientInstances(List<QueryDocumentSnapshot> ingredients) {
    // Uses a set to only add unique ingredients to reduce database reads
    Set<DocumentReference> ingredientReferences = {};
    for (int i = 0; i < ingredients.length; i++) {
      ingredientReferences.add(ingredients[i]["Item"]);
    }

    return ingredientReferences;
  }

  /*
   * Updates availableRecipes with each recipe reference by querying the database
   */
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
    return Scaffold(
      appBar: AppBar(title: Text("Recipe Recommendations"), backgroundColor: Colors.red[400]),

      // Gets Ingredient Instances for a given Primary Pantry
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection(this.currentPPID.path + "/ingredients").snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> querySnapshot) {
          if (querySnapshot.connectionState == ConnectionState.waiting)
            return Center(child: CircularProgressIndicator());
          else {

            // Adds all ingredients to a set to be checked against
            Set<DocumentReference> ingredients = getIngredientInstances(querySnapshot.data.docs);

            /* availableRecipes will be initialized to null
             * if a primary pantry is changed, availableRecipes will be reset to null
             * getRecipeIds only needs to be called once
             */
            if (this.availableRecipes == null) {
              this.availableRecipes = {};
              getRecipeIds(ingredients);
            }

            // StatefulBuilder required to update when new ingredients are added to a pantry
            return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return AvailableRecipesListView(
                    user: this.user,
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

/*
 * Handles all logic for showing recipe recommendations
 */
class AvailableRecipesListView extends StatelessWidget {
  Set<DocumentReference> availableRecipes;
  Set<DocumentReference> pantryIngredients;
  PantreeUser user;

  AvailableRecipesListView({
    @required this.user,
    @required this.availableRecipes,
    @required this.pantryIngredients,
  });

  @override
  Widget build(BuildContext context) {
    // At least one ingredient must be in a user's pantry
    if (this.pantryIngredients.length == 0)
      return addPantryItemDialogue(context, this.user);

    // If no recipes can be recommended, shows dialogue
    if (this.availableRecipes.length == 0)
      return noRecipeDialogue();

    // Will be updated dynamically as Widget is rebuilt
    List<DocumentReference> availableRecipesList = this.availableRecipes.toList();
    return ListView.builder(
      itemCount: availableRecipesList.length,
      itemBuilder: (context, index) {

        // Gets each recipe within availableRecipes
        return StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance.doc(availableRecipesList[index].path).snapshots(),
          builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> querySnapshot) {
            if (querySnapshot.connectionState == ConnectionState.waiting)
              return Container();
            else {

              // Gets ingredient instances per recipe for Missing Ingredients
              DocumentSnapshot recipe = querySnapshot.data;
              return StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection(recipe.reference.path + "/ingredients").snapshots(),
                builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> ingredientsSnapshot) {
                  if (ingredientsSnapshot.connectionState == ConnectionState.waiting)
                    return Container();

                  // Card showing each recipe, allowing for recipe viewing
                  return recipeCard(this.pantryIngredients, this.user, recipe, context, ingredientsSnapshot.data, recommendRecipe: true);
                },
              );
            }
          },
        );
      }
    );
  }
}