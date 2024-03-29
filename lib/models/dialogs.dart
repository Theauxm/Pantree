import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Dialogs {
  static Future<void> showLoadingDialog(
      BuildContext context, GlobalKey key) async {
    return showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return new WillPopScope(
              onWillPop: () async => false,
              child: SimpleDialog(key: key, children: <Widget>[
                Center(
                  child: Column(children: [
                    CircularProgressIndicator(),
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      "Please wait....",
                      style: TextStyle(color: Colors.blueAccent),
                    )
                  ]),
                )
              ]));
        });
  }

  static Future<void> showOKDialog(
      BuildContext context, String title, String message) async {
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
        return AlertDialog(
            title: Text(title), content: Text(message), actions: [okButton]);
      },
    );
  }

  /// Your generic no/yes dialog generalized to work with any function
  static showNoYesDialog(BuildContext context, String title, String msg, Function func, {Object param}) {
    Widget noButton = TextButton(
        style: TextButton.styleFrom(primary: Colors.red),
        child: Text("NO"),
        onPressed: () {
          Navigator.of(context, rootNavigator: true).pop();
        });

    Widget yesButton = TextButton(
      style: TextButton.styleFrom(primary: Colors.lightBlue),
      child: Text("YES"),
      onPressed: () {
        func(param);
        Navigator.of(context, rootNavigator: true).pop();
      },
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(msg),
          actions: [
            noButton,
            yesButton,
          ],
        );
      },
    );
  }

  static Future<void> showCreateRecipeFailDialog(
      BuildContext context, String title, String message) async {
    // set up the button
    Widget okButton = TextButton(
      child: Text("OK"),
      onPressed: () {
        Navigator.of(context, rootNavigator: true).pop();
      },
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
            title: Text(title), content: Text(message), actions: [okButton]);
      },
    );
  }

  static Future<void> friendRequestSent(
      BuildContext context, String friend) async {
    // set up the button

    Widget okButton = TextButton(
      child: Text("Ok"),
      onPressed: () {
        Navigator.of(context, rootNavigator: true).pop();
      },
    );
    var a = [okButton];
    AlertDialog alert = AlertDialog(
        title: Text("Friend Request"), content: Text(friend), actions: a);

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  static showDeleteItemDialog(BuildContext context, String item, DocumentSnapshot ds) {
    Widget cancelButton = TextButton(
        style: TextButton.styleFrom(primary: Colors.red),
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
          content: Text("Do you really want to remove \"$item\"?"),
          actions: [
            cancelButton,
            okButton,
          ],
        );
      },
    );
  }

  static showError(BuildContext context, String title, String content) {
        Widget okButton = TextButton(
      style: TextButton.styleFrom(primary: Colors.lightBlue),
      child: Text("Ok"),
      onPressed: () {
        Navigator.of(context, rootNavigator: true).pop();
      },
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: [
            okButton,
          ],
        );
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


