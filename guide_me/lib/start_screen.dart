// import 'package:flutter/material.dart';
// import 'sign_in.dart';
// import 'sign_up.dart';
// //import 'package:google_fonts/google_fonts.dart';
//
// class StartScreen extends StatelessWidget {
//   const StartScreen({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Stack(
//         fit: StackFit.expand,
//         children: [
//           // Background image
//           Image.asset(
//             'assets/background_image.jpg',
//             fit: BoxFit.cover,
//           ),
//           Center(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Text(
//                   'Tour Guide\nIn\nYour\nPocket',
//                   textAlign: TextAlign.center,
//                   style: GoogleFonts.shrikhand(
//                     textStyle: TextStyle(
//                       fontSize: 48,
//                       fontWeight: FontWeight.bold,
//                       color: Color.fromARGB(255, 229, 233, 154),
//                       height: 1.5, // Adjust line height as needed
//                     ),
//                   ),
//                 ),
//                 SizedBox(height: 20),
//                 ElevatedButton(
//                   onPressed: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(builder: (context) => sign_in()),
//                     );
//                   },
//                   style: ElevatedButton.styleFrom(
//                     foregroundColor: Colors.white, backgroundColor: const Color.fromARGB(255, 35, 110, 172), // Text color
//                   ),
//                   child: Text('Sign In'),
//                 ),
//                 SizedBox(height: 10),
//                 ElevatedButton(
//                   onPressed: () {
//                      Navigator.push(
//                       context,
//                       MaterialPageRoute(builder: (context) => SignUpPage()),
//                     );
//                   },
//                   style: ElevatedButton.styleFrom(
//                     foregroundColor: Colors.white, backgroundColor:  const Color.fromARGB(255, 35, 110, 172), // Text color
//                   ),
//                   child: Text('Sign Up'),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }