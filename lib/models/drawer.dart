/*
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
//part of '../pages/home.dart';
class Drawer extends StatefulWidget {

  @override
  _DrawerState createState() => _DrawerState();
}

class _DrawerState extends State<Drawer> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: <Widget>[
          StreamBuilder(
            stream: FirebaseFirestore.instance.collection('users').doc('1').snapshots(),
            builder: (context, snapshot){
              if(!snapshot.hasData) return const Text('Loading....');
              return DrawerHeader(
                decoration: BoxDecoration(
                  color: Colors.lightBlue,
                ),
*/
/*              child: Text('Pantree',style: TextStyle(
                color: Colors.white,
                fontSize: 22,
              ),
              ),*//*

                child:
                Row(
                  children: [
                    Padding(
                        padding: const EdgeInsets.only(right: 10.0),
                        child: Icon(Icons.account_circle, size: 75)),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Pantree User',
                            style: Theme.of(context).textTheme.headline5),
                        Text(
                          snapshot.data['Username'].toString(),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.account_circle),
            title: Text('Profile'),
          ),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text('Settings'),
          ),
          ListTile(
            leading: Icon(Icons.bug_report),
            title: Text('Report a bug'),
          ),
          ListTile(
            leading: Icon(Icons.help),
            title: Text('Help'),
          ),
          ListTile(
            leading: Icon(Icons.logout),
            title: Text('Sign out'),
          ),
        ],
      ),
    );
  }
}


*/
