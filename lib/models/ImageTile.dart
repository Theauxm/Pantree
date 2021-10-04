import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pantree/pantreeUser.dart';

class ImageTile extends StatefulWidget {
  PantreeUser user;
  ImageTile({this.user});

  @override
  _ImageTileState createState() => _ImageTileState(user: user);
}

class _ImageTileState extends State<ImageTile> {
  PantreeUser user;
  _ImageTileState({this.user});

  @override
  Widget build(BuildContext context) {
    return
      Container(
          padding: const EdgeInsets.all(8),
          child: GestureDetector(
            onTap: () async {
             // getData(); //this onTap needs to be changed
              },
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                  color: Colors.grey[200]),
              child:
                //images2.length >= 1
              //?
             //   Image.network(
               //   images2[0])
           // :
                Container(
          decoration: BoxDecoration(
          color: Colors.teal[100]),
              width: 200,
              height: 200,
            ),
            )
          )
        );
  }

}
