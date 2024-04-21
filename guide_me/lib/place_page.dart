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
        child: Text('Place details go here'),
      ),
    );
  }
}