// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:guide_me/city_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Remove debug banner
      title: 'Guide Me',
      theme: ThemeData(
        primaryColor: const Color.fromARGB(255, 21, 82, 113), // Custom primary color
        colorScheme: const ColorScheme.dark().copyWith(
          primary: const Color(0xFF372949), // Custom primary color for dark mode
          onPrimary: Colors.white, // Text color on primary color
        ),
      ),
      home: const MyHomePage(title: 'Guide Me'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final ScrollController _scrollController = ScrollController();
  bool _showAppbarColor = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
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
              // Show search field
              showSearch<String>(
                context: context,
                delegate: CustomSearchDelegate(),
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
                  itemCount: titles.length,
                  itemBuilder: (BuildContext context, int index) {
                    return _buildCard(titles[index], imagePaths[index]);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        elevation: 0, // Remove elevation from bottom app bar
        color: const Color.fromARGB(255, 21, 82, 113), // Set color to transparent
        child: Container(
          height: 60, // Reduce the height of the footer
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
                onPressed: () {},
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

Widget _buildCard(String title, String imagePath) {
  return GestureDetector(
    onTap: () {
      // Navigate to another page here
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => city_page(title:title)),
      );
    },
    child: Stack(
      children: [
        Card(
          elevation: 3, // Add elevation to the cards
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.0),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(30.0),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(
                  imagePath,
                  fit: BoxFit.cover,
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 22, // Increase font size
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
  @override
  ThemeData appBarTheme(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return theme.copyWith(
      scaffoldBackgroundColor: const Color.fromARGB(255, 21, 82, 113), // Set background color to blue
      appBarTheme: const AppBarTheme(
        backgroundColor: Color.fromARGB(140, 21, 82, 113), // Set app bar background color to blue
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
      opacity: 0.9, // Set the opacity value (0.0 to 1.0)
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
    // Implement your search results view here
    return Container();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    // Implement your search suggestions view here
    return Container();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 21, 82, 113), // Set app bar background color
        title: const Text('Search'),
        actions: buildActions(context),
        leading: buildLeading(context),
      ),
      body: const Column(
        children: [
          // Your search page content goes here
        ],
      ),
    );
  }
}

final List<String> titles = [
  'Cairo',
  'Giza',
  'Alexandria',
  'Hurghada',
  'Luxor',
  'Aswan',
  'Sinai',
  'Sharm El-Sheikh',
  'Marsa Matrouh',
  'Marsa Alam',
];

final List<String> imagePaths = [
  'assets/cairo.jpg',
  'assets/giza.jpg',
  'assets/alexandria.jpg',
  'assets/hurghada.jpg',
  'assets/luxor.jpg',
  'assets/aswan.jpg',
  'assets/sinai.jpg',
  'assets/sharm_el_sheikh.jpg',
  'assets/marsa_matrouh.jpg',
  'assets/marsa_alam.jpg',
];     