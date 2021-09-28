import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ViewRecipe extends StatefulWidget {
  QueryDocumentSnapshot recipe;

  ViewRecipe(this.recipe);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        extendBody: true,
        appBar: AppBar(title: Text(recipe["RecipeName"])),


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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: SizedBox(
          height: MediaQuery.of(context).size.height, // card height
          child: PageView.builder(
            itemCount: 10,
            controller: PageController(viewportFraction: 0.9),
            onPageChanged: (int index) => setState(() => _index = index),
            itemBuilder: (_, i) {
              return Transform.scale(
                scale: i == _index ? 1 : 0.9,
                child: Card(
                  elevation: 6,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  child: Center(
                    child: Text(
                      "Card ${i + 1}",
                      style: TextStyle(fontSize: 32),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}