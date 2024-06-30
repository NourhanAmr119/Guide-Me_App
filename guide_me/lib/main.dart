import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';

import 'AppLocalization.dart';
import 'sign_up.dart';
import 'sign_in.dart';
import 'start_screen.dart';
import 'favorite_places_model.dart';
import 'home_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Locale _locale;

  @override
  void initState() {
    super.initState();
    _locale = const Locale('en', 'US'); // Default locale

    // Optionally, load user's preferred language
    _fetchUserLanguage();
  }

  Future<void> _fetchUserLanguage() async {
    // Simulate fetching user language from an API or local storage
    try {
      // Replace this with your actual API call to fetch user language
      // Example:
      // final response = await http.get('your_api_endpoint');
      // final userLanguage = json.decode(response.body)['preferredLanguage'];

      // Simulated response:
      final userLanguage = 'spanish'; // Replace with actual user's language

      final locale = Locale(_mapLanguageCode(userLanguage), ''); // Use country code if available
      setState(() {
        _locale = locale;
      });
    } catch (e) {
      print('Error fetching user language: $e');
    }
  }

  String _mapLanguageCode(String language) {
    // Map your API language response to Flutter locale language codes
    switch (language.toLowerCase()) {
      case 'spanish':
        return 'es';
      case 'french':
        return 'fr';
      case 'italian':
        return 'it';
      case 'arabic':
        return 'ar';
      case 'russian':
        return 'ru';
      default:
        return 'en'; // Default to English
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => FavoritePlacesModel(),
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
        locale: _locale,
        supportedLocales: [
          const Locale('en', 'US'), // English
          const Locale('es', 'ES'), // Spanish
          const Locale('fr', 'FR'), // French
          const Locale('it', 'IT'), // Italian
          const Locale('ar', 'AR'), // Arabic
          const Locale('ru', 'RU'), // Russian
        ],
        localizationsDelegates: [
          AppLocalization.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        localeResolutionCallback: (locale, supportedLocales) {
          // Ensure that the locale is one of the supported locales
          for (var supportedLocale in supportedLocales) {
            if (supportedLocale.languageCode == locale?.languageCode &&
                supportedLocale.countryCode == locale?.countryCode) {
              return supportedLocale;
            }
          }
          return supportedLocales.first; // Fallback to the first supported locale
        },
        home: const StartScreen(),
        routes: {
          '/sign_up': (context) => SignUpPage(),
          '/sign_in': (context) => SignInPage(),
          '/start': (context) => const StartScreen(),
        },
      ),
    );
  }
}
