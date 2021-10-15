import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class ImageViewer extends StatefulWidget {
  final URL;
  final description;
  ImageViewer(this.URL, this.description);
  //ImageFromGalleryEx(this.user);

  @override
  ImageViewerState createState() =>
      ImageViewerState (this.URL,this.description);
}

class ImageViewerState extends State<ImageViewer> {

  var URL;
  var description;

  ImageViewerState(this.URL, this.description);

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: AppBar(),
        body:
        Container(

          child: Column(
            children: [
              Row(
          crossAxisAlignment: CrossAxisAlignment.center,
                children: [
              ConstrainedBox(
              constraints: new BoxConstraints(
              minHeight: 100,
                minWidth: 100,
                maxHeight: 450,
                maxWidth: 350,
              ),
          child:
                  Center(
                    child:
                    new Image.network(
                      URL,
                      fit: BoxFit.cover,
                      //height: double.infinity,
                      //width: double.infinity,
                      alignment: Alignment.center,
                    )
                    ,
                  )
              )],
              ),
              Row(
                //mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [

                        Text(description),
                      ]
              ),


            ],
          )




    )
    );
  }
}
