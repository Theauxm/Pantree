import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:pantree/pantreeUser.dart';

import 'ImageViewer.dart';

class ImageTile extends StatefulWidget {

  DocumentReference postRef;

  ImageTile({this.postRef});

  @override
  ImageTileState createState() => ImageTileState(postRef: postRef);

}
class ImageTileState extends State<ImageTile>{

  DocumentReference postRef;

  var URL;
  var description;

  ImageTileState({this.postRef});

  @override
  void initState(){
    super.initState();
    getData();
  }

  Future<void> getData() async{
    var post = await postRef.get();
    var imageDownloadURL;
    var imageDescription;
    imageDownloadURL = post.data()['image'];
    imageDescription = post.data()['description'];

    String imageURL = await firebase_storage.FirebaseStorage.instance
        .refFromURL(imageDownloadURL)
        .getDownloadURL();

    this.URL = imageURL;
    this.description = imageDescription;
    setState(() {
    });
  }

  void handleImageTilePress(BuildContext context, URL, description) {
    print("hey i got tapped " + URL);
    print("description: " + description);
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => ImageViewer(URL, description)));
    //TODO: may also need to add the description here
  }

  @override
  Widget build(BuildContext context) {
    if(URL == null){
      return Center(child: CircularProgressIndicator());
    }
    return
          Container(
            padding: const EdgeInsets.all(8),
            child: GestureDetector(
                onTap: () async {

                   handleImageTilePress(context, this.URL, this.description); //this will be changed to show the larger image preview
                },
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                      color: Colors.grey[200]),
                  child:
                     Image.network(
                     this.URL)

                )
            )
        );
      }

}
