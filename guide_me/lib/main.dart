import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Import Provider package
import 'home_page.dart';
import 'start_screen.dart';
import 'sign_in.dart';
import 'sign_up.dart';
import 'favorite_places_model.dart'; // Import your FavoritePlacesModel class

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider( // Wrap your StartScreen with ChangeNotifierProvider
      create: (context) => FavoritePlacesModel(), // Create an instance of FavoritePlacesModel
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Guide Me',
        theme: ThemeData(
          primaryColor: const Color.fromARGB(255, 21, 82, 113),
          colorScheme: const ColorScheme.dark().copyWith(
            primary: const Color(0xFF372949),
            onPrimary: Colors.white,
          ),
        ),
        home: const StartScreen(),
        // Define your app's routes
        routes: {
          '/sign_up': (context) => SignUpPage(),
          '/sign_in': (context) => SignInPage(),
          '/start': (context) => StartScreen(),
        },
      ),
    );
  }
}