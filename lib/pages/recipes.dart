import 'package:flutter/material.dart';

class recipes extends StatefulWidget {

  @override
  _recipeState createState() => _recipeState();
}

class _recipeState extends State<recipes> {
  int _count = 0;

  @override
  Widget build(BuildContext context) {
    return Center(child: Text('You have pressed the button $_count times.'));
  }
}