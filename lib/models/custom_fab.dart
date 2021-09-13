import 'package:flutter/material.dart';

class CustomFAB extends StatelessWidget {
  // const CustomFAB({Key? key}) : super(key: key); // figure out what this is all about
  CustomFAB({@required this.color, @required this.icon, @required this.onPressed});
  final Color color;
  final Widget icon;
  final Function onPressed;

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      backgroundColor: color,
      child: icon,
      onPressed: onPressed,
    );
  }
}
