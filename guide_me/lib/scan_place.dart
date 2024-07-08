import 'dart:io';
import 'package:flutter/material.dart';
import 'package:jwt_decode/jwt_decode.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'AppLocalization.dart';
import 'place_page.dart';

class ScanPage extends StatefulWidget {
  final String cityName;
  final String token;
  final Locale? locale;
  final AppLocalization appLocalization;

  ScanPage({required this.cityName, required this.token, required this.appLocalization, this.locale});

  @override
  _ScanPageState createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  File? _image;
  bool _isLoading = false;
  String? _placeName;
  String? _placeImageUrl;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _scanPlace() async {
    if (_image == null) return;

    setState(() {
      _isLoading = true;
    });

    _showLoadingDialog();

    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('http://guideme.runasp.net/api/Scan/scan-place'),
      );
      request.headers['Authorization'] = 'Bearer ${widget.token}';
      request.files.add(await http.MultipartFile.fromPath('Image', _image!.path));
      request.fields['Name'] = widget.cityName;

      final response = await request.send();

      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        final data = json.decode(responseBody);

        if (data == null || data['similarPlaceData'] == null || data['similarPlaceData'].isEmpty) {
          Navigator.pop(context); // Close the loading dialog
          _showAlertDialog(widget.appLocalization.translate('Not Found'), widget.appLocalization.translate('No similar places found.'));
        } else {
          setState(() {
            _placeName = data['similarPlaceData'][0]['placeName'];
            _placeImageUrl = data['similarPlaceData'][0]['image'];
          });
          Navigator.pop(context); // Close the loading dialog
        }
      } else {
        Navigator.pop(context); // Close the loading dialog
        _showAlertDialog(widget.appLocalization.translate('Error'), widget.appLocalization.translate('Failed to scan the place.'));
      }
    } catch (e) {
      Navigator.pop(context); // Close the loading dialog
      _showAlertDialog(widget.appLocalization.translate('Exception'), widget.appLocalization.translate('An error occurred: $e'));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 20),
              Text(widget.appLocalization.translate('Please wait...')),
            ],
          ),
        );
      },
    );
  }

  void _showAlertDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(widget.appLocalization.translate('OK')),
              style: TextButton.styleFrom(
                foregroundColor: Colors.white, // Set the text color to white
              ),
            ),
          ],
        );
      },
    );
  }

  String decodeToken(String token) {
    Map<String, dynamic> decodedToken = Jwt.parseJwt(token);
    print('Decoded token: $decodedToken');
    return decodedToken['http://schemas.xmlsoap.org/ws/2005/05/identity/claims/name'] ?? '';
  }

  void _onTapCard(Map<String, dynamic> place, String token) async {
    try {
      final String touristName = decodeToken(token);
      final response = await http.post(
        Uri.parse('http://guideme.runasp.net/api/TouristHistory?placename=${place['name']}&touristname=$touristName'),
        headers: {
          'Authorization': 'Bearer $token',
          'accept': '/',
        },
      );

      if (response.statusCode == 200) {
        print('Place added to history successfully');
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PlacePage(
              touristName: decodeToken(widget.token),
              cityName: widget.cityName,
              place: place,
              token: widget.token,
              appLocalization: widget.appLocalization, // Pass the localization instance
              locale: widget.locale, // Pass the locale
            ),
          ),
        );
      } else {
        print('Failed to add place to history: ${response.statusCode}');
      }
    } catch (e) {
      print('Exception caught: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Scan Place'),
        titleTextStyle: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
        backgroundColor: Color.fromARGB(255, 246, 243, 177),
        iconTheme: IconThemeData(color: Colors.black),
      ),
      backgroundColor: Color.fromARGB(255, 246, 243, 177),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (_image == null)
              Image.asset(
                'assets/default_image.png', // Path to the uploaded image
                height: 200,
              )
            else
              Image.file(
                _image!,
                height: 200,
              ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _pickImage(ImageSource.gallery),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[600], // Background color
                  ),
                  icon: Icon(Icons.photo_library, color: Colors.white), // Icon color
                  label: Text(widget.appLocalization.translate(
                    'Open Gallery'),
                    style: TextStyle(color: Colors.white), // Text color
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => _pickImage(ImageSource.camera),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[600], // Background color
                  ),
                  icon: Icon(Icons.camera_alt, color: Colors.white), // Icon color
                  label: Text(widget.appLocalization.translate(
                    'Open Camera'),
                    style: TextStyle(color: Colors.white), // Text color
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _scanPlace,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black, // Background color
              ),
              child: Text(widget.appLocalization.translate(
                'Scan Place'),
                style: TextStyle(color: Colors.white), // Text color
              ),
            ),
            if (_placeName != null && _placeImageUrl != null)
              GestureDetector(
                onTap: () => _onTapCard({
                  'name': _placeName,
                  'image': _placeImageUrl,
                }, widget.token),
                child: Card(
                  clipBehavior: Clip.antiAlias,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Image.network(
                        _placeImageUrl!,
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          color: Colors.black54,
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            _placeName!,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
