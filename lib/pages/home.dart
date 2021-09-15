import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pantree/pages/shopping_list.dart';
import 'welcome.dart';
import 'pantry.dart';
import 'shopping_list.dart';
import 'recipes.dart';
import 'social_feed.dart';
import '../pantreeUser.dart';

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

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if(snapshot.hasData){
          PantreeUser pUser = PantreeUser();
          return HomeScreen(user: pUser);
        } else {
          return WelcomePage();
        }
      }
    );
  }
}


class HomeScreen extends StatefulWidget {
  PantreeUser user;
  HomeScreen({this.user});

  @override
  _HomeScreenState createState() => _HomeScreenState(user: user);
}

class _HomeScreenState extends State<HomeScreen> {
  PantreeUser user;
  _HomeScreenState({this.user});
  int _selectedIndex = 0;

  // Widget currentPage;
  // List<Widget> pages;
  List<GlobalKey<NavigatorState>> _navigatorKeys = [
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>()
  ];

  @override
  Widget build(BuildContext context) {
    //TODO: Remove this Streambuilder once we have real user objects
        return WillPopScope(
            onWillPop: () async {
          final isFirstRouteInCurrentTab =
          !await _navigatorKeys[_selectedIndex].currentState.maybePop();

          // let system handle back button if we're on the first route
          return isFirstRouteInCurrentTab;
        },
          child: Scaffold(
            body: Stack(
              children: [
                _buildOffstageNavigator(0),
                _buildOffstageNavigator(1),
                _buildOffstageNavigator(2),
                _buildOffstageNavigator(3),
              ],
            ),
          // This trailing comma makes auto-formatting nicer for build methods.
          bottomNavigationBar: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            items: const <BottomNavigationBarItem> [
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
            onTap: _onNavTapped,
          ),
        ));
    //   }
    // );
  }

  Widget _buildOffstageNavigator(int index) {
    var routeBuilders = _routeBuilders(context, index);

    return Offstage(
      offstage: _selectedIndex != index,
      child: Navigator(
        key: _navigatorKeys[index],
        onGenerateRoute: (routeSettings) {
          return MaterialPageRoute(
            builder: (context) => routeBuilders[routeSettings.name](context),
          );
        },
      ),
    );
  }

  Map<String, WidgetBuilder> _routeBuilders(BuildContext context, int index) {
    return {
      '/': (context) {
        return [
          pantry(user: this.user),
          ShoppingList(user: this.user),
          recipes(user: this.user),
          social_feed(user: this.user),
        ].elementAt(index);
      },
    };
  }

  void _onNavTapped(int index) {
    setState(() {
      _selectedIndex = index;
      //currentPage = pages[index];
    });
  }

}

/*
Navigator.push(context, MaterialPageRoute(
                builder: (context) => Screen2()
            ));
}
 */

//Save these for later helper methods


//*********Sign out*********
// Future<void> _signOut() async {
//   await FirebaseAuth.instance.signOut();
// }

//**********************APPBAR**********************************
// appBar: AppBar(
//   // Here we take the value from the MyHomePage object that was created by
//   // the App.build method, and use it to set our appbar title.
//   title: Text("Pantree <3"),
//   actions: <Widget>[
//     Padding(
//       padding: EdgeInsets.only(right: 20.0),
//       child: GestureDetector(
//         onTap: () {},
//         child: Icon(Icons.search, size: 26.0),
//       ),
//     ),
//     PopupMenuButton<String>(
//       onSelected: handleClick,
//       itemBuilder: (BuildContext context) {
//         return {'Add new item', 'Filter'}.map((String choice) {
//           return PopupMenuItem<String>(
//             value: choice,
//             child: Text(choice),
//           );
//         }).toList();
//       },
//     ),
//   ],
// ),

//******************Drawer****************
// drawer: Drawer(
// child: ListView(
// children: <Widget>[
// DrawerHeader(
// decoration: BoxDecoration(
// color: Colors.blue,
// ),
// child:
// Row(
// children: [
// Padding(
// padding: const EdgeInsets.only(right: 10.0),
// child: Icon(Icons.account_circle, size: 75)),
// Column(
// crossAxisAlignment: CrossAxisAlignment.start,
// mainAxisSize: MainAxisSize.min,
// children: [
// Text(snapshot.data['Username'],
// style: Theme
//     .of(context)
// .textTheme
//     .headline5),
// Text(
// snapshot.data['Username'],
// //user.displayName.toString(),
// ),
// ],
// ),
// ],
// ),
// ),
// ListTile(
// leading: Icon(Icons.account_circle),
// title: Text('Profile'),
// ),
// ListTile(
// leading: Icon(Icons.settings),
// title: Text('Settings'),
// ),
// ListTile(
// leading: Icon(Icons.bug_report),
// title: Text('Report a bug'),
// ),
// ListTile(
// leading: Icon(Icons.help),
// title: Text('Help'),
// ),
// ListTile(
// leading: Icon(Icons.logout),
// title: Text('Sign out'),
// onTap: _signOut,
// ),
// ],
// ),
// ),

// NO idea what the fuck this is I never made it but wanted everyone to have a chance to claim it

// static const List<Widget> _widgetOptions = <Widget>[
//   Text(
//     'Index 0: Home',
//     style: optionStyle,
//   ),
//   Text(
//     'Index 1: Shopping List',
//     style: optionStyle,
//   ),
//   Text(
//     'Index 2: Recipe Recommender',
//     style: optionStyle,
//   ),
//   Text(
//     'Index 3: Social Feed',
//     style: optionStyle,
//   ),
//   Text(
//     'Index 4: Profile',
//     style: optionStyle,
//   ),
// ];


