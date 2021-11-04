import 'package:flutter/material.dart';
import 'package:pantree/models/ImageTile.dart';
import 'package:pantree/models/recipe_viewer.dart';
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
  var currentUser;


  user_profile({Key key, this.profileRef, this.status, this.currentUser}) : super(key: key); //receive the document snapshot here

  @override
  _profileState createState() => _profileState(profileRef: profileRef, currentUser: currentUser);
}

class _profileState extends State<user_profile> {

  DocumentReference profileRef;
  var currentUser;
  var username;
  int friends;
  var posts; //user post array
  var images; //image links to pass
  var recipes;
  String status;
  List<String> recipeNames = ["None"];
  Map recipeDocument = new Map<String, DocumentSnapshot>();
  String dropdownValue = 'None';

  //TODO: finish variables for holding all relevant info from the profile

  @override
  void initState(){
    super.initState();
    getData();
  }

  Future<void> getData() async {
    var profile = await profileRef.get();
    recipeNames.clear();
    recipeDocument.clear();
    recipeNames.add("None");
    username = profile.data()['Username'];
    posts = profile.data()['PostIDs'];
    friends = profile.data()['Friends'];
    recipes = profile.data()['RecipeIDs'];



    for (DocumentReference ref in posts) {
      String imageLink = "";
      await ref.get().then((DocumentSnapshot snapshot) {
        imageLink = snapshot.data()['image']; // get the image link as a string
      });
    }

    for (DocumentReference ref in recipes) {
      String recipeName = "";
      DocumentSnapshot recipeSnapshot;
      print(ref);
      await ref.get().then((DocumentSnapshot snapshot) {
        recipeName = snapshot.data()['RecipeName'];
        recipeSnapshot = snapshot;
      });

      //recipeNames.add(recipeName);
      print(recipeName);
      recipeNames.add(recipeName);
      recipeDocument[recipeName] = recipeSnapshot;



    }
    setState(() {});
  }

  void _handleFeaturedRecipePress(BuildContext context) {
    print('recipe pressed ' + dropdownValue);
    //getData();
    //print(user.recipes.length.toString());
    if (dropdownValue != "None") {
      var selectedRecipe = recipeDocument[dropdownValue];
      print(selectedRecipe);
      Navigator.push(context,
          MaterialPageRoute(
              builder: (context) =>
                  ViewRecipe(
                    user: currentUser, //TODO PASS THE CURRENT USER TO THE USER PROFILE
                      recipe: selectedRecipe)));
    }
  }

  _profileState({this.profileRef, this.currentUser});

  //TODO: receive a document reference and a status

  @override
  Widget build(BuildContext context) {
    if(username == null){
      return Center(child: CircularProgressIndicator());
    }
    return Scaffold(
        //drawer: PantreeDrawer(
        //user: this.user
    //),
    appBar: AppBar(
    backgroundColor: Colors.lightGreen,

    title: Text(username)),

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
    Text(widget.status.toString()), //place holder for number
    Text('Friend Status')
    ]
    )
    ],
    ),
    Padding(
    padding: const EdgeInsets.all(6.0),
    //child: Text("text"),
    ),
      Text("Recipes created by " + username),
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
    child:
    StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return DropdownButton<String>(
            value: dropdownValue,
            icon: const Icon(Icons.arrow_drop_down),
            iconSize: 24,
            //elevation: 16,
            style: const TextStyle(color: Colors.black),
            // underline: Container(
            //   height: 2,
            //   color: Colors.deepPurpleAccent,
            // ),
            onChanged: (String newValue) {
              print(newValue);
              setState(() {
                dropdownValue = newValue;
              });
            },
            items: recipeNames//<String>['None','One', 'Two', 'Free', 'Four']//recipeNames
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          );
        }
    ),

    )
    ),
    Container(
    child: IconButton(
    icon: const Icon(Icons.arrow_forward_rounded),

    onPressed: () {
    _handleFeaturedRecipePress(context);
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
    return ImageTile(postRef : posts[index]);
    },
    )
    )
    ]
    )
    )

    );

  }
}