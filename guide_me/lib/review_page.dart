import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decode/jwt_decode.dart';
import 'AppLocalization.dart';

class ReviewPage extends StatefulWidget {
  final String token;
  final String placeName;
  final Locale? locale;
  final AppLocalization appLocalization;

  ReviewPage({required this.token, required this.placeName,required this.appLocalization, // Add this line
    this.locale,});

  @override
  _ReviewPageState createState() => _ReviewPageState();
}

class _ReviewPageState extends State<ReviewPage> {
  List<dynamic> reviews = [];
  TextEditingController _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchReviews();
  }

  Future<void> fetchReviews() async {
    final response = await http.get(
      Uri.parse('http://guideme.runasp.net/api/Review/GetReviews?placeName=${widget.placeName}'),
      headers: {
        'Authorization': 'Bearer ${widget.token}',
        'accept': '/',
      },
    );

    if (response.statusCode == 200) {
      setState(() {
        reviews = json.decode(response.body);
        print('Fetched reviews: $reviews'); // Debug: Check fetched reviews
      });
    } else {
      print('Failed to fetch reviews: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalization appLocalization = AppLocalization.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(appLocalization.translate('Reviews')),
        titleTextStyle: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
        backgroundColor: Color.fromARGB(255, 246, 243, 177),
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: Column(
          children: [
      Expanded(
      child: Container(
      color: Color.fromARGB(255, 246, 243, 177),
      child: ListView.builder(
        itemCount: reviews.length,
        itemBuilder: (context, index) {
          String photoUrl = reviews[index]['photoUrl'] ?? '';
          String touristName = reviews[index]['touristName'] ?? 'Unknown';
          String comment = reviews[index]['comment'] ?? '';
          print('Review $index: photoUrl=$photoUrl, touristName=$touristName');

          return Card(
            color: Colors.white,
            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: Colors.white, // Set background color to white
                        backgroundImage: photoUrl.isNotEmpty
                            ? NetworkImage(photoUrl)
                            : null,
                        child: photoUrl.isEmpty
                            ? Icon(Icons.person, color: Colors.black, size: 30) // Default icon is black
                            : null,
                      ),
                      SizedBox(width: 8),
                      Text(
                        touristName,
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.black),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 55), // Change the horizontal padding as needed
                    child: Text(
                      comment,
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    ),
    ),
    Container(
    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    color: Color.fromARGB(255, 246, 243, 177),
    child: Row(
    children: [
    Expanded(
    child: TextField(
    controller: _commentController,
    decoration: InputDecoration(
    hintText: 'Enter your comment',
      hintStyle: TextStyle(color: Colors.grey),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20.0), // Add border radius for rounded corners
      ),
      filled: true,
      fillColor: Colors.white,
      contentPadding: EdgeInsets.symmetric(vertical: 22, horizontal: 12),
    ),
      style: TextStyle(color: Colors.black),
    ),
    ),
      IconButton(
        icon: Icon(Icons.send, color: Colors.black),
        onPressed: () {
          String comment = _commentController.text;
          if (comment.isNotEmpty) {
            addReview(comment);
            _commentController.clear();
          }
        },
      ),
    ],
    ),
    ),
          ],
      ),
    );
  }

  Future<void> addReview(String comment) async {
    final response = await http.post(
      Uri.parse('http://guideme.runasp.net/api/Review/AddReview'),
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
      fetchReviews();
      print('success add review');
    } else {
      print('Failed to add review: ${response.statusCode}');
    }
  }

  String decodeToken(String token) {
    Map<String, dynamic> decodedToken = Jwt.parseJwt(token);
    print('Decoded token: $decodedToken');
    return decodedToken['http://schemas.xmlsoap.org/ws/2005/05/identity/claims/name'] ?? 'Unknown';
  }
}