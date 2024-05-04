import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:jwt_decode/jwt_decode.dart';

class RatePage extends StatefulWidget {
  final String placeName;
  final String token;

  RatePage({required this.placeName, required this.token});

  @override
  _RatePageState createState() => _RatePageState();
}

class _RatePageState extends State<RatePage> {
  int rating = 0;
  List<String> suggestions = [];
  List<String> selectedSuggestions = [];
  late String touristName;

  @override
  void initState() {
    super.initState();
    touristName = decodeToken(widget.token);
    fetchSuggestions();
  }

  String decodeToken(String token) {
    Map<String, dynamic> decodedToken = Jwt.parseJwt(token);
    print('Decoded token: $decodedToken');
    return decodedToken[
    'http://schemas.xmlsoap.org/ws/2005/05/identity/claims/name'] ??
        '';
  }

  Future<void> fetchSuggestions() async {
    final response = await http.get(
      Uri.parse(
          'http://guide-me.somee.com/api/Rating/$rating/Rating/Suggestion'),
      headers: {
        'Authorization': 'Bearer ${widget.token}',
        'accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      setState(() {
        suggestions = List<String>.from(json.decode(response.body));
      });
    } else {
      print('Failed to fetch suggestions: ${response.statusCode}');
    }
  }

  void toggleSuggestionSelection(String suggestion) {
    setState(() {
      if (selectedSuggestions.contains(suggestion)) {
        selectedSuggestions.remove(suggestion);
      } else {
        selectedSuggestions.add(suggestion);
      }
    });
  }

  Future<void> submitSuggestions() async {
    final response = await http.post(
      Uri.parse('http://guide-me.somee.com/Rating/Suggestion'),
      headers: {
        'Authorization': 'Bearer ${widget.token}',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'suggestion': selectedSuggestions, // Send all selected suggestions
        'placeName': widget.placeName,
        'touristName': touristName,
        'ratingNum': rating,
      }),
    );

    if (response.statusCode == 200) {
      print('Suggestions submitted successfully');
      // Show a dialog box if suggestions are submitted successfully
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Thanks for rating'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    } else {
      print('Failed to submit suggestions: ${response.statusCode}');
    }
  }

  void ratePlace() async {
    // Call API to submit rating
    final response = await http.post(
      Uri.parse('http://guide-me.somee.com/api/Rating/RatePlace'),
      headers: {
        'Authorization': 'Bearer ${widget.token}',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'placeName': widget.placeName,
        'touristName': touristName,
        'ratingNum': rating,
      }),
    );

    if (response.statusCode == 200) {
      print('Rating submitted successfully');
      await submitSuggestions();
    } else {
      print('Failed to submit rating: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Rate Place'),
        backgroundColor: Color.fromARGB(255, 21, 82, 113),
      ),
      backgroundColor: Color.fromARGB(255, 21, 82, 113),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top +
                kToolbarHeight), // Place content below app bar
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'Share your thoughts to help us improve ',
                style: TextStyle(fontSize: 30, color: Colors.white),
              ),
              SizedBox(height: 60),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return IconButton(
                    icon: Icon(
                      index < rating ? Icons.star : Icons.star_border,
                      color: Colors.yellow,
                      size: 60, // Even larger stars
                    ),
                    onPressed: () {
                      setState(() {
                        rating = index + 1;
                        fetchSuggestions();
                      });
                    },
                  );
                }),
              ),
              SizedBox(height: 30),
              Text(
                'Suggestions:',
                style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
              SizedBox(height: 30),
              Wrap(
                alignment: WrapAlignment.center,
                children: suggestions.map((suggestion) {
                  return ElevatedButton(
                    onPressed: () {
                      toggleSuggestionSelection(suggestion);
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: selectedSuggestions.contains(suggestion)
                          ? Colors.blueGrey[700]
                          : Colors.grey,
                      padding:
                      EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                    ),
                    child: Text(suggestion),
                  );
                }).toList(),
              ),
              SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  ratePlace();
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.black,
                  padding: EdgeInsets.symmetric(
                      horizontal: 30, vertical: 10), // Larger submit button
                ),
                child: Text('Submit Rating',
                    style: TextStyle(fontSize: 20)), // Larger text
              ),
            ],
          ),
        ),
      ),
    );
  }
}