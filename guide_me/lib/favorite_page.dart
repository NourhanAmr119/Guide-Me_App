import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:jwt_decode/jwt_decode.dart'; // Import the jwt_decode package
import 'package:guide_me/city_page.dart'; // Import city_page for navigation
import 'history_page.dart';
import 'home_page.dart';

class favorite_page extends StatefulWidget {
  final String authToken;
  const favorite_page({Key? key, required this.authToken}) : super(key: key);

  @override
  _FavoritePageState createState() => _FavoritePageState();
}

class _FavoritePageState extends State<favorite_page> {
  List<dynamic> favorites = [];

  @override
  void initState() {
    super.initState();
    fetchFavorites();
  }

  void fetchFavorites() async {
    try {
      // Decode the token to extract the user name
      String userName = decodeToken(widget.authToken);

      final response = await http.post(
        Uri.parse(
            'http://guide-me.somee.com/api/TouristFavourites/GetTouristFavoritePlaces?touristname=$userName'),
        headers: {
          'Authorization': 'Bearer ${widget.authToken}',
          'Content-Type': 'application/json',
        },
      );

      print('Status code: ${response.statusCode}'); // Print status code
      if (response.statusCode == 200) {
        setState(() {
          favorites = jsonDecode(response.body);
          print('Favorites: $favorites'); // Print the favorites data
        });
      } else {
        print(
            'Failed to load favorites: ${response.body}'); // Print error response
      }
    } catch (e) {
      print('Caught error: $e'); // Print errors if any
    }
  }

  String decodeToken(String token) {
    Map<String, dynamic> decodedToken = Jwt.parseJwt(token);
    print('Decoded token: $decodedToken');
    return decodedToken[
            'http://schemas.xmlsoap.org/ws/2005/05/identity/claims/name'] ??
        '';
  }

  void handleFavoriteStatusChange(dynamic favorite) async {
    try {
      // Extract necessary data from the favorite object
      int favoriteId = favorite['id'];
      bool isFavorite = favorite['isFavorite'];

      // Send a request to the server to update the favorite status
      final response = await http.put(
        Uri.parse(
            'http://guide-me.somee.com/api/TouristFavourites/UpdateFavoriteStatus'),
        headers: {
          'Authorization': 'Bearer ${widget.authToken}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'favoriteId': favoriteId,
          'isFavorite': !isFavorite, // Toggle the favorite status
        }),
      );

      if (response.statusCode == 200) {
        print('Favorite status updated successfully');
      } else {
        print('Failed to update favorite status: ${response.body}');
      }
    } catch (e) {
      print('Error updating favorite status: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Favorites"),
        backgroundColor: Color.fromARGB(
            255, 21, 82, 113), // Set the background color of app bar
      ),
      body: Container(
        color: Color.fromARGB(
            255, 21, 82, 113), // Set the background color of the page
        child: ListView.builder(
          itemCount: favorites.length,
          itemBuilder: (context, index) {
            final favorite = favorites[index];
            return Padding(
              padding: EdgeInsets.all(8.0),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    height: 200,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: NetworkImage(
                          favorite['media'][0]['mediaContent'],
                        ),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 8,
                    left: 8,
                    right: 8,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(
                            0.5), // Semi-transparent black background
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        favorite['name'],
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: CustomBottomNavigationBar(authToken: widget.authToken),
 // Add the custom bottom navigation bar
    );
  }
}

class CustomBottomNavigationBar extends StatelessWidget {
  final String authToken;

  const CustomBottomNavigationBar({Key? key, required this.authToken}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      elevation: 0,
      color: Color.fromARGB(255, 21, 82, 113),
      child: Container(
        height: 60,
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.home),
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                      builder: (context) => home_page(token: authToken)),
                  (Route<dynamic> route) => false,
                );
              },
            ),
            IconButton(
              icon: Icon(Icons.favorite),
              onPressed: () {
                // Do nothing as we are already on the favorite page
              },
            ),
            IconButton(
              icon: Icon(Icons.history),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => history_page(token: authToken),
                  ),
                );
              },
            ),
            IconButton(
              icon: Icon(Icons.account_circle),
              onPressed: () {
                // Navigate to account page
              },
            ),
          ],
        ),
      ),
    );
  }
}
