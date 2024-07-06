import 'package:flutter/material.dart';
import 'package:guide_me/scan_place.dart';
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
import 'AppLocalization.dart';
import 'bottom_nav_bar.dart';

// Import your localization class

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
        Uri.parse(
            'http://guideme.runasp.net/api/Place/$cityName/$userName/Allplaces'),
        headers: {
          'Authorization': 'Bearer ${widget.token}',
          'accept': '/',
        },
      );
      if (response.statusCode == 200) {
        setState(() {
          places = jsonDecode(response.body);
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
            'http://guideme.runasp.net/api/TouristHistory?placename=${place['name']}&touristname=$touristName'),
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
              appLocalization: widget.appLocalization, // Pass the localization instance
              locale: widget.locale, // Pass the locale
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

  Future<double> fetchRating(String placeName, String touristName) async {
    try {
      var response = await http.get(
        Uri.parse(
            'http://guideme.runasp.net/api/Rating/$placeName/$touristName/OverAllRating'),
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
          'http://guideme.runasp.net/api/TouristFavourites/${isFavorite ? "AddFavoritePlace" : "RemoveFavoritePlace"}'),
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
    final favoritePlacesModel = Provider.of<FavoritePlacesModel>(context);
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
                  builder: (context) => SuggestionPage(token: widget.token,appLocalization: widget.appLocalization, // Pass the localization instance
                      locale: widget.locale), // Navigate to SuggestionPage with token
                ),
              );
            },
          ),
          actions: [
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ScanPage(token: widget.token, cityName: widget.title,appLocalization: widget.appLocalization, // Pass the localization instance
                      locale: widget.locale)),
                );
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
              icon: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search, color: Colors.white),
                  SizedBox(height: 2),
                  Text(
                    appLocalization.translate('search'),
                    style: TextStyle(color: Colors.white, fontSize: 9),
                  ),
                ],
              ),
              onPressed: () {
                showSearch<String>(
                  context: context,
                  delegate:
                  CustomSearchDelegate(context: context, token: widget.token, cityName: widget.title, touristName: decodeToken(widget.token),appLocalization: widget.appLocalization, // Pass the localization instance
                      locale: widget.locale),
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
        bottomNavigationBar: BottomNavBar(
          token: widget.token,
          appLocalization: widget.appLocalization,
          locale: widget.locale,
        ),
      ),
    );
  }

  List<Widget> buildCategoryCards(String category) {
    List<Widget> cards = [];
    final model = Provider.of<FavoritePlacesModel>(context);
    for (var place in places) {
      if (place['category'] == category) {
        bool isFavorite = place['favoriteFlag'] ==
            1; // Initialize favorite state based on favoriteFlag
        cards.add(
          GestureDetector(
            onTap: () {
              _onTapCard(place, widget.token); // Pass the entire place object
            },
            child: SizedBox(
              height: 250,
              child: Card(
                elevation: 5,
                margin:
                const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
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
                          await updateFavoritePlace(place['name'], !isFavorite);
                          setState(() {
                            // Update favorite state after adding/removing from favorites
                            place['favoriteFlag'] = isFavorite ? 0 : 1;
                          });
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
                        child:Column(
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
                              future: fetchRating(place['name'], decodeToken(widget.token)),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState == ConnectionState.waiting) {
                                  return CircularProgressIndicator();
                                } else if (snapshot.hasError) {
                                  return Text(widget.appLocalization.translate('error_loading_rating'));
                                } else {
                                  final rating = snapshot.data ?? 0.0;
                                  return _buildRatingStars(rating);
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

class CustomSearchDelegate extends SearchDelegate<String> {
  final String cityName;
  final String touristName;
  final String token;
  final BuildContext context;
  final Locale? locale;
  final AppLocalization appLocalization;// Add context here

  CustomSearchDelegate({
    required this.context,
    required this.cityName,
    required this.touristName,
    required this.token,
    required this.appLocalization, // Add this line
    this.locale,
  });

  @override
  ThemeData appBarTheme(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return theme.copyWith(
      scaffoldBackgroundColor: const Color.fromARGB(255, 21, 82, 113),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color.fromARGB(140, 21, 82, 113),
      ),
    );
  }

  @override
  List<Widget> buildActions(BuildContext context) {
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
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSearchResults(context);
  }

  Future<void> addPlaceToHistory(String placeName) async {
    try {
      final url = Uri.parse(
          'http://guideme.runasp.net/api/TouristHistory?placename=${Uri.encodeComponent(placeName)}&touristname=${Uri.encodeComponent(touristName)}');

      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'accept': '/',
          'Content-Type': 'application/json',
        },
      );

      print('Request URL: $url');
      print('Response Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        print('Place added to history successfully');
        // Handle success as needed, e.g., navigate to a new page
      } else {
        print('Failed to add place to history: ${response.statusCode}');
        // Handle failure, e.g., show a SnackBar with an error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add place to history: ${response.statusCode}'),
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      print('Exception caught: $e');
      // Handle exceptions, e.g., show a SnackBar with the exception message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Exception: $e'),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  String get searchFieldLabel => appLocalization.translate('search') ?? '';

  Widget _buildSearchResults(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future:searchPlace(query, cityName, touristName, token),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text(appLocalization.translate('no_results') ?? ''));
        } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
          final places = snapshot.data!;

          return ListView.builder(
            itemCount: places.length,
            itemBuilder: (context, index) {
              final place = places[index];

              return GestureDetector(
                  onTap: () {
                    _onTapCard(place);
                  },
                  child:Card(
                    margin: EdgeInsets.symmetric(vertical: 25, horizontal: 60),
                    clipBehavior: Clip.antiAlias,
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width * 0.7, // Adjust the width as needed
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          Image.network(
                            place['placeImage'] ?? '', // Ensure place['placeImage'] is not null
                            width: 50,
                            height: 130,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Placeholder(
                              fallbackWidth: 50,
                              fallbackHeight: 50,
                            ),
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Center(child: CircularProgressIndicator());
                            },
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              place['placeName'] ?? 'Unknown Place',
                              style: Theme.of(context).textTheme.subtitle1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )

              );
            },
          );
        } else {
          return Center(child: Text('No results found.'));
        }
      },
    );
  }

  Future<List<Map<String, dynamic>>> searchPlace(String placeName, String cityName, String touristName, String token) async {
    final url = Uri.parse(
        'http://guideme.runasp.net/api/Place/${Uri.encodeComponent(placeName)}/${Uri.encodeComponent(cityName)}/${Uri.encodeComponent(touristName)}/SearchPlace');

    print('API URL: $url');  // Debugging statement
    print('Token: $token');  // Debugging statement

    final response = await http.get(
      url,
      headers: {
        'accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    print('Response Status: ${response.statusCode}');  // Debugging statement
    print('Response Body: ${response.body}');  // Debugging statement

    if (response.statusCode == 200) {
      dynamic jsonData = jsonDecode(response.body);

      if (jsonData is List) {
        List<Map<String, dynamic>> places = [];
        for (var item in jsonData) {
          if (item is Map<String, dynamic>) {
            places.add(item);
          }
        }
        return places;
      } else if (jsonData is Map<String, dynamic>) {
        return [jsonData];
      } else {
        throw Exception('Unexpected response format');
      }
    } else {
      throw Exception('Failed to load places: ${response.statusCode}');
    }
  }
  void _onTapCard(Map<String, dynamic> place) async {
    try {
      final String placeName = place['placeName'] ?? 'Unknown Place';

      await addPlaceToHistory(placeName);

      // Print the parameters before navigating
      print('Navigating to PlacePage with parameters:');
      print('touristName: $touristName');
      print('cityName: $cityName');
      print('place: $place');
      print('token: $token');

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PlacePage(
            touristName: touristName,
            cityName: cityName,
            place: {
              'name': place['placeName'],
              'image': place['placeImage'],
            },
            token: token,
            appLocalization: appLocalization, // Pass the localization instance
            locale: locale,
          ),
        ),
      );
    } catch (e) {
      print('Error tapping card: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

}