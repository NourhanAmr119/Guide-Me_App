import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decode/jwt_decode.dart';

class ReviewPage extends StatefulWidget {
  final String token;
  final String placeName;

  ReviewPage({required this.token, required this.placeName});

  @override
  _ReviewPageState createState() => _ReviewPageState();
}

class _ReviewPageState extends State<ReviewPage> {
  List<dynamic> reviews = [];

  @override
  void initState() {
    super.initState();
    fetchReviews();
  }

  Future<void> fetchReviews() async {
    final response = await http.get(
      Uri.parse('http://guide-me.somee.com/api/Review/GetReviews?placeName=${widget.placeName}'),
      headers: {
        'Authorization': 'Bearer ${widget.token}',
        'accept': '/',
      },
    );

    if (response.statusCode == 200) {
      setState(() {
        reviews = json.decode(response.body);
      });
    } else {
      print('Failed to fetch reviews: ${response.statusCode}');
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reviews'),
        backgroundColor: Color.fromARGB(255, 21, 82, 113),
        actions: [
          IconButton(
            icon: Icon(Icons.comment),
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  String comment = '';

                  return AlertDialog(
                    title: Text('Add Review'),
                    content: TextField(
                      onChanged: (value) {
                        comment = value;
                      },
                      decoration: InputDecoration(
                        hintText: 'Enter your comment',
                      ),
                    ),
                    actions: [
                      ElevatedButton(
                        onPressed: () {
                          addReview(comment);
                          Navigator.pop(context);
                        },
                        child: Text('Add Review'),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
      body: Container(
        color: Color.fromARGB(255, 21, 82, 113), // Same as the app bar color
        child: ListView.builder(
          itemCount: reviews.length,
          itemBuilder: (context, index) {
            return Card(
              color: Colors.grey, // Dark gray color
              margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      reviews[index]['touristName'],
                      style: TextStyle(fontWeight: FontWeight.bold,fontSize:20, color: Colors.white),
                    ),
                    SizedBox(height: 8),
                    Text(
                      reviews[index]['comment'],
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> addReview(String comment) async {
    final response = await http.post(
      Uri.parse('http://guide-me.somee.com/api/Review/AddReview'),
      headers: {
        'Authorization': 'Bearer ${widget.token}',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'placeName': widget.placeName,
        'touristName': decodeToken(widget.token),
        'comment': comment,
      }),
    );

    if (response.statusCode == 200) {
      // If the review is added successfully, fetch the reviews again to update the list
      fetchReviews();
    } else {
      print('Failed to add review: ${response.statusCode}');
    }
  }

  String decodeToken(String token) {
    Map<String, dynamic> decodedToken = Jwt.parseJwt(token);
    print('Decoded token: $decodedToken');
    return decodedToken['http://schemas.xmlsoap.org/ws/2005/05/identity/claims/name'] ?? '';
  }

}
