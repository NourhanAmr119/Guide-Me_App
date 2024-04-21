import 'package:flutter/material.dart';

class place_page extends StatelessWidget {
  final Map<String, dynamic> place;

  const place_page({Key? key, required this.place}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(place['name']),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Place details go here'),
            SizedBox(height: 20),
            // Display additional details of the place
            Text('Category: ${place['category']}'),
            // Add more information as needed
          ],
        ),
      ),
    );
  }
}
