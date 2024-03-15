import 'package:flutter/material.dart';
import 'sign_in.dart'; // Import your sign_in.dart file

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Guide Me',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: sign_in(), // Use your sign_in class as the home widget
    );
  }
}
