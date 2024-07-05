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
  final bool isProfilePage; // Add a flag to differentiate profile page

  const BottomNavBar({
    Key? key,
    required this.token,
    required this.appLocalization,
    this.locale,
    this.isProfilePage = false, // Default to false
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      elevation: 0,
      color: isProfilePage ? Color.fromARGB(255, 246, 243, 177) : const Color.fromARGB(255, 21, 82, 113), // Use different colors based on the flag
      child: Container(
        height: 60,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: Icon(Icons.home, color: isProfilePage ? Colors.black : Colors.white), // Icon color based on isProfilePage flag
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HomePage(token: token),
                  ),
                      (Route<dynamic> route) => false,
                );
              },
            ),
            IconButton(
              icon: Icon(Icons.favorite, color: isProfilePage ? Colors.black : Colors.white), // Icon color based on isProfilePage flag
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FavoritePage(
                      authToken: token,
                      appLocalization: appLocalization,
                      locale: locale,
                    ),
                  ),
                );
              },
            ),
            IconButton(
              icon: Icon(Icons.history, color: isProfilePage ? Colors.black : Colors.white), // Icon color based on isProfilePage flag
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HistoryPage(
                      token: token,
                      appLocalization: appLocalization,
                      locale: locale,
                    ),
                  ),
                );
              },
            ),
            IconButton(
              icon: Icon(Icons.person, color: isProfilePage ? Colors.black : Colors.white), // Icon color based on isProfilePage flag
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProfilePage(
                      token: token,
                      appLocalization: appLocalization,
                      locale: locale,
                    ),
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
