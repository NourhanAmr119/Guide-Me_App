import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:jwt_decode/jwt_decode.dart';
import 'package:guide_me/city_page.dart';
import 'history_page.dart';
import 'home_page.dart';

class FavoritePage extends StatefulWidget {
  final String authToken;
  const FavoritePage({Key? key, required this.authToken}) : super(key: key);

  @override
  _FavoritePageState createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> {
  List<dynamic> favorites = [];

  @override
  void initState() {
    super.initState();
    fetchFavorites();
  }

  void fetchFavorites() async {
    try {
      String userName = decodeToken(widget.authToken);

      final response = await http.post(
        Uri.parse(
            'http://guideme.somee.com/api/TouristFavourites/GetTouristFavoritePlaces?touristname=$userName'),
        headers: {
          'Authorization': 'Bearer ${widget.authToken}',
          'Content-Type': 'application/json',
        },
      );

      print('Status code: ${response.statusCode}');
      if (response.statusCode == 200) {
        setState(() {
          favorites = jsonDecode(response.body);
          print('Favorites: $favorites');
        });
      } else {
        print('Failed to load favorites: ${response.body}');
      }
    } catch (e) {
      print('Caught error: $e');
    }
  }

  String decodeToken(String token) {
    Map<String, dynamic> decodedToken = Jwt.parseJwt(token);
    print('Decoded token: $decodedToken');
    return decodedToken[
    'http://schemas.xmlsoap.org/ws/2005/05/identity/claims/name'] ??
        '';
  }

  void removeFavorite(int index) async {
    try {
      String userName = decodeToken(widget.authToken);

      final response = await http.post(
        Uri.parse('http://guideme.somee.com/api/TouristFavourites/RemoveFavoritePlace'),
        headers: {
          'Authorization': 'Bearer ${widget.authToken}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'PlaceName': favorites[index]['name'], // Assuming 'name' corresponds to 'PlaceName'
          'TouristName': userName, // Assuming 'userName' corresponds to 'TouristName'
          'placeId': favorites[index]['id'],
        }),
      );

      print('Remove status code: ${response.statusCode}');
      if (response.statusCode == 200) {
        setState(() {
          favorites.removeAt(index);
        });
      } else {
        print('Failed to remove favorite: ${response.body}');
      }
    } catch (e) {
      print('Caught error: $e');
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Favorites"),
        backgroundColor: Color.fromARGB(255, 21, 82, 113),
      ),
      body: Container(
        color: Color.fromARGB(255, 21, 82, 113),
        child: ListView.builder(
          itemCount: favorites.length,
          itemBuilder: (context, index) {
            final favorite = favorites[index];
            return GestureDetector(
              onTap: () {
                // Handle tap event
              },
              child: Card(
                clipBehavior: Clip.antiAlias,
                child: Stack(
                  alignment: Alignment.topRight,
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
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        padding: EdgeInsets.all(8),
                        color: Colors.black.withOpacity(0.5),
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
                    Positioned(
                      top: 5,
                      right: 5,
                      child: IconButton(
                        icon: Icon(Icons.favorite, color: Colors.white),
                        onPressed: () {
                          removeFavorite(index); // Call removeFavorite method
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: CustomBottomNavigationBar(authToken: widget.authToken),
    );
  }
}

class CustomBottomNavigationBar extends StatelessWidget {
  final String authToken;

  const CustomBottomNavigationBar({Key? key, required this.authToken})
      : super(key: key);

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
                      builder: (context) => HomePage(token: authToken)),
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
                    builder: (context) => HistoryPage(token: authToken),
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
