import 'package:flutter/material.dart';
import 'start_screen.dart'; // Import your StartScreen widget

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
      home: const StartScreen(), // Set the StartScreen as the home page
    );
  }
}
