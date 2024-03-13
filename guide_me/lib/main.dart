import 'package:flutter/material.dart';
import 'sign_in.dart'; // Import your SignInPage widget

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Guide Me',
      theme: ThemeData(
        primaryColor: const Color.fromARGB(255, 21, 82, 113),
        colorScheme: const ColorScheme.dark().copyWith(
          primary: const Color(0xFF372949),
          onPrimary: Colors.white,
        ),
      ),
      home: const sign_in(), // Set the SignInPage as the home page
    );
  }
}