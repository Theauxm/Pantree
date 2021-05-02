import 'package:flutter/material.dart';

class social_feed extends StatefulWidget {

  @override
  _socialState createState() => _socialState();
}

class _socialState extends State<social_feed> {
  int _count = 0;


  @override
  Widget build(BuildContext context) {
    return Center(child: Text('You have pressed the button $_count times.'));
  }
}