import 'package:flutter/material.dart';

class city_page extends StatelessWidget {
  final String title;
  final String imagePath;

  city_page({Key? key, required this.title, required this.imagePath}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent, // Make app bar transparent
        elevation: 0, // Remove app bar shadow
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconText(
              icon: Icons.location_on,
              color: Colors.blue, // Change color to blue
            ),
            const SizedBox(width: 8),
            Text(
              'Welcome to $title', // Dynamically generate title based on provided title
              style: const TextStyle(fontSize: 16, color: Colors.blue), // Change font size and color
            ),
          ],
        ),
        leading: IconButton(
          icon: IconText(
            icon: Icons.qr_code,
            color: Colors.white, // Change color to white
          ),
          onPressed: () {
            // Add your scan functionality here
          },
        ),
        actions: [
          IconButton(
            icon: IconText(
              icon: Icons.lightbulb,
              color: Colors.white, // Change color to white
            ),
            onPressed: () {
              // Add your idea functionality here
            },
          ),
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/background_image.jpg', // Set your background image path here
            fit: BoxFit.cover,
          ),
          Container(
            color: Colors.transparent, // Make container transparent
            child: Align(
              alignment: Alignment.topLeft, // Align content to the top left
              child: Container(
                margin: EdgeInsets.symmetric(vertical: 20, horizontal: 20), // Add margin
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start, // Align content to the start
                  children: [
                    const SizedBox(width: 8), // Add space between icon and text
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start, // Align text to the left
                      children: [
                        Container(
                          margin: EdgeInsets.symmetric(vertical: 4), // Add vertical margin
                          child: Row( // Add a Row to display icon and text horizontally
                            children: [
                              Text(
                                'Hi,There ', // First part of the sentence
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                               IconText( // Display waving hand icon
                                icon: Icons.waving_hand,
                                size: 20,
                                color: Colors.yellow,
                              ),
                            ],
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.symmetric(vertical: 4,horizontal:1), // Add vertical margin
                          child: Text(
                            'Welcome to $title', // Dynamically generate title based on provided title
                            style: TextStyle(fontSize:18, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 20), // Add space between content
                Image.asset(
                  imagePath,
                  width: 200,
                  height: 200,
                  fit: BoxFit.cover,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    // Navigate back to the previous page
                    Navigator.pop(context);
                  },
                  child: const Text('Go Back'),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        elevation: 0,
        color: Colors.transparent, // Make bottom app bar transparent
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
}

class IconText extends StatelessWidget {
  final IconData icon;
  final double size;
  final Color color;

  IconText({
    Key? key,
    required this.icon,
    this.size = 24,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center, // Align icon and text vertically
      children: [
        Icon(
          icon,
          size: size,
          color: color, // Set icon color
        ),
      ],
    );
  }
}
