import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ViewRecipe extends StatelessWidget {
  QueryDocumentSnapshot recipe;

  ViewRecipe(this.recipe);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        extendBody: true,
        appBar: AppBar(title: Text(recipe["RecipeName"])),
        body: Column(children: [
          ListTile(
              subtitle: Text(recipe["Creator"].id,
              style: TextStyle(fontSize: 20.0)),
              title: Text("Created By:",
                  style: TextStyle(
                      fontSize: 25.0
                  ))
          ),
          ListTile(
              subtitle: Text(DateTime.parse(recipe["CreationDate"].toDate().toString()).toString(),
                  style: TextStyle(fontSize: 20.0)),
              title: Text("Creation Date:",
                  style: TextStyle(
                      fontSize: 25.0
                  ))
          ),
          ListTile(
            subtitle: Text(recipe["TotalTime"].toString() + " minutes",
            style: TextStyle(
              fontSize: 20.0
            )),
            title: Text("Time to cook:",
            style: TextStyle(
              fontSize: 25.0
            ))
          ),
          ListTile(
              subtitle: Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection("recipes")
                          .doc(recipe.id)
                          .collection("ingredients")
                          .snapshots(),
                      builder: (BuildContext context,
                          AsyncSnapshot<QuerySnapshot> querySnapshot) {
                        if (querySnapshot.hasError) {
                          return Text("Could not show ingredients.");
                        }
                        if (querySnapshot.connectionState ==
                            ConnectionState.waiting)
                          return Center(child: CircularProgressIndicator());

                        return ListView.builder(
                          shrinkWrap: true,
                          itemCount: querySnapshot.data.docs.length,
                          itemBuilder: (context, index) {
                            QueryDocumentSnapshot ingredients =
                                querySnapshot.data.docs[index];
                            return Text(ingredients["Quantity"].toString() + " " + ingredients["Unit"].toString() + " " + ingredients["Item"].id,
                                style: TextStyle(
                            fontSize: 20.0
                            ),
                            );
                          },
                        );
                      })),
              title: Text("Ingredients:", style: TextStyle(fontSize: 25.0))),
          ListTile(
            subtitle: ListView.builder(
                shrinkWrap: true,
                itemCount: recipe["Directions"].length,
                itemBuilder: (context, index) {
                  return Text((index + 1).toString() + ". " + recipe["Directions"][index],
                      style: TextStyle(fontSize: 20.0));
                }),
            title: Text("Directions:",
            style: TextStyle(
              fontSize: 25.0
            ))
          ),
        ]));
  }
}

/*
Expanded(
        child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('recipes').doc(recipe.id)
            .collection('ingredients').snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> querySnapshot) {
          return ListView.builder(
            itemCount: querySnapshot.data.docs.length,
            itemBuilder: (context, index) {
              QueryDocumentSnapshot ingredients = querySnapshot.data.docs[index];
              return Text(
                ingredients["Item"].toString()
              );
            }
          );
        }
      )
    )
 */
