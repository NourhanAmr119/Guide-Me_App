import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
import 'AppLocalization.dart';
import 'city_page.dart';
import 'bottom_nav_bar.dart';

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
            .toLowerCase();

        setState(() {
          _locale = Locale(userLanguage);
          _appLocalization = AppLocalization(_locale!);
        });

        await _appLocalization.load();

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

  @override
  Widget build(BuildContext context) {
    if (_appLocalization == null) {

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
      bottomNavigationBar: BottomNavBar(
        token: widget.token,
        appLocalization: _appLocalization,
        locale: _locale,
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
                    city['name'] ?? '',
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
  final Locale? locale;

  CustomSearchDelegate({
    required this.context,
    required this.token,
    required this.touristName,
    required this.appLocalization,
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

  @override
  String get searchFieldLabel => appLocalization.translate('search') ?? '';

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
                  margin: EdgeInsets.all(8.0),
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

          return data.map<Map<String, dynamic>>((city) {
            return {
              'id': city['id'],
              'name': city['name'],
              'imagePath': city['cityImage'],
            };
          }).toList();
        } else if (data is Map<String, dynamic>) {

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