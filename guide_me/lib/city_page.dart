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
                    'Welcome to $title',
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
                  'Top Places In $title',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 20),
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
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          icon,
          size: size,
          color: color,
        ),
      ],
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
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold,color: Colors.black),
            ),
            SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                5,
                (index) {
                  if (index < rating) {
                    return Icon(
                      Icons.star,
                      color: Colors.yellow,
                      size: 15,
                    );
                  } else {
                    return Icon(
                      Icons.star,
                      color: Colors.grey,
                      size: 15,
                    );
                  }
                },
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