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

class social_feed extends StatefulWidget {

  firebase_storage.FirebaseStorage storage =
  firebase_storage.FirebaseStorage.instanceFor(
      bucket: 'pantree-4347e.appspot.com');
  //var images = FirebaseStorage.getInstance
  //var f = FirebaseStorage.instance.refFromURL("gs://pantree-4347e.appspot.com/images/social.png");
  PantreeUser user; //working more with the user so it can contain more objects within it
  social_feed({this.user});

  @override
  _socialState createState() => _socialState(user: user);
}

class _socialState extends State<social_feed> {
  PantreeUser user;
  _socialState({this.user});
 //TODO: READ FROM DB FOR THE POSTS COLLECTION AND PULL RELEVANT INFORMATION
  var images;
  var images1;
  var images2;
  List<String> recipeNames = ["None"];
  Map recipeDocument = new Map<String, DocumentSnapshot>();
  var _image;
  String dropdownValue = 'None';

  // this.user.posts.toString() is a reference to a document that is housing this material, I will now have
  //to read the document

  // @override
  // void initState(){
  //   super.initState();
  //   var uName = user.name;
  //   print(uName);
  // }

  // void initialize() async {
  //   var ll = user.name;
  // }

  Future<dynamic> getData() async {
    DocumentReference tempPost;
    String tempName;
    recipeNames.clear();
    recipeDocument.clear();
    recipeNames.add("None");

   // await user.updateData(); // important: refreshes the user's data
    images = Map<String, DocumentReference>(); // instantiate the map

    // for (DocumentReference ref in user.posts) {
    //   print('hi');
    //   String imageLink = "";
    //   await ref.get().then((DocumentSnapshot snapshot) {
    //     imageLink = snapshot.data()['image']; // get the image link as a string
    //   });
    //   tempPost = ref;
    //   tempName = imageLink;
    //   images1.add(imageLink);
    //   images[imageLink] = ref; // map the doc ref to its name
    //   //TODO: GIVE A BETTER MAPPING FOR THESE VALUES AS THE IMAGE LINK IS THE KEY
    // }

    print('reading recipes');
    for(DocumentReference ref in user.recipes){
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

    setState(() {
    });
  }

  setListener() {
    FirebaseFirestore.instance
        .collection("users")
        .doc(user.uid)
        //.collection("posts")
        .snapshots()
        .listen((event) {
      if(event.data()['PostIDs'].length != user.posts.length) {
        user.posts = event.data()['PostIDs'];
        setState(() {
          });
      }
        if(event.data()['RecipeIDs'].length != user.recipes.length){
          user.recipes = event.data()['RecipeIDs'];
          getData();
          setState(() {
          });
        }
        });
  }
  @override
  void initState() {
    super.initState();
    getData();
    setListener();
  }

  void _handleURLButtonPress(BuildContext context, var type) {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => ImageFromGalleryEx(type, user)));
  }

  void _handleFriendsPress(BuildContext context){
    print("value of your text");
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => FriendsList(user: user)));
  }

  void _handleFeaturedRecipePress(BuildContext context){
    print('recipe pressed ' + dropdownValue);
    //getData();
    //print(user.recipes.length.toString());
    var selectedRecipe = recipeDocument[dropdownValue];
    print(selectedRecipe);
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => ViewRecipe(recipe: selectedRecipe)));



  }


  @override
  Widget build(BuildContext context) {

    //TODO: set this to another value if this is found


    if(user.name == null){
      return Center(child: CircularProgressIndicator());
    }

    return Scaffold(
        drawer: PantreeDrawer(user: this.user),
      appBar: AppBar(
        backgroundColor: Colors.lightGreen,

        title: Text(this.user.name),

        actions: <Widget>[

          IconButton(
            icon: const Icon(Icons.people),
            color: Colors.white,
              onPressed: () {
                if(kIsWeb) {

                }else{
                  _handleFriendsPress(context);
                }
              }
          ),
          IconButton(
            //icon: const Icon(Icons.view_headline_rounded),
            icon: const Icon(Icons.add_box_outlined),
            //tooltip: 'Show Snackbar',
            // onPressed: () {
            //   ScaffoldMessenger.of(context).showSnackBar(
            //       const SnackBar(content: Text('This is a snackbar')));
            // },
              onPressed: () {
              if(kIsWeb) {

              }else{
                _handleURLButtonPress(context, ImageSourceType.gallery);
              }
              }
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
                  child:  Text(user.name.toString().substring(0,1)),
                  minRadius: 30,
                  maxRadius: 40,
                ),
                  Column(
                      children:[
                        Text(user.posts.length.toString()),
                        Text('Posts')
                      ]
                  ),
                  Column(
                      children:[
                        Text(user.friends.length.toString()),
                        InkWell(
                          child: Text('Friends'),
                          onTap: () {
                            _handleFriendsPress(context);
                          }

                        )
                      ]
                  ),
                  // Column(
                  //     children:[
                  //       Text('1000'), //place holder for number
                  //       Text('Likes')
                  //     ]
                  // )
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
                    child:
                    // Center(
                    //   child:Text('Featured Recipe: Chicken Carbonara',
                    //     textAlign: TextAlign.center,)
                    // )

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
                      icon: const Icon(Icons.arrow_drop_down),

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
                    itemCount: user.posts.length, //might be length()
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
                      return ImageTile(postRef : user.posts[index]);
                    },
               )
               )
            ]
          )
      )
    );

  }
}