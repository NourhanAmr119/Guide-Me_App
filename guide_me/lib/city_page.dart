import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:jwt_decode/jwt_decode.dart';
import 'favorite_page.dart';
import 'place_page.dart';
import 'history_page.dart';
import 'profile_page.dart';
import 'package:provider/provider.dart';
import 'favorite_places_model.dart';
import 'suggest_place.dart';
import 'AppLocalization.dart'; // Import your localization class

class CityPage extends StatefulWidget {
  final String title;
  final String token;
  final Locale? locale;
  final AppLocalization appLocalization; // Receive AppLocalization here
  const CityPage({
    Key? key,
    required this.title,
    required this.token,
    required this.appLocalization,
    this.locale,
  }) : super(key: key);

  @override
  _CityPageState createState() => _CityPageState();
}

class _CityPageState extends State<CityPage> {
  final Locale? locale; // Add locale property
  _CityPageState({this.locale}); // Update constructor to accept locale
  List<dynamic> places = [];
  List<String> categories = [];
  int _currentIndex = 0;
  ScrollController _scrollController = ScrollController();
  bool _showAppbarColor = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    fetchData(widget.title, decodeToken(widget.token));
  }

  Future<void> fetchData(String cityName, String userName) async {
    try {
      var response = await http.get(
        Uri.parse('http://guideme.somee.com/api/Place/$cityName/$userName/Allplaces'),
        headers: {
          'Authorization': 'Bearer ${widget.token}',
          'accept': '/',
        },
      );
      if (response.statusCode == 200) {
        setState(() {
          places = jsonDecode(response.body)['\$values'];
          categories = places
              .map<String>((place) => place['category'].toString())
              .toSet()
              .toList();
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
      final String touristName = decodeToken(token);
      final response = await http.post(
        Uri.parse(
            'http://guideme.somee.com/api/TouristHistory?placename=${place['name']}&touristname=$touristName'),
        headers: {
          'Authorization': 'Bearer $token',
          'accept': '/',
        },
      );

      if (response.statusCode == 200) {
        print('Place added to history successfully');
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PlacePage(
              touristName: decodeToken(widget.token),
              cityName: widget.title,
              place: place,
              token: widget.token,
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
        Uri.parse(
            'http://guideme.somee.com/api/Rating/$placeName/OverAllRating'),
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
          'http://guideme.somee.com/api/TouristFavourites/${isFavorite ? "AddFavoritePlace" : "RemoveFavoritePlace"}'),
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
    final appLocalization = widget.appLocalization; // Access AppLocalization instance

    // Example usage
    print('Current language code: ${appLocalization.locale.languageCode}');
    return DefaultTabController(
      length: categories.length,
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
            icon: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.lightbulb_outline, color: Colors.white),
                SizedBox(height: 2),
                Text(
                  appLocalization.translate('suggest'),
                  style: TextStyle(color: Colors.white, fontSize: 9),
                ),
              ],
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SuggestionPage(token: widget.token), // Navigate to SuggestionPage with token
                ),
              );
            },
          ),
          actions: [
            IconButton(
              onPressed: () {
                // Handle your scan action
              },
              icon: Column(
                children: [
                  Image.asset(
                    'assets/scan_icon.jpg',
                    width: 34,  // Adjust the width as needed
                    height: 24, // Adjust the height as needed
                    // color: Colors.white, // Apply color filter if necessary
                  ),
                  SizedBox(height: 2), // Adjust the height as needed for spacing
                  Text(appLocalization.translate('scan'), style: TextStyle(color: Colors.white, fontSize: 9)),
                ],
              ),
            ),
            SizedBox(width: 8), // Space between icons
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                showSearch<String>(
                  context: context,
                  delegate:
                  CustomSearchDelegate(context: context, token: widget.token, cityName: widget.title, touristName: decodeToken(widget.token)),
                );
              },
            ),
          ],
          bottom: categories.isNotEmpty
              ? TabBar(
            isScrollable: true,
            tabs: categories.map((category) => Tab(text: category)).toList(),
          )
              : null,
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
            child: categories.isNotEmpty
                ? TabBarView(
              children: categories
                  .map((category) => ListView(
                controller: _scrollController,
                children: buildCategoryCards(category),
              ))
                  .toList(),
            )
                : Center(child: CircularProgressIndicator()),
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
                        builder: (context) => FavoritePage(
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
                        builder: (context) => HistoryPage(
                          token: widget.token,

                        ),
                      ),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.person),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProfilePage(token: widget.token),
                      ),
                    );
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
    return places
        .where((place) => place['category'] == category)
        .map<Widget>((place) => GestureDetector(
      onTap: () {
        _onTapCard(place, widget.token);
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          children: [
            Image.network(
              place['imageUrl'],
              height: 200,
              fit: BoxFit.cover,
            ),
            ListTile(
              title: Text(place['name']),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(place['description']),
                  FutureBuilder<double>(
                    future: fetchRating(place['name']),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return CircularProgressIndicator();
                      } else if (snapshot.hasError) {
                        return Text('Error loading rating');
                      } else {
                        return _buildRatingStars(snapshot.data ?? 0.0);
                      }
                    },
                  ),
                  ChangeNotifierProvider(
                    create: (context) => FavoritePlacesModel(),
                    child: Consumer<FavoritePlacesModel>(
                      builder: (context, favoritePlacesModel, child) {
                        bool isFavorite = favoritePlacesModel.favoritePlaces
                            .contains(place['name']);
                        return IconButton(
                          icon: Icon(
                            isFavorite ? Icons.favorite : Icons.favorite_border,
                          ),
                          onPressed: () {
                            setState(() {
                              isFavorite
                                  ? favoritePlacesModel
                                  .remove(place['name'])
                                  : favoritePlacesModel
                                  .add(place['name']);
                              updateFavoritePlace(
                                  place['name'], !isFavorite);
                            });
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ))
        .toList();
  }
}

class CustomSearchDelegate extends SearchDelegate<String> {
  final BuildContext context;
  final String token;
  final String cityName;
  final String touristName;

  CustomSearchDelegate({
    required this.context,
    required this.token,
    required this.cityName,
    required this.touristName,
  });

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final appLocalization = AppLocalization.of(context);

    if (query.isEmpty) {
      return Center(
        child: Text(appLocalization.translate('search')),
      );
    } else {
      return FutureBuilder<List<dynamic>>(
        future: searchPlaces(query),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text(appLocalization.translate('fetch_search_results_error')));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text(appLocalization.translate('no_results')));
          } else {
            return ListView(
              children: snapshot.data!.map((place) {
                return ListTile(
                  title: Text(place['name']),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PlacePage(
                          touristName: touristName,
                          cityName: cityName,
                          place: place,
                          token: token,
                        ),
                      ),
                    );
                  },
                );
              }).toList(),
            );
          }
        },
      );
    }
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final appLocalization = AppLocalization.of(context);

    if (query.isEmpty) {
      return Center(
        child: Text(appLocalization.translate('search_hint')),
      );
    } else {
      return FutureBuilder<List<dynamic>>(
        future: searchPlaces(query),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text(appLocalization.translate('fetch_search_results_error')));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text(appLocalization.translate('no_results')));
          } else {
            return ListView(
              children: snapshot.data!.map((place) {
                return ListTile(
                  title: Text(place['name']),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PlacePage(
                          touristName: touristName,
                          cityName: cityName,
                          place: place,
                          token: token,
                        ),
                      ),
                    );
                  },
                );
              }).toList(),
            );
          }
        },
      );
    }
  }

  Future<List<dynamic>> searchPlaces(String query) async {
    try {
      var response = await http.get(
        Uri.parse(
            'http://guide-me.somee.com/api/Place/$cityName/$touristName/search/$query'),
        headers: {
          'Authorization': 'Bearer $token',
          'accept': '/',
        },
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print('Failed to search places: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Exception caught: $e');
      return [];
    }
  }
}
