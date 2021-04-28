import 'package:flutter/material.dart';

class recipes extends StatefulWidget {

  @override
  _recipeState createState() => _recipeState();
}

class _recipeState extends State<recipes> {
  int _count = 0;

  void _onNavTapped(int index) {
    switch(index){
      case 0:{
        Navigator.pushNamed(context, 'home');
      }
      break;
      case 1:{
        Navigator.pushNamed(context, 'shopping');
      }
      break;
      case 2:{
        Navigator.pushNamed(context, 'recipes');
      }
      break;
      case 3:{
        Navigator.pushNamed(context, 'social');
      }
    }
    // setState(() {
    //   _selectedIndex = index;
    // });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recipes'),
      ),
      body: Center(child: Text('You have pressed the button $_count times.')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => setState(() => _count++),
        tooltip: 'Increment Counter',
        child: const Icon(Icons.add),
      ),
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
        currentIndex: 2,
        selectedItemColor: Colors.amber[800],
        onTap: _onNavTapped,
      ),
    );
  }
}