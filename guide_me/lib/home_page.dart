import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';

import 'AppLocalization.dart';
import 'city_page.dart';
import 'favorite_page.dart';
import 'history_page.dart';

class HomePage extends StatefulWidget {
  final String token;

  const HomePage({Key? key, required this.token}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ScrollController _scrollController = ScrollController();
  bool _showAppbarColor = false;
  List<Map<String, dynamic>> cities = [];
  Locale? _locale;
  late AppLocalization _appLocalization = AppLocalization(Locale('en'));

  @override
  void initState() {
    super.initState();
    _fetchCities();
    _scrollController.addListener(_onScroll);
    _fetchInitialData();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  String decodeToken(String token) {
    Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
    return decodedToken[
    'http://schemas.xmlsoap.org/ws/2005/05/identity/claims/name'];
  }

  Future<void> _fetchInitialData() async {
    await _fetchLanguage();
  }

  Future<void> _fetchLanguage() async {
    String touristName = decodeToken(widget.token);
    try {
      final response = await http.get(
        Uri.parse(
            'http://guideme.runasp.net/api/Tourist/GetTouristInfo/$touristName'),
        headers: {
          'Authorization': 'Bearer ${widget.token}',
          'accept': '/',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        String userLanguage = data['language']
            .toLowerCase(); // Language code like 'es', 'fr', 'ar', 'en'

        setState(() {
          _locale = Locale(userLanguage);
          _appLocalization = AppLocalization(_locale!);
        });

        await _appLocalization.load(); // Load localized strings
// Load localized strings
      } else {
        throw Exception('Failed to fetch tourist info');
      }
    } catch (e) {
      print('Error fetching tourist info: $e');
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


  void _fetchCities() async {
    String touristName = decodeToken(widget.token);  // Implement your token decoding logic
    final response = await http.get(
      Uri.parse('http://guideme.runasp.net/api/City/AllCities/$touristName'),
      headers: {
        'Authorization': 'Bearer ${widget.token}',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      setState(() {
        cities = data.map<Map<String, dynamic>>((city) {
          return {
            'id': city['id'],
            'name': city['name'],
            'imagePath': city['cityImage'],
          };
        }).toList();
      });
    } else {
      throw Exception('Failed to fetch cities');
    }
  }

  // // Example implementation of decodeToken function
  // String decodeToken(String token) {
  //   // Your logic to decode the JWT token and extract touristName
  //   // For example:
  //   // final payload = token.split('.')[1];
  //   // final decoded = utf8.decode(base64Url.decode(base64Url.normalize(payload)));
  //   // final touristName = json.decode(decoded)['http://schemas.xmlsoap.org/ws/2005/05/identity/claims/name'];
  //   // return touristName;
  //
  //   // Placeholder return value, replace with actual logic
  //   return "touristName";
  // }
  @override
  Widget build(BuildContext context) {
    if (_appLocalization == null) {
      // Show loading indicator or handle uninitialized state
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: _showAppbarColor
            ? Theme
            .of(context)
            .primaryColor
            : Colors.transparent,
        title: Text(
          _appLocalization.translate('app_title') ?? '',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch<String>(
                context: context,
                delegate: CustomSearchDelegate(
                  context: context,
                  token: widget.token,
                  touristName: decodeToken(widget.token),
                  appLocalization: _appLocalization,
                  searchHint: _appLocalization.translate('search') ?? '',
                  noResultsMessage:
                  _appLocalization.translate('no_results') ?? '',
                  locale: _locale,
                ),
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/background_image.jpg',
              fit: BoxFit.cover,
            ),
          ),
          SingleChildScrollView(
            controller: _scrollController,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: MediaQuery
                    .of(context)
                    .padding
                    .top),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16.0,
                    mainAxisSpacing: 16.0,
                  ),
                  itemCount: cities.length,
                  itemBuilder: (BuildContext context, int index) {
                    return _buildCard(context, cities[index]);
                  },
                ),
              ],
            ),
          ),
        ],
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
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.favorite),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          FavoritePage(authToken: widget.token,locale: _locale,
                            appLocalization: _appLocalization),
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
                      builder: (context) => HistoryPage(token: widget.token,locale: _locale,
                        appLocalization: _appLocalization),
                    ),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.account_circle),
                onPressed: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard(BuildContext context, Map<String, dynamic> city) {
    return GestureDetector(
      onTap: () {
        print('Navigating to CityPage with parameters:');
        print('Title: ${city['name']}');
        print('Token: ${widget.token}');
        print('Locale: $_locale');
        print('AppLocalization: $_appLocalization');

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CityPage(
              title: city['name'],
              token: widget.token,
              locale: _locale,
              appLocalization: _appLocalization,
            ),
          ),
        );

      },
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30.0),
          child: Stack(
            fit: StackFit.expand,
            children: [
              city['imagePath'] != null
                  ? Image.network(
                city['imagePath'],
                fit: BoxFit.cover,
              )
                  : Container(),
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    city['name'] ?? '', // Provide default value if null
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
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
class CustomSearchDelegate extends SearchDelegate<String> {
  final BuildContext context;
  final String token;
  final String touristName;
  final AppLocalization appLocalization;
  final String searchHint;
  final String noResultsMessage;
  final Locale? locale; // Add locale here

  CustomSearchDelegate({
    required this.context,
    required this.token,
    required this.touristName,
    required this.appLocalization,
    required this.searchHint,
    required this.noResultsMessage,
    this.locale, // Include locale in constructor
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
    return Opacity(
      opacity: 0.9,
      child: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () {
          close(context, '');
        },
      ),
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

  Widget _buildSearchResults(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _fetchSearchResults(query, touristName),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(
              child: Text(
                  appLocalization.translate('fetch_search_results_error') ??
                      ''));
        } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
          final results = snapshot.data!;
          return GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: results.length,
            itemBuilder: (context, index) {
              final city = results[index];
              return GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CityPage(
                        title: city['name'],
                        token: token,
                        locale: locale,
                      appLocalization: appLocalization,
                    ),
                  ),
                ),
                child: Card(
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Expanded(
                        child: city['imagePath'] != null
                            ? Image.network(
                                city['imagePath'],
                                fit: BoxFit.cover,
                              )
                            : Container(),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          city['name'] ?? '',
                          style: Theme.of(context).textTheme.subtitle1,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        } else {
          return Center(
            child: Text(
              appLocalization.translate('no_results') ?? '',
              style: Theme.of(context).textTheme.headline6,
            ),
          );
        }
      },
    );
  }

  Future<List<Map<String, dynamic>>> _fetchSearchResults(
      String query, String touristName) async {
    final url = Uri.parse(
        'http://guideme.runasp.net/api/City/SearchCity/$query/$touristName');

    try {
      final response = await http.get(url,
          headers: {'accept': '/', 'Authorization': 'Bearer ${token}'});

      if (response.statusCode == 200) {
        final dynamic data = json.decode(response.body);

        if (data is List) {
          // Case when API returns an array of objects
          return data.map<Map<String, dynamic>>((city) {
            return {
              'id': city['id'],
              'name': city['name'],
              'imagePath': city['cityImage'],
            };
          }).toList();
        } else if (data is Map<String, dynamic>) {
          // Case when API returns a single object
          return [
            {
              'id': data['id'],
              'name': data['name'],
              'imagePath': data['cityImage'],
            }
          ];
        } else {
          throw Exception(
              appLocalization.translate('fetch_search_results_error') ?? '');
        }
      } else {
        throw Exception(
            appLocalization.translate('fetch_search_results_error') ?? '');
      }
    } catch (e) {
      throw Exception(
          appLocalization.translate('fetch_search_results_error') ?? '');
    }
  }
}
