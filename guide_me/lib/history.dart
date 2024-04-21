import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class history extends StatefulWidget {
  final String token;

  history({required this.token});

  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<history> {
  List<dynamic> historyData = [];

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      final response = await http.get(
        Uri.parse('http://guide-me.somee.com/api/TouristHistory/${Uri.encodeComponent(widget.token)}'),
        headers: {'Authorization': 'Bearer ${widget.token}'},
      );

      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        setState(() {
          historyData = json.decode(response.body);
        });
      } else {
        throw Exception('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching data: $e');
      throw Exception('Failed to load data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('History Page'),
      ),
      body: ListView.builder(
        itemCount: historyData.length,
        itemBuilder: (context, index) {
          var data = historyData[index];
          return Card(
            child: Column(
              children: [
                ListTile(
                  title: Text('Date: ${data['date']}'),
                ),
                Image.network(data['place']['media'][0]['mediaContent']),
                ListTile(
                  title: Text('Place: ${data['place']['name']}'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}