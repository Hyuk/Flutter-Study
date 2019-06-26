import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Using FontAwesome Fonts",
      home: Scaffold(
        appBar: AppBar(
          title: Text("Using FontAwesome Fonts"),
        ),
        body: Container(
          child: Center(
            child: IconButton(icon: Icon(FontAwesomeIcons.gamepad),
            onPressed: (){
              print("Pressed");
            },),
          ),
        ),
      ),
    );
  }
}