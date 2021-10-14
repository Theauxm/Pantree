import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:pantree/pantreeUser.dart';

class ImageTile extends StatefulWidget {

  DocumentReference postRef;

  ImageTile({this.postRef});

  @override
  ImageTileState createState() => ImageTileState(postRef: postRef);

}
class ImageTileState extends State<ImageTile>{

  DocumentReference postRef;

  var URL;

  ImageTileState({this.postRef});

  @override
  void initState(){
    super.initState();
    getData();
  }

  Future<void> getData() async{

    var post = await postRef.get();
    var imageDownloadURL;
    imageDownloadURL = post.data()['image'];

    String imageURL = await firebase_storage.FirebaseStorage.instance
        .refFromURL(imageDownloadURL)
        .getDownloadURL();

    this.URL = imageURL;
    setState(() {
    });
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
                  // getData(); //this will be changed to show the larger image preview
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
