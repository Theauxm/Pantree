import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Dialogs {
  static Future<void> showLoadingDialog(BuildContext context,
      GlobalKey key) async {
    return showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return new WillPopScope(
              onWillPop: () async => false,
              child: SimpleDialog(
                  key: key,
                  backgroundColor: Colors.black54,
                  children: <Widget>[
                    Center(
                      child: Column(children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 10,),
                        Text("Please Wait....",
                          style: TextStyle(color: Colors.blueAccent),)
                      ]),
                    )
                  ]));
        });
  }

  static Future<void> showOKDialog(BuildContext context, String title, String message) async {
    // set up the button
    Widget okButton = TextButton(
      child: Text("OK"),
      onPressed: () {
        Navigator.of(context, rootNavigator: true).pop();
        Navigator.of(context).pop();
      },
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(title: Text(title), content: Text(message), actions: [okButton]);
      },
    );
  }

  static Future<void> friendRequestSent(BuildContext context, String friend) async {
    // set up the button

    Widget okButton = TextButton(
      child: Text("Ok"),
      onPressed: () {
        Navigator.of(context, rootNavigator: true).pop();
      },
    );
    var a = [okButton];
    AlertDialog alert =
    AlertDialog(title: Text("Friend Request:"), content: Text(friend), actions: a);

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}

Future<void> deleteItem(DocumentSnapshot ds) async {
  DocumentReference doc = ds.reference;
  await doc
      .delete()
      .then((value) => print("SUCCESS: $doc has been deleted"))
      .catchError((error) => print("FAILURE: couldn't delete $doc: $error"));
}

showDeleteDialog(BuildContext context, String item, DocumentSnapshot ds) {
  Widget cancelButton = TextButton(
      style: TextButton.styleFrom(
          backgroundColor: Colors.lightBlue, primary: Colors.white),
      child: Text("NO"),
      onPressed: () {
        Navigator.of(context, rootNavigator: true).pop();
      });

  Widget okButton = TextButton(
    style: TextButton.styleFrom(primary: Colors.lightBlue),
    child: Text("YES"),
    onPressed: () {
      deleteItem(ds);
      Navigator.of(context, rootNavigator: true).pop();
    },
  );

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text("Are you sure?"),
        content:
        Text("Do you really want to remove \"$item\"?"),
        actions: [
          cancelButton,
          okButton,
        ],
      );
    },
  );
}