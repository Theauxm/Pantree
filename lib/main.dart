import 'package:flutter/material.dart';
import 'pages/home.dart';
import 'package:firebase_core/firebase_core.dart';

// void main() {
//   //await Firsebase.initializedApp();
//   runApp(MyApp());
// }

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Pantree',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      //home: Home(title: 'Pantree Home'), // alt title: myPantree
      home: Home(),
    );
  }

}
