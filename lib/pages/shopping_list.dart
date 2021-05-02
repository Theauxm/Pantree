import 'package:flutter/material.dart';

class shoppingList extends StatefulWidget {

  @override
  _ShoppingState createState() => _ShoppingState();
}

class _ShoppingState extends State<shoppingList> {
  int _count = 0;

  @override
  Widget build(BuildContext context) {
    return  Center(child: Text('You have pressed the button $_count times.'));
  }
}