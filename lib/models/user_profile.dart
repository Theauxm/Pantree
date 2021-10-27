import 'package:flutter/material.dart';
import 'package:pantree/models/ImageTile.dart';
import 'package:pantree/pantreeUser.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import '../models/ImageFromGalleryEx.dart';
import '../models/friends_list.dart';
import '../models/drawer.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

enum ImageSourceType { gallery, camera }

class user_profile extends StatefulWidget {

  DocumentReference profileRef;
  String status;


  user_profile({this.profileRef, this.status}); //receive the document snapshot here

  @override
  _profileState createState() => _profileState(profileRef: profileRef);
}

class _profileState extends State<user_profile> {

  DocumentReference profileRef;
  var username;
  int friends;
  var posts; //user post array
  var images; //image links to pass
  String status;
  //TODO: finish variables for holding all relevant info from the profile

  @override
  void initState(){
    super.initState();
    getData();
  }

  Future<void> getData() async {
    var profile = await profileRef.get();
    username = profile.data()['Username'];
    posts = profile.data()['postIDs'];
    friends = profile.data()['Friends'];


    images = Map<String, DocumentReference>(); // instantiate the map

    for (DocumentReference ref in posts) {
      String imageLink = "";
      await ref.get().then((DocumentSnapshot snapshot) {
        imageLink = snapshot.data()['image']; // get the image link as a string
      });
      images.add(imageLink);
    }

    setState(() {
    });


  }

  _profileState({this.profileRef});

  //TODO: receive a document reference and a status

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        //drawer: PantreeDrawer(
        //user: this.user
    //),
    appBar: AppBar(
    backgroundColor: Colors.lightGreen,

    title: Text('hey')),

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
    child:  Text(username.toString().substring(0,1)),
    minRadius: 30,
    maxRadius: 40,
    ),
    Column(
    children:[
    Text(posts.length.toString()),
    Text('Posts')
    ]
    ),
    Column(
    children:[
    Text(friends.toString()),
    InkWell(
    child: Text('Friends'),
    onTap: () {
    //_handleFriendsPress(context);
    }

    )
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

    onPressed: () {
    print('recipe button pressed');
    },
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
    BoxConstraints(maxHeight: MediaQuery.of(context).size.height / 1.9),
    child:
    //   RefreshIndicator(
    //     child:

    GridView.builder(
    itemCount: posts.length, //might be length()
    gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
    maxCrossAxisExtent: 200,
    childAspectRatio: 3 / 2,
    crossAxisSpacing: 20,
    mainAxisSpacing: 20),
    //primary: false,
    scrollDirection: Axis.vertical,
    //shrinkWrap: true,
    padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),

    itemBuilder: (context, index){
    return ImageTile(postRef : images[index]);
    },
    )
    )
    ]
    )
    )

    );

  }
}