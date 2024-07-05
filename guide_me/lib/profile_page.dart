import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decode/jwt_decode.dart';
import 'edit_profile_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'AppLocalization.dart';
import 'bottom_nav_bar.dart';

class ProfilePage extends StatefulWidget {
  final String token;
  final Locale? locale;
  final AppLocalization appLocalization;


  ProfilePage({
    required this.token,
    required this.appLocalization,
    this.locale,
  });

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Future<Map<String, dynamic>?>? _touristInfo; // Nullable Future

  late SharedPreferences _prefs;

  @override
  void initState() {
    super.initState();
    _initializeSharedPreferences().then((_) {
      _loadTouristInfo();
    });
  }

  Future<void> _initializeSharedPreferences() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<void> _loadTouristInfo() async {
    String? storedProfile = _prefs.getString('profileData');
    if (storedProfile != null) {
      setState(() {
        _touristInfo = Future.value(jsonDecode(storedProfile));
      });
    }
    _fetchTouristInfoFromApi();
  }

  Future<void> _fetchTouristInfoFromApi() async {
    try {
      String touristName = decodeToken(widget.token);
      final response = await http.get(
        Uri.parse('http://guideme.runasp.net/api/Tourist/GetTouristInfo/$touristName'),
        headers: {'Authorization': 'Bearer ${widget.token}'},
      );
      if (response.statusCode == 200) {
        final touristInfo = json.decode(response.body);
        _prefs.setString('profileData', jsonEncode(touristInfo));
        setState(() {
          _touristInfo = Future.value(touristInfo);
        });
      } else {
        throw Exception('Failed to load tourist information: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching tourist information: $error');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error fetching user info')));
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
            widget.appLocalization.translate('profile'),
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
              void _navigateToEditProfile(Map<String, dynamic>? userInfo) {
                if (userInfo != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditProfilePage(token: widget.token, initialData: userInfo,appLocalization: widget.appLocalization, locale: widget.locale),
                    ),
                  ).then((_) {
                    _fetchTouristInfoFromApi();
                  });
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('User info not available yet')));
                }
              }

              if (_touristInfo != null) {
                _touristInfo!.then((userInfo) {
                  _navigateToEditProfile(userInfo);
                }).catchError((error) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error fetching user info')));
                });
              } else {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('User info not available yet')));
              }
            },
          ),
        ],
        centerTitle: true,
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: _touristInfo,
        builder: (context, AsyncSnapshot<Map<String, dynamic>?> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData && snapshot.data != null) {
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
                        widget.appLocalization.translate('logout'),
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
          } else {
            // Handle case where _touristInfo is null or snapshot.data is null
            return Center(child: Text('User info not available yet'));
          }
        },
      ),
      backgroundColor: Color.fromARGB(255, 246, 243, 177),
      bottomNavigationBar: BottomNavBar(
        token: widget.token,
        appLocalization: widget.appLocalization,
        locale: widget.locale,
        isProfilePage: true,
      ),
    );
  }
}
