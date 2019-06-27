# Create and style a text field

* lib/main.dart
```dart
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final appTitle = 'Text Field Decoration';
    return MaterialApp(
      title: appTitle,
      home: Scaffold(
        appBar: AppBar(
          title: Text(appTitle),
        ),
        body: TextFormField(
          decoration: InputDecoration(
            labelText: 'Enter your username',
          ),
        ),
      ),
    );
  }
}

```
