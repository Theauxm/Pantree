
import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
//import '../models/drawer.dart';
import 'package:firebase_auth_ui/firebase_auth_ui.dart';
import 'welcome.dart';

class Home extends StatefulWidget {
  Home({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".
  final String title;

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  var FireBase = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User _currentUser;
  int _selectedIndex = 0;
  String userUID = "";
  String _food = "";
  static const TextStyle optionStyle = TextStyle(fontWeight: FontWeight.bold);


  void _checkCurrentUser() async {
    _currentUser = _auth.currentUser;
    //_currentUser?.getIdToken(refresh = true) // IM not sure what this is doing or if we need it - Trey
  }

  @override
  void initState() {
    super.initState();
    _checkCurrentUser();
  }


  // var _listener = _auth.authStateChanges().listen((User user) {
  //   _currentUser = user;
  // });
  // Stream<User> get onAuthStateChanged =>
  //     _auth.authStateChanges();
  // _listener = _auth.authStateChanges().listen((event) {
  //
  // })

//   _listener = _auth.userChanges().listen((FirebaseUser user) {
//   setState(() {
//   _currentUser = user;
//   });
//   });
// }
// }


  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if(snapshot.hasData){
          return HomeScreen(user: snapshot.data);
        } else {
          return WelcomePage();
        }
      }
    );
  }
}


class HomeScreen extends StatefulWidget {
  final User user;
  HomeScreen({this.user});

  @override
  _HomeScreenState createState() => _HomeScreenState(user: user);
}

class _HomeScreenState extends State<HomeScreen> {
  final User user;
  _HomeScreenState({this.user});
  static const TextStyle optionStyle = TextStyle(fontWeight: FontWeight.bold);
  int _selectedIndex = 0;
  static const List<Widget> _widgetOptions = <Widget>[
    Text(
      'Index 0: Home',
      style: optionStyle,
    ),
    Text(
      'Index 1: Shopping List',
      style: optionStyle,
    ),
    Text(
      'Index 2: Recipe Recommender',
      style: optionStyle,
    ),
    Text(
      'Index 3: Social Feed',
      style: optionStyle,
    ),
    Text(
      'Index 4: Profile',
      style: optionStyle,
    ),
  ];



  void handleClick(String value) {
    switch (value) {
      case 'Add new item':
        break;
      case 'Filter':
        break;
    }
  }

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
  Widget _buildPantry(BuildContext context, pantryReference){

  }
  Widget _buildPantryItem(BuildContext context){

  }
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection('users').doc(user.uid).snapshots(),
      builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        //if (!snapshot.hasData) return const Text('Loading....');
        if (!snapshot.hasData) return Center ( child: CircularProgressIndicator(),);
        //if (snapshot.data['Username'] == null) return  const Text('Loading....');
        if(!snapshot.data.exists) return Center ( child: CircularProgressIndicator(),);
        return Scaffold(
          appBar: AppBar(
            // Here we take the value from the MyHomePage object that was created by
            // the App.build method, and use it to set our appbar title.
            title: Text("Pantree Home"),
            actions: <Widget>[
              Padding(
                padding: EdgeInsets.only(right: 20.0),
                child: GestureDetector(
                  onTap: () {},
                  child: Icon(Icons.search, size: 26.0),
                ),
              ),
              PopupMenuButton<String>(
                onSelected: handleClick,
                itemBuilder: (BuildContext context) {
                  return {'Add new item', 'Filter'}.map((String choice) {
                    return PopupMenuItem<String>(
                      value: choice,
                      child: Text(choice),
                    );
                  }).toList();
                },
              ),
            ],
          ),
          body: StreamBuilder( //Sets up a stream builder to listen for changes inside the database.
              stream: FirebaseFirestore.instance.collection('pantries').doc(
                  'ExamplePantry').snapshots(), //Where its listening!
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Text('Loading....');
                return Center(
                  child: Column(

                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        'Index selected:',
                      ),
                      Text(
                        '$_selectedIndex',
                        style: Theme
                            .of(context)
                            .textTheme
                            .headline5,
                      ),
                      Text(
                        //Reads from data snapshot the the Food section!
                        snapshot.data['Food'].toString(),

                      ),
                    ],
                  ),
                );
              }),
          drawer: Drawer(
            child: ListView(
              children: <Widget>[
                DrawerHeader(
                  decoration: BoxDecoration(
                    color: Colors.lightBlue,
                  ),
/*              child: Text('Pantree',style: TextStyle(
                color: Colors.white,
                fontSize: 22,
              ),
              ),*/
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
                          Text(snapshot.data['Username'],
                              style: Theme
                                  .of(context)
                                  .textTheme
                                  .headline5),
                          Text(
                            snapshot.data['Username'],
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
          ),
          // This trailing comma makes auto-formatting nicer for build methods.
          bottomNavigationBar: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.shopping_basket),
                label: 'Shopping List',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.search),
                label: 'Recipes',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.people),
                label: 'Social Feed',
              ),
            ],
            currentIndex: _selectedIndex,
            selectedItemColor: Colors.amber[800],
            onTap: _onItemTapped,
          ),
        );
      }
    );
  }
}



