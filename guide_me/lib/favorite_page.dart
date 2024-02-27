import 'package:flutter/material.dart';

class favorite_page extends StatefulWidget {
  final List<String> favoritePlaces;

  const favorite_page({Key? key, required this.favoritePlaces}) : super(key: key);

  @override
  _FavoritePageState createState() => _FavoritePageState();
}

class _FavoritePageState extends State<favorite_page> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Favorite Places'),
      ),
      body: widget.favoritePlaces.isEmpty
          ? Center(
              child: Text('No favorite places yet!'),
            )
          : ListView.builder(
              itemCount: widget.favoritePlaces.length,
              itemBuilder: (context, index) {
                return buildFavoriteCard(context, widget.favoritePlaces[index]);
              },
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

  Widget buildFavoriteCard(BuildContext context, String placeName) {
    return Card(
      margin: EdgeInsets.all(8),
      child: ListTile(
        title: Text(placeName),
        trailing: IconButton(
          icon: Icon(Icons.favorite, color: Colors.white),
          onPressed: () {
            // Handle removing from favorites
          },
        ),
        onTap: () {
          // Handle navigating to details page
        },
      ),
    );
  }
}