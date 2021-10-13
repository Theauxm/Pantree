import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../pantreeUser.dart';

class RecipeCreator extends StatelessWidget {
  PantreeUser user;

  RecipeCreator({this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar( title: Text("Create a Recipe"), backgroundColor: Colors.red[400]),
      body: Text("Hello")

    );
  }
}