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
        backgroundColor: Colors.lightGreen,
        leading:
        IconButton(
          icon: const Icon(Icons.arrow_left),
        ),

        //leading: stars,

        title: Text(user.name),

        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.add_box_outlined),
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

      body:Container(

          //padding: const EdgeInsets.all(10),
        padding: EdgeInsets.fromLTRB(0, 20, 0, 0),
          child:Column(
            children:[
              Row(
                //mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  CircleAvatar( //use a stack here
                  //backgroundImage: NetworkImage(userAvatarUrl),
                  backgroundColor: Colors.blueGrey,
                  child: const Text('BW'),
                  minRadius: 30,
                  maxRadius: 40,
                ),
                  Column(
                      children:[
                        Text('30'), //place holder for number
                        Text('Posts')
                      ]
                  ),
                  Column(
                      children:[
                        Text('300'), //place holder for number
                        Text('Friends')
                      ]
                  ),
                  Column(
                      children:[
                        Text('1000'), //place holder for number
                        Text('Likes')
                      ]
                  )
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                //child: Text("text"),
              ),
              Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ConstrainedBox(
                      constraints: new BoxConstraints(
                        minHeight: 30,
                        minWidth: 30,
                        maxHeight: 30,
                        maxWidth: 320,
                      ),

                      child:Container(
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey)
                      ),
                    child:Center(
                      child:Text('Featured Recipe: Chicken Carbonara',
                        textAlign: TextAlign.center,)
                    )

                  )
                  ),
                  Container(
                    child: IconButton(
                      icon: const Icon(Icons.arrow_drop_down),
                    )
                  )
                ]
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                //child: Text("text"),
              ),
              Container(
                  constraints:
                  BoxConstraints(maxHeight: MediaQuery.of(context).size.height / 2.1),
                  child:
                   //   RefreshIndicator(
                   //     child:

                  GridView.count(
                    primary: false,
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    crossAxisCount: 3,

                    children:[
                      Container(
                        padding: const EdgeInsets.all(8),
                        child: const Text('1st'),
                        color: Colors.teal[100],
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        child: const Text('1st'),
                        color: Colors.teal[100],
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        child: const Text('1st'),
                        color: Colors.teal[100],
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        child: const Text('2nd'),
                        color: Colors.teal[200],
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        child: const Text('2nd'),
                        color: Colors.teal[200],
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        child: const Text('2nd'),
                        color: Colors.teal[200],
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        child: const Text('3rd'),
                        color: Colors.teal[300],
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        child: const Text('3rd'),
                        color: Colors.teal[300],
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        child: const Text('3rd'),
                        color: Colors.teal[300],
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        child: const Text('overflow'),
                        color: Colors.teal[400],
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        child: const Text('Overflow'),
                        color: Colors.teal[400],
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        child: const Text('overflow'),
                        color: Colors.teal[400],
                      ),
                    ],
              )
              )
        //      )
            ]
          )
      )
    );

  }
}