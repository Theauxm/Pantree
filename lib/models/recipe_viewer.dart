import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';


class ViewRecipe extends StatelessWidget {
  QueryDocumentSnapshot recipe;
  ViewRecipe(this.recipe);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(recipe["RecipeName"])),
      body: Text(recipe["Directions"].toString())
    );
  }

}