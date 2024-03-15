import 'package:flutter/material.dart';
import 'sign_in.dart';
import 'sign_up.dart';
import 'package:google_fonts/google_fonts.dart';

class StartScreen extends StatelessWidget {
  const StartScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background image
          Image.asset(
            'assets/background_image.jpg',
            fit: BoxFit.cover,
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Tour Guide\nIn\nYour\nPocket',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.shrikhand(
                    textStyle: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 229, 233, 154),
                      height: 1.5, // Adjust line height as needed
                    ),
                  ),
                ),
                SizedBox(height: 120), // Increased space between the text and the button
                SizedBox(
                  width: 200, // Set a fixed width for the buttons
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => sign_in()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Color.fromARGB(255, 229, 233, 154), // Text color matching the Tour Guide text color
                      backgroundColor: const Color.fromARGB(255, 35, 110, 172), // Button color
                      padding: EdgeInsets.symmetric(vertical: 10), // Vertical padding
                    ),
                    child: Text(
                      'Sign In',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold), // Font size and bold text
                    ),
                  ),
                ),
                SizedBox(height: 30), // Space between the buttons
                SizedBox(
                  width: 200, // Set a fixed width for the buttons
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => SignUpPage()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Color.fromARGB(255, 229, 233, 154), // Text color matching the Tour Guide text color
                      backgroundColor: const Color.fromARGB(255, 35, 110, 172), // Button color
                      padding: EdgeInsets.symmetric(vertical: 10), // Vertical padding
                    ),
                    child: Text(
                      'Sign Up',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold), // Font size and bold text
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
