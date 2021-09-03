import 'package:flutter/material.dart';
import 'package:pantree/pantreeUser.dart';

class social_feed extends StatefulWidget {
  PantreeUser user;
  social_feed({this.user});

  @override
  _socialState createState() => _socialState(user: user);
}

class _socialState extends State<social_feed> {
  PantreeUser user;
  _socialState({this.user});
  int _count = 0;


  @override
  Widget build(BuildContext context) {
    return Center(child: Text('You have pressed the button $_count times.'));
  }
}