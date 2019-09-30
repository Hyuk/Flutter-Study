import 'package:flutter/material.dart';
import './footer/friend_detail_footer.dart';
import './friend_detail_body.dart';
import './header/friend_detail_header.dart';
import '../friends/friend.dart';
import 'package:meta/meta.dart';

class FriendDetailsPage extends StatefulWidget {
  FriendDetailsPage(
      this.friend, {
        @required this.avatarTag,
      });

  final Friend friend;
  final Object avatarTag;

  @override
  _FriendDetailsPageState createState() => _FriendDetailsPageState();
}

class _FriendDetailsPageState extends State<FriendDetailsPage> {
  @override
  Widget build(BuildContext context) {
    var linearGradient = const BoxDecoration(
      gradient: const LinearGradient(
        begin: FractionalOffset.centerRight,
        end: FractionalOffset.bottomLeft,
        colors: <Color>[
          const Color(0xFF413070),
          const Color(0xFF2B264A),
        ],
      ),
    );

    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          decoration: linearGradient,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              FriendDetailHeader(
                widget.friend,
                avatarTag: widget.avatarTag,
              ),
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: FriendDetailBody(widget.friend),
              ),
              FriendShowcase(widget.friend),
            ],
          ),
        ),
      ),
    );
  }
}