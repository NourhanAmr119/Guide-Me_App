import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
class favorite_page extends StatefulWidget {
  final List<String> favoritePlaces;

  const favorite_page({Key? key, required this.favoritePlaces})
      : super(key: key);

  @override
  _FavoritePageState createState() => _FavoritePageState();
}

class _FavoritePageState extends State<favorite_page> {
  late List<bool> isFavoriteList; // List to track favorite status of each place

  @override
  void initState() {
    super.initState();
    // Initialize isFavoriteList with false values for each place
    isFavoriteList =
        List.generate(widget.favoritePlaces.length, (index) => true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Favorite Places'),
        backgroundColor:
        const Color.fromARGB(255, 21, 82, 113), // Set app bar color
      ),
      body: Container(
        color: const Color.fromARGB(255, 21, 82, 113), // Set background color
        child: widget.favoritePlaces.isEmpty
            ? Center(
          child: Text('No favorite places yet!'),
        )
            : ListView.builder(
          itemCount: widget.favoritePlaces.length,
          itemBuilder: (context, index) {
            return buildFavoriteCard(context, index);
          },
        ),
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
                  Navigator.popUntil(context, ModalRoute.withName('/'));
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

  Widget buildFavoriteCard(BuildContext context, int index) {
    return Card(
      margin: EdgeInsets.all(8),
      child: ListTile(
        leading: SizedBox(
          width: 80,
          child: Image.asset(
            'assets/Dream_Park.jpg', // Replace with the actual image path
            fit: BoxFit.cover,
          ),
        ),
        title: Text(widget.favoritePlaces[index]),
        trailing: IconButton(
          icon: Icon(
            Icons.favorite,
            color: isFavoriteList[index]
                ? const Color.fromARGB(255, 252, 250, 250)
                : Colors.grey,
          ),
          onPressed: () {
            // Remove the place from favorites when the icon is clicked
            setState(() {
              widget.favoritePlaces.removeAt(index);
              isFavoriteList.removeAt(index);
            });
          },
        ),
        onTap: () {
          // Handle navigating to details page
        },
      ),
    );
  }
}