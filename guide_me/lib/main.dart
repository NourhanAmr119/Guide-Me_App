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
    _fetchLanguage(); // Fetch user's preferred language
  }
  String decodeToken(String token) {
    Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
    return decodedToken[
    'http://schemas.xmlsoap.org/ws/2005/05/identity/claims/name'];
  }
  void _fetchLanguage() async {
    // Implement your token decoding logic here
    String token = ''; // Replace with your token
    String touristName = decodeToken(token); // Implement decodeToken function

    final response = await http.get(
      Uri.parse('http://guide-me.somee.com/api/Tourist/GetTouristInfo/$touristName'),
      headers: {
        'Authorization': 'Bearer $token',
        'accept': '*/*',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      String languageCode = _mapLanguageCode(data['language']);
      setState(() {
        _locale = Locale(languageCode);
      });
    } else {
      throw Exception('Failed to fetch tourist info');
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
