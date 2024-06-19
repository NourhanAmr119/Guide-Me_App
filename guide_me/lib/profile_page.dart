import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decode/jwt_decode.dart';
import 'edit_profile_page.dart';
import 'favorite_page.dart';
import 'history_page.dart';

class ProfilePage extends StatefulWidget {
  final String token;

  ProfilePage({required this.token});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late Future<Map<String, dynamic>> _touristInfo;

  @override
  void initState() {
    super.initState();
    _touristInfo = _fetchTouristInfo(widget.token);
  }

  Future<Map<String, dynamic>> _fetchTouristInfo(String token) async {
    try {
      String touristName = decodeToken(token);
      final response = await http.get(
        Uri.parse('http://guide-me.somee.com/api/Tourist/GetTouristInfo/$touristName'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load tourist information: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching tourist information: $error');
      throw Exception('Failed to load tourist information');
    }
  }

  String decodeToken(String token) {
    Map<String, dynamic> decodedToken = Jwt.parseJwt(token);
    print('Decoded token: $decodedToken');
    return decodedToken['http://schemas.xmlsoap.org/ws/2005/05/identity/claims/name'] ?? '';
  }

  void _logout() {
    // Navigate to the start screen
    Navigator.pushReplacementNamed(context, '/start');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Profile Page',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Color.fromARGB(255, 246, 243, 177),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black, size: 30),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.edit, color: Colors.black, size: 30),
            onPressed: () {
              void _navigateToEditProfile(Map<String, dynamic> userInfo) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditProfilePage(token: widget.token, initialData: userInfo),
                  ),
                );
              }
              _touristInfo.then((userInfo) {
                _navigateToEditProfile(userInfo);
              }).catchError((error) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error fetching user info')));
              });
            },
          ),
        ],
        centerTitle: true,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _touristInfo,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final touristInfo = snapshot.data!;
            final photoUrl = touristInfo['photoUrl'];
            return SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 20),
                  Center(
                    child: CircleAvatar(
                      radius: 65,
                      backgroundColor: Color.fromARGB(255, 246, 243, 177),
                      backgroundImage: photoUrl != null ? NetworkImage(photoUrl) : null,
                      child: photoUrl == null ? Icon(Icons.person, size: 130, color: Colors.black) : null,
                    ),
                  ),
                  SizedBox(height: 30),
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Icon(Icons.person, color: Colors.black, size: 60),
                            SizedBox(width: 40),
                            Text(
                              '${touristInfo['userName']}',
                              style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold, color: Colors.black),
                            ),
                          ],
                        ),
                        SizedBox(height: 30),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Icon(Icons.email, color: Colors.black, size: 50),
                            SizedBox(width: 40),
                            Text(
                              '${touristInfo['email']}',
                              style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold, color: Colors.black),
                            ),
                          ],
                        ),
                        SizedBox(height: 30),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Icon(Icons.language, color: Colors.black, size: 50),
                            SizedBox(width: 40),
                            Text(
                              '${touristInfo['language']}',
                              style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold, color: Colors.black),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 60),
                  Center(
                    child: ElevatedButton(
                      onPressed: _logout,
                      child: Text(
                        'Logout',
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(horizontal: 50, vertical: 10),
                        backgroundColor: Color.fromARGB(255, 85, 147, 191),
                      ),
                    ),
                  ),
                  SizedBox(height: 40),
                ],
              ),
            );
          }
        },
      ),
      backgroundColor: Color.fromARGB(255, 246, 243, 177),
      bottomNavigationBar: BottomAppBar(
        elevation: 0,
        color: Colors.transparent,
        child: Container(
          height: 60,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: Icon(Icons.home, size: 30, color: Colors.black),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              IconButton(
                icon: Icon(Icons.favorite, size: 30, color: Colors.black),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => favorite_page(
                        authToken: widget.token,
                      ),
                    ),
                  );
                },
              ),
              IconButton(
                icon: Icon(Icons.history, size: 30, color: Colors.black),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => history_page(token: widget.token),
                    ),
                  );
                },
              ),
              IconButton(
                icon: Icon(Icons.account_circle, size: 30, color: Colors.black),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProfilePage(token: widget.token),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}