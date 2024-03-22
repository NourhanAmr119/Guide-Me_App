import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'sign_in.dart';

class TokenHelper {
  static Future<void> saveToken(String token) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

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
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Session Expired"),
          content: Text("Your session has expired. Please sign in again."),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => SignInPage()));
              },
            ),
          ],
        );
      },
    );
  }
}