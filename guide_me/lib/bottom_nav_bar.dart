import 'package:flutter/material.dart';
import 'history_page.dart';
import 'home_page.dart';
import 'favorite_page.dart';
import 'AppLocalization.dart';
import 'profile_page.dart';

class BottomNavBar extends StatelessWidget {
  final String token;
  final Locale? locale;
  final AppLocalization appLocalization;

  const BottomNavBar({
    Key? key,
    required this.token,
    required this.appLocalization,
    this.locale,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      elevation: 0,
      color: const Color.fromARGB(255, 21, 82, 113),
      child: Container(
        height: 60,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.home),
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                      builder: (context) => HomePage(token: token)),
                      (Route<dynamic> route) => false,
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.favorite),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FavoritePage(
                      authToken: token,
                      appLocalization: appLocalization, // Pass the localization instance
                      locale: locale,
                    ),
                  ),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.history),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HistoryPage(
                        token: token,
                        appLocalization: appLocalization, // Pass the localization instance
                        locale: locale
                    ),
                  ),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.person),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProfilePage(
                        token: token,
                        appLocalization: appLocalization,
                        locale: locale),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
