import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:jwt_decode/jwt_decode.dart';
import 'AppLocalization.dart';
import 'bottom_nav_bar.dart';

class HistoryPage extends StatefulWidget {
  final String token;
  final Locale? locale;
  final AppLocalization appLocalization;

  const HistoryPage({Key? key, required this.token, required this.appLocalization, this.locale}) : super(key: key);

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
        Uri.parse('http://guideme.runasp.net/api/TouristHistory/$touristName'),
        headers: {
          'Authorization': 'Bearer ${widget.token}',
          'accept': '/',
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
  Widget build(BuildContext context) {
    // Grouping history by date
    Map<String, List<dynamic>> groupedHistory = {};
    history.forEach((visit) {
      var place = visit['place'];
      var date = visit['date'].substring(0, 10); // Extract only date part

      groupedHistory.putIfAbsent(date, () => []);
      groupedHistory[date]!.add(place);
    });

    // Sorting grouped history by date in descending order
    List<String> sortedDates = groupedHistory.keys.toList();
    sortedDates.sort((a, b) => DateTime.parse(b).compareTo(DateTime.parse(a)));

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 21, 82, 113), // Set app bar background color
        title: Text(widget.appLocalization.translate('History')),
      ),
      backgroundColor: Color.fromARGB(255, 21, 82, 113), // Set scaffold background color
      body: ListView.builder(
        itemCount: sortedDates.length,
        itemBuilder: (context, index) {
          var date = sortedDates[index];
          var places = groupedHistory[date]!;

          // Sort places in descending order by appearance order in API response
          places.sort((a, b) => history.indexWhere((visit) => visit['place'] == b).compareTo(
              history.indexWhere((visit) => visit['place'] == a)));

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
                itemCount: places.length,
                itemBuilder: (context, index) {
                  var place = places[index];
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
      bottomNavigationBar: BottomNavBar(
        token: widget.token,
        appLocalization: widget.appLocalization,
        locale: widget.locale,
      ),
    );
  }
}