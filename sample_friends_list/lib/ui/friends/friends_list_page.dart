import 'dart:async';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../frienddetails/friend_details_page.dart';
import './friend.dart';

class FriendsListPage extends StatefulWidget {
  @override
  _FriendsListPageState createState() => _FriendsListPageState();
}

class _FriendsListPageState extends State<FriendsListPage> {
  List<Friend> _friends = [];

  @override
  void initState() {
    super.initState();
    _loadFriends();
  }

  Future<void> _loadFriends() async {
    http.Response response =
    await http.get('https://randomuser.me/api/?results=25');

    setState(() {
      _friends = Friend.allFromResponse(response.body);
    });
  }

  Widget _buildFriendListTile(BuildContext context, int index) {
    var friend = _friends[index];

    return ListTile(
      onTap: () => _navigateToFriendDetails(friend, index),
      leading: Hero(
        tag: index,
        child: CircleAvatar(
          backgroundImage: NetworkImage(friend.avatar),
        ),
      ),
      title: Text(friend.name),
      subtitle: Text(friend.email),
    );
  }

  void _navigateToFriendDetails(Friend friend, Object avatarTag) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (c) {
          return FriendDetailsPage(friend, avatarTag: avatarTag);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget content;

    if (_friends.isEmpty) {
      content = Center(
        child: CircularProgressIndicator(),
      );
    } else {
      content = ListView.builder(
        itemCount: _friends.length,
        itemBuilder: _buildFriendListTile,
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text('Friends')),
      body: content,
    );
  }
}