import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../pantreeUser.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

class RecipeCreator extends StatelessWidget {
  PantreeUser user;
  RecipeCreator({this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Create a Recipe"), backgroundColor: Colors.red[400]),
      body: InputForm(user: this.user)
    );
  }
}

class InputForm extends StatefulWidget {
  PantreeUser user;
  InputForm({this.user});

  @override
  State<StatefulWidget> createState() {return _InputForm(user: this.user);}
}

class _InputForm extends State<InputForm> {
  PantreeUser user;
  _InputForm({this.user});
  final  _fbKey = GlobalKey<FormBuilderState>();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10),
      child: Column(
        children: [
          FormBuilder(
            key: _fbKey,
            autovalidateMode: AutovalidateMode.always,
            child: Column(
              children: [
                FormBuilderTextField(
                  validator: FormBuilderValidators.compose([FormBuilderValidators.required(context)]),
                  decoration: InputDecoration(labelText: "Recipe Name"),
                ),
                FormBuilderTextField(
                  validator: FormBuilderValidators.compose([FormBuilderValidators.required(context)]),
                  decoration: InputDecoration(labelText: "Total Time"),
                ),
              ]
            )
          )
        ]
      )
    );
  }
}