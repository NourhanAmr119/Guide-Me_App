import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:jwt_decode/jwt_decode.dart';
import 'package:provider/provider.dart';
import 'AppLocalization.dart';
import 'place_page.dart';
import 'bottom_nav_bar.dart';
import 'favorite_places_model.dart';

class FavoritePage extends StatefulWidget {
  final String authToken;
  final Locale? locale;
  final AppLocalization appLocalization;

  const FavoritePage({Key? key, required this.authToken, required this.appLocalization, this.locale}) : super(key: key);

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
      final model = Provider.of<FavoritePlacesModel>(context, listen: false);
      final response = await http.post(
        Uri.parse(
            'http://guideme.runasp.net/api/TouristFavourites/GetTouristFavoritePlaces?touristname=$userName'),
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
  void _onTapCard(Map<String, dynamic> place) async {
    try {
      final String touristName = decodeToken(widget.authToken);
      final response = await http.post(
        Uri.parse(
            'http://guideme.runasp.net/api/TouristHistory?placename=${place['name']}&touristname=$touristName'),
        headers: {
          'Authorization': 'Bearer ${widget.authToken}',
          'accept': '/',
        },
      );

      if (response.statusCode == 200) {
        print('Place added to history successfully');
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PlacePage(
              touristName: touristName,
              cityName: '',
              place: place,
              token: widget.authToken,
              appLocalization: widget.appLocalization,
              locale: widget.locale,
            ),
          ),
        );
      } else {
        print('Failed to add place to history: ${response.statusCode}');
      }
    } catch (e) {
      print('Exception caught: $e');
    }
  }

  void removeFavorite(int index) async {
    try {
      String userName = decodeToken(widget.authToken);
      final model = Provider.of<FavoritePlacesModel>(context, listen: false);
      final response = await http.post(
        Uri.parse('http://guideme.runasp.net/api/TouristFavourites/RemoveFavoritePlace'),
        headers: {
          'Authorization': 'Bearer ${widget.authToken}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'PlaceName': favorites[index]['name'],
          'TouristName': userName,
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
        title: Text(widget.appLocalization.translate("Favorites")),
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
                _onTapCard(favorite);
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
                          removeFavorite(index);
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
      bottomNavigationBar: BottomNavBar(
        token: widget.authToken,
        appLocalization: widget.appLocalization,
        locale: widget.locale,
      ),
    );
  }
}