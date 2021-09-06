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

  // @override
  // void initState(){
  //   super.initState();
  //   var uName = user.name;
  //   print(uName);
  // }

  // void initialize() async {
  //   var ll = user.name;
  // }

  var stars = Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(Icons.star, color: Colors.green[500]),
      Icon(Icons.star, color: Colors.green[500]),
      Icon(Icons.star, color: Colors.green[500]),
      const Icon(Icons.star, color: Colors.black),
      const Icon(Icons.star, color: Colors.black),
    ],
  );

  @override
  Widget build(BuildContext context) {
    //return Center(child: Text('You have pressed the button $_count times.'));
    //super.build(context);
    //var user = user.name;
    //var uName = user.name;
    return Scaffold(
      appBar: AppBar(

        leading:IconButton(
          icon: const Icon(Icons.arrow_left),
        ),

        //leading: stars,

        title: Text(user.name),

        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.add_box_rounded),
            tooltip: 'Show Snackbar',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('This is a snackbar')));
            },
          ),
          IconButton(
            icon: const Icon(Icons.view_headline_rounded),
            tooltip: 'Go to the next page',
            onPressed: () {
              Navigator.push(context, MaterialPageRoute<void>(
                builder: (BuildContext context) {
                  return Scaffold(
                    appBar: AppBar(
                      title: const Text('Next page'),
                    ),
                    body: const Center(
                      child: Text(
                        'This is the next page',
                        style: TextStyle(fontSize: 24),
                      ),
                    ),
                  );
                },
              ));
            },
          ),
        ],
      ),

      body:CircleAvatar(
        //backgroundImage: NetworkImage(userAvatarUrl),
        backgroundColor: Colors.green,
        child: const Text('BW'),
      )
    );

  }
}