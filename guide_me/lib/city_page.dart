import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'favorite_page.dart';
import 'package:jwt_decode/jwt_decode.dart';

class CityPage extends StatefulWidget {
  final String title;
  final String token; // Add token field

  const CityPage({Key? key, required this.title, required this.token})
      : super(key: key);

  @override
  _CityPageState createState() => _CityPageState();
}

class _CityPageState extends State<CityPage> {
  List<dynamic> places = [];
  int _currentIndex = 0;
  ScrollController _scrollController = ScrollController();
  bool _showAppbarColor = false;
  List<String> favoritePlaces = [];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    fetchData(widget.title); // Pass the city name here
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

  List<Widget> buildCategoryCards(String category) {
    List<Widget> cards = [];
    for (var place in places) {
      if (place['category'] == category) {
        bool isFavorite = favoritePlaces.contains(place['name']);
        cards.add(
          SizedBox(
            height: 250, // Specify the desired height for all cards
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
                        color: isFavorite ? Colors.white : Colors.white,
                      ),
                      onPressed: () async {
                        setState(() {
                          if (isFavorite) {
                            favoritePlaces.remove(place['name']);
                          } else {
                            favoritePlaces.add(place['name']);
                          }
                        });

                        // Update favorite place on the server
                        await updateFavoritePlace(place['name'], isFavorite);
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
                        color: Colors.black54
                            .withOpacity(_showAppbarColor ? 0.5 : 0.8),
                      ),
                      child: Text(
                        place['name'],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }
    }
    return cards;
  }

  Future<void> updateFavoritePlace(String placeName, bool isFavorite) async {
    final String touristName = decodeToken(widget.token);
    final Map<String, String> body = {
      "placeName": placeName,
      "touristName": touristName,
    };

    final response = await http.post(
      Uri.parse('http://guide-me.somee.com/api/TouristFavourites/AddFvoritePlace'),
      headers: {
        'Authorization': 'Bearer ${widget.token}',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode != 200) {
      print('Failed to update favorite place: ${response.statusCode}');
    }
  }

  String decodeToken(String token) {
    Map<String, dynamic> decodedToken = Jwt.parseJwt(token);
    return decodedToken['name'];
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
    Navigator.pop(
    context); // Navigate back to the previous screen
    },
    ),IconButton(
        icon: const Icon(Icons.favorite),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  favorite_page(favoritePlaces: favoritePlaces),
            ),
          );
        },
      ),
      IconButton(
        icon: const Icon(Icons.history),
        onPressed: () {
          // Navigate to history page
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
}