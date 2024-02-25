import 'package:flutter/material.dart';
import 'package:guide_me/main.dart';

class city_page extends StatelessWidget {
  final String title;

  city_page({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 21, 82, 113),
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
              title,
              style: const TextStyle(
                fontSize: 16,
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
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
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
                SizedBox(height: 20),
                Text(
                  'Top Historical Places in $title',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 20),
                // Historical Places Slider
                SizedBox(
                  height: 220,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      CardWidget(
                        imageUrl: 'assets/egyptian_museum.jpg',
                        placeName: 'Egyptian Museum',
                        locationIcon: Icons.location_on,
                        rating: 4.5,
                        locationName: 'Downtown Cairo',
                      ),
                      CardWidget(
                        imageUrl: 'assets/cairo.jpg',
                        placeName: 'Cairo Tower',
                        locationIcon: Icons.location_on,
                        rating: 3.8,
                        locationName: 'Gezira Island',
                      ),
                      CardWidget(
                        imageUrl: 'assets/citadel_of_saladin.jpg',
                        placeName: 'Citadel of Saladin',
                        locationIcon: Icons.location_on,
                        rating: 4.2,
                        locationName: 'Old Cairo',
                      ),
                      CardWidget(
                        imageUrl: 'assets/khan_al-khalily.jpg',
                        placeName: 'Khan el-Khalili',
                        locationIcon: Icons.location_on,
                        rating: 4.8,
                        locationName: 'Islamic Cairo',
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  'Entertainment Places',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 20),
                // Entertainment Places Slider
                SizedBox(
                  height: 220,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _buildEntertainmentPlaceCard(
                        imageUrl: 'assets/The_Nile_Ritz_Carlton.png',
                        placeName: 'The-Nile-Ritz-Carlton',
                        locationIcon: Icons.location_on,
                        rating: 4.3,
                        locationName: '6th of October City',
                      ),
                      _buildEntertainmentPlaceCard(
                        imageUrl: 'assets/Dream_Park.jpg',
                        placeName: 'Dream Park',
                        locationIcon: Icons.location_on,
                        rating: 4.5,
                        locationName: '6th of October City',
                      ),
                      _buildEntertainmentPlaceCard(
                        imageUrl: 'assets/Pier_88.png',
                        placeName: 'Pier 88 Restaurant',
                        locationIcon: Icons.location_on,
                        rating: 4.2,
                        locationName: 'Zamalek',
                      ),
                      _buildEntertainmentPlaceCard(
                        imageUrl: 'assets/Steigenberger.jpg',
                        placeName: 'Steigenberger Hotel',
                        locationIcon: Icons.location_on,
                        rating: 4.6,
                        locationName: 'New Cairo',
                      ),
                      _buildEntertainmentPlaceCard(
                        imageUrl: 'assets/Azhar_Park.jpg',
                        placeName: 'Al-Azhar Park',
                        locationIcon: Icons.location_on,
                        rating: 4.7,
                        locationName: 'Islamic Cairo',
                      ),
                      _buildEntertainmentPlaceCard(
                        imageUrl: 'assets/Kadoura.png',
                        placeName: 'Kadoura Restaurant',
                        locationIcon: Icons.location_on,
                        rating: 4.7,
                        locationName: 'Islamic Cairo',
                      ),
                    ],
                  ),
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

  Widget _buildEntertainmentPlaceCard({
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

  const CardWidget({
    Key? key,
    required this.imageUrl,
    required this.placeName,
    required this.locationIcon,
    required this.rating,
    required this.locationName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      margin: EdgeInsets.symmetric(horizontal: 10),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              imageUrl,
              width: 150,
              height: 130,
              fit: BoxFit.cover,
            ),
            SizedBox(height: 8),
            Text(
              placeName,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
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
                Text(
                  locationName,
                  style: TextStyle(fontSize: 14, color: Colors.blue),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
