import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ViewRecipe extends StatefulWidget {
  final QueryDocumentSnapshot recipe;

  ViewRecipe(this.recipe);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
    );
  }

  @override
  State<StatefulWidget> createState() => _HomePageState(this.recipe);
}

// https://stackoverflow.com/questions/51607440/horizontally-scrollable-cards-with-snap-effect-in-flutter
class _HomePageState extends State<ViewRecipe> {
  int _index = 0;
  QueryDocumentSnapshot recipe;

  _HomePageState(this.recipe);

  Widget getIngredients() {
    return StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("recipes")
            .doc(recipe.id)
            .collection("ingredients")
            .snapshots(),
        builder:
            (BuildContext context, AsyncSnapshot<QuerySnapshot> querySnapshot) {
          if (querySnapshot.hasError) {
            return Text("Could not show ingredients.");
          }
          if (querySnapshot.connectionState == ConnectionState.waiting)
            return Center(child: CircularProgressIndicator());

          return ListView.builder(
            shrinkWrap: true,
            itemCount: querySnapshot.data.docs.length,
            itemBuilder: (context, index) {
              QueryDocumentSnapshot ingredients =
                  querySnapshot.data.docs[index];
              return Text(
                ingredients["Quantity"].toString() +
                    " " +
                    ingredients["Unit"].toString() +
                    " " +
                    ingredients["Item"].id,
                style: TextStyle(fontSize: 20.0),
              );
            },
          );
        });
  }

  Widget listToListView(List<dynamic> list) {
    return ListView.builder(
        itemCount: list.length,
        itemBuilder: (_, i) {
          return Text(list[i]);
        });
  }

  Widget cardInfo(Widget info, int i) {
    return Center(
        child: Transform.scale(
            scale: i == _index ? 1 : 0.9,
            child: Card(
                elevation: 6,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                child: info
            )));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: SizedBox(
          height: MediaQuery.of(context).size.height, // card height
          child: PageView.builder(
            itemCount: 3,
            controller: PageController(viewportFraction: 0.9),
            onPageChanged: (int index) => setState(() => _index = index),
            itemBuilder: (_, i) {
              if (i == 0)
                return cardInfo(listToListView([
                  recipe["RecipeName"].toString(),
                  recipe["Creator"].toString(),
                  recipe["Credit"].toString(),
                  recipe["CreationDate"].toString(),
                  recipe["TotalTime"].toString()]), i);
              else if (i == 1)
                return cardInfo(listToListView(recipe["Directions"]), i);
              else
                return cardInfo(getIngredients(), i);
            },
          ),
        ),
      ),
    );
  }
}
