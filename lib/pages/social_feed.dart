import 'package:flutter/material.dart';
import 'package:pantree/pantreeUser.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import '../models/ImageFromGalleryEx.dart';
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
  var _image;

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

    await user.updateData(); // important: refreshes the user's data
    images = Map<String, DocumentReference>(); // instantiate the map
    images1 = [];
    images2 = [];

    for (DocumentReference ref in user.posts) {
      print('hi');
      // go through each doc ref and add to list of pantry names + map
      String imageLink = "";
      await ref.get().then((DocumentSnapshot snapshot) {
        imageLink = snapshot.data()['image']; // get the image link as a string
      });
      tempPost = ref; // this will have to do for now
      tempName = imageLink;
      images1.add(imageLink);

      images[imageLink] = ref; // map the doc ref to its name
      //TODO: GIVE A BETTER MAPPING FOR THESE VALUES AS THE IMAGE LINK IS THE KEY
      print(imageLink);
    }
    print(images);
    print(user.posts);
    print(images1);

    //WORKING FOR GETTING AN IMAGE BACK
    for(var i = 0; i < images1.length; i++) {
      String downloadURL = await firebase_storage.FirebaseStorage.instance
          .refFromURL(images1[i])
          .getDownloadURL();

      print(downloadURL);
      images2.add(downloadURL);
    }

    // setState(() {
    //   _selectedPantry = tempPantry;
    //   _selectedPantryName = tempName;
    // });
  }

  @override
  void initState() {
    super.initState();
    getData();
    //setListener();
  }

  void _handleURLButtonPress(BuildContext context, var type) {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => ImageFromGalleryEx(type, user)));
  }

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

  //ImagePicker picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    //return Center(child: Text('You have pressed the button $_count times.'));
    //super.build(context);
    //var user = user.name;
    //var uName = user.name;
    return Scaffold(
        drawer: PantreeDrawer(user: this.user),
      appBar: AppBar(
        backgroundColor: Colors.lightGreen,
     //   leading:
     //   IconButton(
     //     icon: const Icon(Icons.arrow_left),
     //   ),

        //leading: stars,

        title: Text(this.user.name),

        actions: <Widget>[

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

          IconButton(
            icon: const Icon(Icons.view_headline_rounded),
              tooltip: 'Show Snackbar',
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('This is a snackbar')));
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
                  BoxConstraints(maxHeight: MediaQuery.of(context).size.height / 1.9),
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
                        child: GestureDetector(
                          onTap: () async {
                            print('hey');
                            getData();
                            },
                          child: Container(
                            width: 200,
                            height: 200,
                            decoration: BoxDecoration(
                                color: Colors.grey[200]),
                            child:images2.length >= 1
                            ? Image.network(
                                images2[0])
                          :Container(
                        decoration: BoxDecoration(
                        color: Colors.teal[100]),
                            width: 200,
                            height: 200,
                            child: Icon(
                              Icons.image,
                              //color: Colors.grey[800],
                            ),
                          ),
                          )
                        )
                      ),
                      Container(
                          padding: const EdgeInsets.all(8),
                          child: GestureDetector(
                              onTap: () async {
                                print('hey');
                                getData();
                              },
                              child: Container(
                                width: 200,
                                height: 200,
                                decoration: BoxDecoration(
                                    color: Colors.grey[200]),
                                child:images2.length >= 2
                                    ? Image.network(
                                    images2[1])
                                    :Container(
                                  decoration: BoxDecoration(
                                      color: Colors.teal[100]),
                                  width: 200,
                                  height: 200,
                                  child: Icon(
                                    Icons.image,
                                    //color: Colors.grey[800],
                                  ),
                                ),
                              )
                          )
                      ),
                      Container(
                          padding: const EdgeInsets.all(8),
                          child: GestureDetector(
                              onTap: () async {
                                print('hey');
                                getData();
                              },
                              child: Container(
                                width: 200,
                                height: 200,
                                decoration: BoxDecoration(
                                    color: Colors.grey[200]),
                                child: images2.length >= 3
                                    ? Image.network(
                                    images2[2])
                                    :Container(
                                  decoration: BoxDecoration(
                                      color: Colors.teal[100]),
                                  width: 200,
                                  height: 200,
                                  child: Icon(
                                    Icons.image,
                                    //color: Colors.grey[800],
                                  ),
                                ),
                              )
                          )
                      ),
                      Container(
                          padding: const EdgeInsets.all(8),
                          child: GestureDetector(
                              onTap: () async {
                                print('hey');
                                getData();
                              },
                              child: Container(
                                width: 200,
                                height: 200,
                                decoration: BoxDecoration(
                                    color: Colors.grey[200]),
                                child:images2.length >= 4
                                    ? Image.network(
                                    images2[3])
                                    :Container(
                                  decoration: BoxDecoration(
                                      color: Colors.teal[100]),
                                  width: 200,
                                  height: 200,
                                  child: Icon(
                                    Icons.image,
                                    //color: Colors.grey[800],
                                  ),
                                ),
                              )
                          )
                      ),
                      Container(
                          padding: const EdgeInsets.all(8),
                          child: GestureDetector(
                              onTap: () async {
                                print('hey');
                                getData();
                              },
                              child: Container(
                                width: 200,
                                height: 200,
                                decoration: BoxDecoration(
                                    color: Colors.grey[200]),
                                child:images2.length >= 5
                                    ? Image.network(
                                    images2[4])
                                    :Container(
                                  decoration: BoxDecoration(
                                      color: Colors.teal[100]),
                                  width: 200,
                                  height: 200,
                                  child: Icon(
                                    Icons.image,
                                    //color: Colors.grey[800],
                                  ),
                                ),
                              )
                          )
                      ),
                      Container(
                          padding: const EdgeInsets.all(8),
                          child: GestureDetector(
                              onTap: () async {
                                print('hey');
                                getData();
                              },
                              child: Container(
                                width: 200,
                                height: 200,
                                decoration: BoxDecoration(
                                    color: Colors.grey[200]),
                                child:images2.length >= 6
                                    ? Image.network(
                                    images2[5])
                                    :Container(
                                  decoration: BoxDecoration(
                                      color: Colors.teal[100]),
                                  width: 200,
                                  height: 200,
                                  child: Icon(
                                    Icons.image,
                                    //color: Colors.grey[800],
                                  ),
                                ),
                              )
                          )
                      ),
                      Container(
                          padding: const EdgeInsets.all(8),
                          child: GestureDetector(
                              onTap: () async {
                                print('hey');
                                getData();
                              },
                              child: Container(
                                width: 200,
                                height: 200,
                                decoration: BoxDecoration(
                                    color: Colors.grey[200]),
                                child:images2.length >= 7
                                    ? Image.network(
                                    images2[6])
                                    :Container(
                                  decoration: BoxDecoration(
                                      color: Colors.teal[100]),
                                  width: 200,
                                  height: 200,
                                  child: Icon(
                                    Icons.image,
                                    //color: Colors.grey[800],
                                  ),
                                ),
                              )
                          )
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        child: GestureDetector(
                          onTap: () async {
                            print('hey1');
                          },
                          child: Container(
                            width: 200,
                            height: 200,
                            decoration: BoxDecoration(
                                color: Colors.grey[200]),
                            child: _image != null
                                ? Image.file(
                              _image,
                              width: 200.0,
                              height: 200.0,
                              fit: BoxFit.fill,
                              //fit: BoxFit.fitWidth

                            )
                                : Container(
                              decoration: BoxDecoration(
                                  color: Colors.teal[100]),
                              width: 200,
                              height: 200,
                              child: Icon(
                                Icons.image,
                                //color: Colors.grey[800],
                              ),
                            ),
                          ),
                        ),
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