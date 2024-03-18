import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'sign_in.dart'; // Ensure this is correctly pointing to your SignInPage widget

class TokenHelper {
  static Future<String?> getToken(BuildContext context) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final expired = await _isTokenExpired();
    if (!expired) {
      return prefs.getString('token');
    } else {
      _promptLoginAgain(context);
      return null;
    }
  }

  static Future<bool> _isTokenExpired() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final expiryString = prefs.getString('token_expiry');
    if (expiryString != null) {
      final expiryTime = DateTime.parse(expiryString);
      return DateTime.now().isAfter(expiryTime);
    }
    return true;
  }

  static void _promptLoginAgain(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false, // User must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Session Expired"),
          content: Text("Your session has expired. Please sign in again."),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop(); // Dismiss the AlertDialog
                Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => SignInPage()));
              },
            ),
          ],
        );
      },
    );
  }
}