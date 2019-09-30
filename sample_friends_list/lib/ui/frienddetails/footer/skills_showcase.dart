import 'package:flutter/material.dart';

class SkillsShowcase extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var textTheme = Theme.of(context).textTheme;

    return Center(
      child: Text(
        'Skills: TODO',
        style: textTheme.title.copyWith(color: Colors.white),
      ),
    );
  }
}