import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pantree/pantreeUser.dart';


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
    return Drawer(
      child: ListView(
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
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
                    Text(user.name,
                        style: Theme
                            .of(context)
                            .textTheme
                            .headline5),
                    Text(
                      user.email,
//user.displayName.toString(),
                    ),
                  ],
                ),
              ],
            ),
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
            onTap: _signOut,
          ),
        ],
      ),
    );
  }

Future<void> _signOut() async {
  await FirebaseAuth.instance.signOut();
}

}