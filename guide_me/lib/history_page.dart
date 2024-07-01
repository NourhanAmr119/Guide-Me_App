import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'favorite_page.dart';
import 'home_page.dart';
import 'package:jwt_decode/jwt_decode.dart'; 

class HistoryPage extends StatefulWidget {
  final String token;

  const HistoryPage({Key? key, required this.token}) : super(key: key);

  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  List<dynamic> history = [];
  late String touristName;

  @override
  void initState() {
    super.initState();
    touristName = decodeToken(widget.token);
    fetchHistory();
  }

  String decodeToken(String token) {
    // Decode the token to extract the user name
    Map<String, dynamic> decodedToken = Jwt.parseJwt(token);
    return decodedToken['http://schemas.xmlsoap.org/ws/2005/05/identity/claims/name'] ?? '';
  }

  Future<void> fetchHistory() async {
    try {
      var response = await http.get(
        Uri.parse('http://guide-me.somee.com/api/TouristHistory/$touristName'),
        headers: {
          'Authorization': 'Bearer ${widget.token}',
          'accept': '*/*',
        },
      );
      if (response.statusCode == 200) {
        setState(() {
          history = jsonDecode(response.body);
        });
      } else {
        print('Failed to fetch history: ${response.statusCode}');
      }
    } catch (e) {
      print('Exception caught while fetching history: $e');
    }
  }


  @override
  @override
  Widget build(BuildContext context) {
    // Grouping history by date
    Map<String, List<dynamic>> groupedHistory = {};
    history.forEach((visit) {
      var date = _formatDate(DateTime.parse(visit['date']));
      groupedHistory.putIfAbsent(date, () => []);
      groupedHistory[date]!.add(visit);
    });

    // Sorting grouped history by date
    List<String> sortedDates = groupedHistory.keys.toList();
    sortedDates.sort((a, b) => DateTime.parse(a).compareTo(DateTime.parse(b)));

    return Scaffold(
      appBar: AppBar(
        backgroundColor:
            Color.fromARGB(255, 21, 82, 113), // Set app bar background color
        title: Text('History'),
      ),
      backgroundColor:
          Color.fromARGB(255, 21, 82, 113), // Set scaffold background color
      body: ListView.builder(
        itemCount: sortedDates.length,
        itemBuilder: (context, index) {
          var date = sortedDates[index];
          var visits = groupedHistory[date]!;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  date,
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: 10),
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: visits.length,
                itemBuilder: (context, index) {
                  var visit = visits[index];
                  var place = visit['place'];
                  return GestureDetector(
                    onTap: () {
                      // Navigate to the place page if needed
                    },
                    child: Card(
                      elevation: 5,
                      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      child: Column(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(15.0),
                              topRight: Radius.circular(15.0),
                            ),
                            child: Image.network(
                              place['media'][0]['mediaContent'],
                              width: double.infinity,
                              height: 200,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(10),
                            child: Text(
                              place['name'],
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          );
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
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                        builder: (context) => HomePage(token: widget.token)),
                    (Route<dynamic> route) => false,
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.favorite),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          FavoritePage(authToken: widget.token),
                    ),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.history),
                onPressed: () {
                  // Do nothing as we are already on the history page
                },
              ),
              IconButton(
                icon: const Icon(Icons.account_circle),
                onPressed: () {
                  // Navigate to account page
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
