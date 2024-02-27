import 'package:flutter/material.dart';
import 'package:guide_me/main.dart';

class city_page extends StatefulWidget {
  final String title;

  const city_page({Key? key, required this.title}) : super(key: key);

  @override
  _CityPageState createState() => _CityPageState();
}

class _CityPageState extends State<city_page> {
  ScrollController _scrollController = ScrollController();
  bool _showAppbarColor = false;
  List<String> favoritePlaces = []; // List to store favorite places

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

  // Function to toggle favorite status of a place
  void toggleFavorite(String placeName) {
    setState(() {
      if (favoritePlaces.contains(placeName)) {
        favoritePlaces.remove(placeName);
      } else {
        favoritePlaces.add(placeName);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: _showAppbarColor
            ? Theme.of(context).primaryColor
            : Colors.transparent,
        elevation: 0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconText(
              icon: Icons.location_on,
              color: Colors.blue,
            ),
            const SizedBox(width: 8),
            Text(
              widget.title,
              style: TextStyle(
                fontSize: 20,
                color: Colors.blue,
              ),
            ),
          ],
        ),
        leading: IconButton(
          icon: IconText(
            icon: Icons.qr_code,
            color: Colors.white,
          ),
          onPressed: () {},
        ),
        actions: [
          IconButton(
            icon: IconText(
              icon: Icons.lightbulb,
              color: Colors.white,
            ),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(
              Icons.favorite,
              color: Colors.white,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => favorite_page(favoritePlaces: favoritePlaces),
                ),
              );
            },
          ),
        ],
      ),
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverList(
            delegate: SliverChildListDelegate(
              [
                Stack(
                  fit: StackFit.loose,
                  children: [
                    Positioned.fill(
                      child: Image.asset(
                        'assets/background_image.jpg',
                        fit: BoxFit.cover,
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: MediaQuery.of(context).padding.top + kToolbarHeight),
                          SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: 20),
                                Row(
                                  children: [
                                    SizedBox(width: 8),
                                    Text(
                                      'Hi, There',
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: Colors.black,
                                      ),
                                    ),
                                    IconText(
                                      icon: Icons.waving_hand,
                                      color: Colors.yellow,
                                      size: 18,
                                    ),
                                  ],
                                ),
                                SizedBox(height: 1),
                                Container(
                                  margin: EdgeInsets.symmetric(vertical: 8),
                                  child: Text(
                                    'Welcome to ${widget.title}',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                                SizedBox(height: 10),
                                Container(
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  padding: EdgeInsets.symmetric(horizontal: 10),
                                  child: Row(
                                    children: [
                                      Icon(Icons.search, color: Colors.grey),
                                      SizedBox(width: 10),
                                      Expanded(
                                        child: TextField(
                                          decoration: InputDecoration(
                                            border: InputBorder.none,
                                            hintText: 'Search',
                                            hintStyle: TextStyle(color: Colors.grey),
                                          ),
                                          style: TextStyle(color: Colors.black),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 10),
                                Text(
                                  'Top Historical Places in ${widget.title}',
                                  style: TextStyle(
                                    fontSize: MediaQuery.of(context).size.width * 0.06, // Responsive font size
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                                SizedBox(height: 20),
                                // Historical Places Slider
                                SizedBox(
                                  height: MediaQuery.of(context).size.width * 0.8, // Responsive height
                                  child: SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                      children: [
                                        buildCard(
                                          imageUrl: 'assets/egyptian_museum.jpg',
                                          placeName: 'Egyptian Museum',
                                          locationIcon: Icons.location_on,
                                          rating: 4.5,
                                          locationName: 'Downtown Cairo',
                                        ),
                                        buildCard(
                                          imageUrl: 'assets/cairo_tower.jpg',
                                          placeName: 'Cairo Tower',
                                          locationIcon: Icons.location_on,
                                          rating: 3.8,
                                          locationName: 'Gezira Island',
                                        ),
                                        buildCard(
                                          imageUrl: 'assets/citadel_of_saladin.jpg',
                                          placeName: 'Citadel of Saladin',
                                          locationIcon: Icons.location_on,
                                          rating: 4.2,
                                          locationName: 'Old Cairo',
                                        ),
                                        buildCard(
                                          imageUrl: 'assets/khan_al-khalily.jpg',
                                          placeName: 'Khan el-Khalili',
                                          locationIcon: Icons.location_on,
                                          rating: 4.8,
                                          locationName: 'Islamic Cairo',
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(height: 20),
                                Text(
                                  'Entertainment Places',
                                  style: TextStyle(
                                    fontSize: MediaQuery.of(context).size.width * 0.06, // Responsive font size
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                                SizedBox(height: 20),
                                // Entertainment Places Slider
                                SizedBox(
                                  height: MediaQuery.of(context).size.width * 0.8, // Responsive height
                                  child: SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                      children: [
                                        buildCard(
                                          imageUrl: 'assets/The_Nile_Ritz_Carlton.png',
                                          placeName: 'The-Nile-Ritz-Carlton',
                                          locationIcon: Icons.location_on,
                                          rating: 4.3,
                                          locationName: '6th of October City',
                                        ),
                                        buildCard(
                                          imageUrl: 'assets/Dream_Park.jpg',
                                          placeName: 'Dream Park',
                                          locationIcon: Icons.location_on,
                                          rating: 4.5,
                                          locationName: '6th of October City',
                                        ),
                                        buildCard(
                                          imageUrl: 'assets/Pier_88.png',
                                          placeName: 'Pier 88 Restaurant',
                                          locationIcon: Icons.location_on,
                                          rating: 4.2,
                                          locationName: 'Zamalek',
                                        ),
                                        buildCard(
                                          imageUrl: 'assets/Steigenberger.jpg',
                                          placeName: 'Steigenberger Hotel',
                                          locationIcon: Icons.location_on,
                                          rating: 4.6,
                                          locationName: 'New Cairo',
                                        ),
                                        buildCard(
                                          imageUrl: 'assets/Azhar_Park.jpg',
                                          placeName: 'Al-Azhar Park',
                                          locationIcon: Icons.location_on,
                                          rating: 4.7,
                                          locationName: 'Islamic Cairo',
                                        ),
                                        buildCard(
                                          imageUrl: 'assets/Kadoura.png',
                                          placeName: 'Kadoura Restaurant',
                                          locationIcon: Icons.location_on,
                                          rating: 4.7,
                                          locationName: 'Islamic Cairo',
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
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
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MyApp(),
                    ),
                  );
                },
              ),
              IconButton(
                icon: Icon(
                  Icons.favorite,
                  color: favoritePlaces.isNotEmpty ? Colors.red : Colors.white,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => favorite_page(favoritePlaces: favoritePlaces),
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

  Widget IconText({
    required IconData icon,
    double size = 24,
    required Color color,
  }) {
    return Icon(
      icon,
      size: size,
      color: color,
    );
  }

  Widget buildCard({
    required String imageUrl,
    required String placeName,
    required IconData locationIcon,
    required double rating,
    required String locationName,
  }) {
    return Container(
      width: 180, // Adjust the width as needed
      child: CardWidget(
        imageUrl: imageUrl,
        placeName: placeName,
        locationIcon: locationIcon,
        rating: rating,
        locationName: locationName,
        isFavorite: favoritePlaces.contains(placeName),
        onFavoriteToggle: () {
          toggleFavorite(placeName);
        },
      ),
    );
  }
}

class CardWidget extends StatelessWidget {
  final String imageUrl;
  final String placeName;
  final IconData locationIcon;
  final double rating;
  final String locationName;
  final bool isFavorite;
  final VoidCallback? onFavoriteToggle;

  const CardWidget({
    Key? key,
    required this.imageUrl,
    required this.placeName,
    required this.locationIcon,
    required this.rating,
    required this.locationName,
    required this.isFavorite,
    this.onFavoriteToggle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      margin: EdgeInsets.symmetric(vertical: 25, horizontal: 10),
      color: Colors.white,
      child: Stack(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: 130,
                width: double.infinity,
                child: Image.asset(
                  imageUrl,
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(height: 8),
              Flexible(
                child: Text(
                  placeName,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  5,
                  (index) => Icon(
                    index < rating ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                    size: 15,
                  ),
                ),
              ),
              SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(locationIcon, size: 16, color: Colors.blue),
                  SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      locationName,
                      style: TextStyle(fontSize: 14, color: Colors.blue),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Positioned(
            top: 8,
            right: 8,
            child: IconButton(
              icon: Icon(
                isFavorite ? Icons.favorite : Icons.favorite_border,
                color: isFavorite ? Colors.red : Colors.grey,
              ),
              onPressed: onFavoriteToggle,
            ),
          ),
        ],
      ),
    );
  }
}

class favorite_page extends StatelessWidget {
  final List<String> favoritePlaces;

  const favorite_page({Key? key, required this.favoritePlaces}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Favorite Places'),
      ),
      body: ListView.builder(
        itemCount: favoritePlaces.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(favoritePlaces[index]),
          );
        },
      ),
    );
  }
}