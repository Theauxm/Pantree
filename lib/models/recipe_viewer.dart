import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pantree/pantreeUser.dart';
import 'package:pantree/models/exportList.dart';

class ViewRecipe extends StatefulWidget {
  final QueryDocumentSnapshot recipe;
  final PantreeUser user;

  const ViewRecipe({
    this.user,
    @required this.recipe});

  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
    );
  }

  @override
  State<StatefulWidget> createState() => _HomePageState(this.user, this.recipe);
}

// https://stackoverflow.com/questions/51607440/horizontally-scrollable-cards-with-snap-effect-in-flutter
class _HomePageState extends State<ViewRecipe> {
  QueryDocumentSnapshot recipe;
  PantreeUser user;

  _HomePageState(this.user, this.recipe);

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
              return getCard(
                ingredients["Quantity"].toString() +
                    " " +
                    ingredients["Unit"].toString() +
                    " " +
                    ingredients["Item"].id
              );
            },
          );
        });
  }

  Widget getCard(String info) {
    return Container(
        child: Container(
          padding: const EdgeInsets.only(top: 5, right: 5, left: 5, bottom: 5),
          child: Text(info, style: TextStyle(fontSize: 20)
        )),
    );
  }

  Widget listToListView(List<dynamic> list) {
    int directionNum;
    return ListView.builder(
        itemCount: list.length,
        itemBuilder: (_, i) {
          directionNum = i + 1;
          return getCard("$directionNum. " + list[i]);
        });
  }

  Widget cardInfo(String title, Widget info, [bool button = false]) {
        return Transform.scale(
            scale: 1,
            child: Card(
                elevation: 6,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                child: Column(children: [Container(padding: const EdgeInsets.only(top: 10), child: Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30))),Expanded(child: info), button ? addIngredientsToShoppingList() : Container()])
            ));
  }

  Widget addIngredientsToShoppingList() {
    print(this.recipe.reference);
    return TextButton(
      onPressed: () {
        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => ExportList(user: this.user, list: this.recipe.reference, exportList: user.shoppingLists)));
        //builder: (context) => AddToShoppingList(user: this.user, recipe: this.recipe)));
      },
      child: Text("Add to Shopping List", style: TextStyle(fontSize: 20))
    );
  }

  Widget boldPartOfText(String bold, String normal) {
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(text: bold, style: TextStyle(fontWeight: FontWeight.bold)),
          TextSpan(text: normal)
        ]
      ),
          style: TextStyle(fontSize: 20),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(recipe["RecipeName"].toString()), backgroundColor: Colors.red[400]),
      body: Center(
        child: SizedBox(
          height: MediaQuery.of(context).size.height, // card height
          child: PageView.builder(
            itemCount: 3,
            controller: PageController(viewportFraction: 0.9),
            itemBuilder: (_, i) {
              if (i == 0)
                return cardInfo("Overview", ListView(
                    children: [
                      Container(
                          child: boldPartOfText("Recipe Name: ", recipe["RecipeName"].toString()),
                          margin: const EdgeInsets.only(
                              top: 10.0, right: 10.0, left: 10.0, bottom: 10.0)),
                      Container(
                          child: boldPartOfText("Date Added: ", DateTime.parse(recipe["CreationDate"].toDate().toString()).toString().substring(0, 10)),
                          margin: const EdgeInsets.only(
                              top: 10.0, right: 10.0, left: 10.0, bottom: 10.0)),
                      Container(
                          child: boldPartOfText("Total Time: ", recipe["TotalTime"].toString() + " minutes"),
                          margin: const EdgeInsets.only(
                              top: 10.0, right: 10.0, left: 10.0, bottom: 10.0)),
                    ]));
              else if (i == 1)
                return cardInfo("Ingredients", getIngredients(), true);
              else
                return cardInfo("Directions", listToListView(recipe["Directions"]));
            },
          ),
        ),
      ),
    );
  }
}
