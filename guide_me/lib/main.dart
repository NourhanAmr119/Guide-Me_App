import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'AppLocalization.dart';
import 'sign_up.dart';
import 'sign_in.dart';
import 'start_screen.dart';
import 'favorite_places_model.dart';
import 'home_page.dart'; // Import your HomePage class

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => FavoritePlacesModel(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Guide Me', // App title
        theme: ThemeData(
          primaryColor: const Color.fromARGB(255, 21, 82, 113),
          colorScheme: const ColorScheme.dark().copyWith(
            primary: const Color(0xFF372949),
            onPrimary: Colors.white,
          ),
        ),
        supportedLocales: const [
          Locale('en', 'US'), // English
          Locale('es', 'ES'), // Spanish
          Locale('fr', 'FR'), // French
          Locale('it', 'IT'), // Italian
          Locale('ar', 'AR'), // Arabic
          Locale('ru', 'RU'), // Russian
        ],
        localizationsDelegates: const [
          AppLocalization.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        localeResolutionCallback: (locale, supportedLocales) {
          // Ensure the selected locale is one of the supported locales
          for (var supportedLocale in supportedLocales) {
            if (supportedLocale.languageCode == locale?.languageCode &&
                supportedLocale.countryCode == locale?.countryCode) {
              return supportedLocale;
            }
          }
          return supportedLocales.first; // Fallback to the first supported locale
        },
        home: const StartScreen(), // Initial screen of the app is HomePage
        routes: {
          '/sign_up': (context) => SignUpPage(), // Named routes
          '/sign_in': (context) => SignInPage(),
          '/start': (context) => const StartScreen(),
        },
      ),
    );
  }
}
