import 'dart:convert';
import 'package:flutter/material.dart';
import 'city_page.dart';
import 'favorite_page.dart'; // Import the FavoritePage widget
import 'package:http/http.dart' as http;

class home_page extends StatefulWidget {
  const home_page({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _home_pageState createState() => _home_pageState();
}

class _home_pageState extends State<home_page> {
  final ScrollController _scrollController = ScrollController();
  bool _showAppbarColor = false;
  List<Map<String, dynamic>> cities = [];
  List<String> favoritePlaces = []; // Create a list of favorite places

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _fetchCities(); // Fetch cities when the widget initializes
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _fetchCities() async {
    final response = await http.get(Uri.parse('http://guide-me.somee.com/api/City/AllCities'));
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
          widget.title,
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
                delegate: CustomSearchDelegate(context: context), // Pass context here
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
                    return _buildCard(context, cities[index]['name'], cities[index]['imagePath']);
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
                      builder: (context) => favorite_page(favoritePlaces: favoritePlaces), // Pass the list of favorite places
                    ),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.history),
                onPressed: () {},
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

  Widget _buildCard(BuildContext context, String title, String? imagePath) {
    return GestureDetector(
      onTap: () {
        // Navigate to city page here
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => city_page(title: title),
          ),
        );
      },
      child: Stack(
        children: [
          Card(
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30.0),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(30.0),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  imagePath != null
                      ? Image.network(
                    imagePath,
                    fit: BoxFit.cover,
                  )
                      : Container(), // Use a placeholder or empty container if imagePath is null
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        title,
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
        ],
      ),
    );
  }
}

class CustomSearchDelegate extends SearchDelegate<String> {
  final BuildContext context; // Add context variable

  CustomSearchDelegate({required this.context}); // Constructor

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
  // Adjustments within CustomSearchDelegate

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults(context); // Adjusted to use a new method for building results
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSearchResults(context); // Adjusted to use a new method for building suggestions
  }

  Widget _buildSearchResults(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _fetchSearchResults(query),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
          final results = snapshot.data!;
          return GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, // Number of columns
              childAspectRatio: 0.8, // Aspect ratio of each grid card
              crossAxisSpacing: 10, // Horizontal spacing between cards
              mainAxisSpacing: 10, // Vertical spacing between cards
            ),
            itemCount: results.length,
            itemBuilder: (context, index) {
              final city = results[index];
              return GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => city_page(title: city['name']), // Make sure CityPage exists
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
                            : const Placeholder(), // Placeholder in case of null image
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          city['name'],
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 16, // Adjust font size as desired
                            fontWeight: FontWeight.bold, // Make the title bold
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        } else {
          return const Center(child: Text('No results found.'));
        }
      },
    );
  }

  Future<List<Map<String, dynamic>>> _fetchSearchResults(String query) async {
    final response = await http.get(Uri.parse('http://guide-me.somee.com/api/City/SearchCity/$query'));
    if (response.statusCode == 200) {
      // Decode the response body
      final responseBody = json.decode(response.body);

      // Check if the decoded response body is a list
      if (responseBody is List) {
        // If it is a list, map each item to a Map<String, dynamic> and return
        return responseBody.map<Map<String, dynamic>>((city) => {
          'id': city['id'],
          'name': city['name'],
          'imagePath': city['cityImage'],
        }).toList();
      } else if (responseBody is Map) {
        // If the response body is a map, treat it as a single city object
        // Wrap the single city object into a list and return
        return [
          {
            'id': responseBody['id'],
            'name': responseBody['name'],
            'imagePath': responseBody['cityImage'],
          }
        ];
      } else {
        // If the response body is neither a List nor a Map, throw an exception
        throw Exception('Unexpected response format: ${response.body}');
      }
    } else {
      // If the status code is not 200, throw an exception
      throw Exception('Failed to fetch search results: ${response.statusCode}');
    }
  }
}