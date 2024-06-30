import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';

import 'city_page.dart';
import 'favorite_page.dart';
import 'history_page.dart';
import 'AppLocalization.dart';

class home_page extends StatefulWidget {
  final String token;

  const home_page({Key? key, required this.token}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<home_page> {
  final ScrollController _scrollController = ScrollController();
  bool _showAppbarColor = false;
  List<Map<String, dynamic>> cities = [];
  String languageCode = 'en'; // Default to English

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _fetchCities();
    _fetchLanguage();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  String decodeToken(String token) {
    Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
    return decodedToken['http://schemas.xmlsoap.org/ws/2005/05/identity/claims/name'];
  }

  Future<void> _fetchLanguage() async {
    String touristName = decodeToken(widget.token);
    final response = await http.get(
      Uri.parse('http://guide-me.somee.com/api/Tourist/GetTouristInfo/$touristName'),
      headers: {
        'Authorization': 'Bearer ${widget.token}',
        'accept': '*/*',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        languageCode = _mapLanguageCode(data['language']);
        _setLocale();
      });
    } else {
      throw Exception('Failed to fetch tourist info');
    }
  }

  String _mapLanguageCode(String language) {
    switch (language.toLowerCase()) {
      case 'spanish':
        return 'es';
      case 'french':
        return 'fr';
      case 'italian':
        return 'it';
      case 'arabic':
        return 'ar';
      case 'russian':
        return 'ru';
      default:
        return 'en'; // Default to English
    }
  }

  void _setLocale() {
    AppLocalization appLocalization = AppLocalization(Locale(languageCode));
    appLocalization.load().then((_) {
      setState(() {}); // Trigger a rebuild once localization is loaded
    });
  }

  void _fetchCities() async {
    final response = await http.get(
      Uri.parse('http://guide-me.somee.com/api/City/AllCities'),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: _showAppbarColor
            ? Theme.of(context).primaryColor
            : Colors.transparent,
        title: Text(
          AppLocalization.of(context).translate('app_title') ?? '', // Provide default value if null
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
                delegate: CustomSearchDelegate(context: context, token: widget.token),
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
                SizedBox(height: MediaQuery.of(context).padding.top),
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
                      builder: (context) => favorite_page(authToken: widget.token),
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
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CityPage(title: city['name'], token: widget.token),
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
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          color: Colors.black,
                          blurRadius: 2,
                          offset: Offset(1, 1),
                        ),
                      ],
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

  CustomSearchDelegate({required this.context, required this.token});

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
      future: _fetchSearchResults(query),
      builder: (BuildContext context, AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
          return GridView.builder(
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10.0,
              mainAxisSpacing: 10.0,
            ),
            itemCount: snapshot.data!.length,
            itemBuilder: (BuildContext context, int index) {
              return _buildSearchCard(context, snapshot.data![index]);
            },
          );
        } else {
          return const Center(child: Text('No results found'));
        }
      },
    );
  }

  Widget _buildSearchCard(BuildContext context, Map<String, dynamic> result) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CityPage(title: result['name'], token: token),
          ),
        );
      },
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                result['name'] ?? '', // Provide default value if null
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<List<Map<String, dynamic>>> _fetchSearchResults(String query) async {
    final response = await http.get(
      Uri.parse('http://guide-me.somee.com/api/City/SearchCities/$query'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map<Map<String, dynamic>>((city) {
        return {
          'id': city['id'],
          'name': city['name'],
        };
      }).toList();
    } else {
      throw Exception('Failed to fetch search results');
    }
  }
}
