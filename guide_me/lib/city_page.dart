import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:jwt_decode/jwt_decode.dart';
import 'favorite_page.dart'; // Import FavoritePage if not imported already
import 'place_page.dart'; // Import PlacePage
import 'history_page.dart';
import 'package:provider/provider.dart';
import 'favorite_places_model.dart';
class city_page extends StatefulWidget {
  final String title;
  final String token;

  const city_page({Key? key, required this.title, required this.token})
      : super(key: key);

  @override
  _CityPageState createState() => _CityPageState();
}

class _CityPageState extends State<city_page> {
  List<dynamic> places = [];
  int _currentIndex = 0;
  ScrollController _scrollController = ScrollController();
  bool _showAppbarColor = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    fetchData(widget.title);
  }

  Future<void> fetchData(String cityName) async {
    try {
      var response = await http.get(
        Uri.parse('http://guide-me.somee.com/api/Place/$cityName/Allplaces'),
        headers: {
          'Authorization': 'Bearer ${widget.token}',
        },
      );
      if (response.statusCode == 200) {
        setState(() {
          places = jsonDecode(response.body);
        });
      } else {
        print('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      print('Exception caught: $e');
    }
  }

  void _onScroll() {
    if (_scrollController.offset > 50 && !_showAppbarColor) {
      setState(() {
        _showAppbarColor = true;
      });
    } else if (_scrollController.offset <= 50 && _showAppbarColor) {
      setState(() {
        _showAppbarColor = false;
      });
    }
  }

  void _onTapCard(Map<String, dynamic> place, String token) async {
    try {
      final String touristName = decodeToken(token); // Decode token to get tourist name
      final response = await http.post(
        Uri.parse('http://guide-me.somee.com/api/TouristHistory?placename=${place['name']}&touristname=$touristName'),
        headers: {
          'Authorization': 'Bearer $token',
          'accept': '/',
        },
      );

      if (response.statusCode == 200) {
        print('Place added to history successfully');
        // Navigate to the place page
        print('Place data: $place');
        Navigator.push(
          context,

          MaterialPageRoute(builder: (context) => PlacePage(place: place, token: token)),
        );
      } else {
        print('Failed to add place to history: ${response.statusCode}');
      }
    } catch (e) {
      print('Exception caught: $e');
    }
  }
  Widget _buildRatingStars(double rating) {
    int roundedRating = rating.round();
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        if (index < roundedRating) {
          return Icon(Icons.star, color: Colors.yellow);
        } else {
          return Icon(Icons.star_border, color: Colors.grey);
        }
      }),
    );
  }

  Future<double> fetchRating(String placeName) async {
    try {
      var response = await http.get(
        Uri.parse('http://guide-me.somee.com/api/Rating/$placeName/OverAllRating'),
        headers: {
          'Authorization': 'Bearer ${widget.token}',
        },
      );
      if (response.statusCode == 200) {
        return double.parse(response.body);
      } else {
        print('Failed to load rating: ${response.statusCode}');
        return 0.0;
      }
    } catch (e) {
      print('Exception caught: $e');
      return 0.0;
    }
  }

  Future<void> updateFavoritePlace(String placeName, bool isFavorite) async {
    final String touristName = decodeToken(widget.token);
    final Map<String, String> body = {
      "placeName": placeName,
      "touristName": touristName,
    };

    final response = await http.post(
      Uri.parse(
          'http://guide-me.somee.com/api/TouristFavourites/${isFavorite ? "AddFavoritePlace" : "RemoveFavoritePlace"}'),
      headers: {
        'Authorization': 'Bearer ${widget.token}',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      print(isFavorite
          ? 'Favorite place added successfully'
          : 'Favorite place removed successfully');
    } else {
      print('Failed to update favorite place: ${response.statusCode}');
    }
  }

  String decodeToken(String token) {
    Map<String, dynamic> decodedToken = Jwt.parseJwt(token);
    print('Decoded token: $decodedToken');
    return decodedToken[
    'http://schemas.xmlsoap.org/ws/2005/05/identity/claims/name'] ??
        '';
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: _showAppbarColor
              ? Color.fromARGB(255, 21, 82, 113)
              : Colors.transparent,
          elevation: 0.0,
          centerTitle: true,
          title: Text(
            widget.title,
            style: const TextStyle(color: Colors.white, fontSize: 25),
          ),
          leading: IconButton(
            icon: const Icon(Icons.lightbulb_outline, color: Colors.white),
            onPressed: () {},
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.qr_code, color: Colors.white),
              onPressed: () {},
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Historical'),
              Tab(text: 'Entertainment'),
              Tab(text: 'Religious'),
            ],
          ),
        ),
        body: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/background_image.jpg'),
              fit: BoxFit.cover,
            ),
          ),
          child: NotificationListener<ScrollNotification>(
            onNotification: (scrollNotification) {
              _onScroll();
              return true;
            },
            child: TabBarView(
              children: [
                ListView(
                  controller: _scrollController,
                  children: buildCategoryCards('Historical'),
                ),
                ListView(
                  controller: _scrollController,
                  children: buildCategoryCards('Entertainment'),
                ),
                ListView(
                  controller: _scrollController,
                  children: buildCategoryCards('Religious'),
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: BottomAppBar(
          elevation: 0,
          color: const Color.fromARGB(255, 21, 82, 113),
          child: Container(
            height: 60,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.home),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.favorite),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => favorite_page(
                          authToken: widget.token,
                        ),
                      ),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.history),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => history_page(token: widget.token),
                      ),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.account_circle),
                  onPressed: () {
                    // Navigate to account page
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> buildCategoryCards(String category) {
    List<Widget> cards = [];
    final model = Provider.of<FavoritePlacesModel>(context);
    for (var place in places) {
      if (place['category'] == category) {
        bool isFavorite = model.isFavorite(place['name']);
        cards.add(
          GestureDetector(
            onTap: () {
              _onTapCard(place, widget.token); // Pass the entire place object
            },
            child: SizedBox(
              height: 250,
              child: Card(
                elevation: 5,
                margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(15.0),
                        child: Image.network(
                          place['media'][0]['mediaContent'],
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 10,
                      right: 10,
                      child: IconButton(
                        icon: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: Colors.white,
                        ),
                        onPressed: () async {
                          if (isFavorite) {
                            model.remove(place['name']);
                          } else {
                            model.add(place['name']);
                          }
                          await updateFavoritePlace(
                              place['name'], !isFavorite);
                        },
                      ),
                    ),
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(15.0),
                            bottomRight: Radius.circular(15.0),
                          ),
                          color: Colors.black54.withOpacity(_showAppbarColor ? 0.5 : 0.8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              place['name'],
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            FutureBuilder<double>(
                              future: fetchRating(place['name']), // Fetch the rating for the place
                              builder: (context, snapshot) {
                                if (snapshot.connectionState == ConnectionState.waiting) {
                                  return CircularProgressIndicator();
                                } else if (snapshot.hasError) {
                                  return Text('Error: ${snapshot.error}');
                                } else {
                                  return _buildRatingStars(snapshot.data ?? 0); // Use the fetched rating to display stars
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }
    }
    return cards;
  }


}