import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pantree/pantreeUser.dart';
import 'package:pantree/models/friends_list.dart';

class PantreeDrawer extends StatefulWidget {
  PantreeUser user;
  PantreeDrawer({this.user});

  @override
  _PantreeDrawerState createState() => _PantreeDrawerState(user: user);
}

class _PantreeDrawerState extends State<PantreeDrawer> {
  PantreeUser user;
  _PantreeDrawerState({this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
        width: 335,
        child: Drawer(
          child: ListView(
            children: <Widget>[
              DrawerHeader(
                decoration: BoxDecoration(
                  color: Colors.blue,
                ),
                child: Row(
                  children: [
                    Padding(
                        padding: const EdgeInsets.only(right: 10.0),
                        child: Icon(Icons.account_circle, size: 75, color: Colors.white)),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        FittedBox(
                          fit: BoxFit.fitWidth,
                          child: Text(user.name,
                              style: TextStyle(
                                  fontSize: 24.0, fontWeight: FontWeight.w400, color: Colors.white)),
                        ),
                        FittedBox(
                          fit: BoxFit.fitWidth,
                          child: Text(
                            user.email,
                            style: TextStyle(
                                fontSize: 16.0, fontWeight: FontWeight.w400, color: Colors.white)
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),
              ListTile(
                leading: const Icon(Icons.account_circle),
                title: Text('Profile'),
              ),
              ListTile(
                leading: const Icon(Icons.people),
                title: Text('Friends'),
                onTap: friendsList,
              ),
              ListTile(
                leading: const Icon(Icons.settings),
                title: Text('Settings'),
              ),
              ListTile(
                leading: const Icon(Icons.bug_report),
                title: Text('Report a bug'),
              ),
              ListTile(
                leading: const Icon(Icons.help),
                title: Text('Help'),
              ),
              ListTile(
                leading: const Icon(Icons.logout),
                title: Text('Sign out'),
                onTap: _signOut,
              ),
            ],
          ),
        ));
  }

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
  }

  void friendsList(){
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
            (FriendsList(user: user))));
  }
}
