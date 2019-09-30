import 'package:flutter/material.dart';
import './ui/friends/friends_list_page.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
        accentColor: const Color(0xFFF850DD),
      ),
      home: FriendsListPage(),
    );
  }
}