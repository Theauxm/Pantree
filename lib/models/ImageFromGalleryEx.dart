//import 'dart:html';

import'dart:io';
import 'package:path/path.dart';
import 'package:flutter/material.dart';
import 'package:pantree/pages/social_feed.dart';
import 'package:pantree/pantreeUser.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';


class ImageFromGalleryEx extends StatefulWidget {
  final type;
  ImageFromGalleryEx(this.type);

  @override
  ImageFromGalleryExState createState() => ImageFromGalleryExState(this.type);
}

class ImageFromGalleryExState extends State<ImageFromGalleryEx> {
  var _image;
  var picture;
  var imagePicker;
  var type;

  ImageFromGalleryExState(this.type);

  Future uploadImageToFirebase(BuildContext context) async {
    String fileName = basename(_image.path);
    Reference firebaseStorageRef =
    FirebaseStorage.instance.ref().child('uploads/$fileName');
    //StorageUploadTask uploadTask = firebaseStorageRef.putFile(_image);
    try {
      await FirebaseStorage.instance
          .ref('uploads/$fileName')
          .putFile(_image);
    }catch (e) {
      // e.g, e.code == 'canceled'
      print('error in upload of image');
    }
    //StorageTaskSnapshot taskSnapshot = await uploadTask.onComplete;
    //taskSnapshot.ref.getDownloadURL().then(
    //      (value) => print("Done: $value"),
    //);
  }

  @override
  void initState() {
    super.initState();
    imagePicker = new ImagePicker();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(type == ImageSourceType.camera
              ? "Image from Camera"
              : "Create New Post")),
      body: Column(
        children: <Widget>[
          SizedBox(
            height: 52,
          ),
          Center(
            child: GestureDetector(
              onTap: () async {
                var source = type == ImageSourceType.camera
                    ? ImageSource.camera
                    : ImageSource.gallery;
                XFile image = await imagePicker.pickImage(
                    source: source, imageQuality: 50, preferredCameraDevice: CameraDevice.front);
                setState(() {
                  picture = image;
                  _image = File(image.path);
                });
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
                      color: Colors.grey[200]),
                  width: 200,
                  height: 200,
                  child: Icon(
                    Icons.camera_alt,
                    color: Colors.grey[800],
                  ),
                ),
              ),
            ),
          ),
          Container(
            //height: 150.0,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 16),
              child: TextField(
                decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Description'
                ),
              )
          ),
          Container(
            child:(
                MaterialButton(
                  color: Colors.blue,
                  child: Text(
                    "Upload",
                    style: TextStyle(
                        color: Colors.white70, fontWeight: FontWeight.bold),
                  ),
                  onPressed: () {
                   // _handleURLButtonPress(context, ImageSourceType.gallery);
                    print(picture.path);
                    print(_image); //this is the file path
                    //TODO: write event handler for saving the photo
                    uploadImageToFirebase(context);

                  },
                )
            )
          ),
        ],
      ),
    );
  }
}