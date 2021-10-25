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


  user_profile();

  @override
  _profileState createState() => _profileState();
}

class _profileState extends State<user_profile> {

  //TODO: receive a document reference and a status

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        //drawer: PantreeDrawer(
        //user: this.user
    //),
    appBar: AppBar(
    backgroundColor: Colors.lightGreen,

    title: Text('hey')));

  }
}