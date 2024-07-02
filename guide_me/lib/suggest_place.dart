import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:jwt_decode/jwt_decode.dart';
import 'package:google_fonts/google_fonts.dart';
import 'AppLocalization.dart';


class SuggestionPage extends StatefulWidget {
  final String token;
  final Locale? locale;
  final AppLocalization appLocalization;

  const SuggestionPage({Key? key, required this.token,required this.appLocalization,
    this.locale}) : super(key: key);

  @override
  _SuggestionPageState createState() => _SuggestionPageState();
}

class _SuggestionPageState extends State<SuggestionPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _placeController = TextEditingController();
  final TextEditingController _manualAddressController = TextEditingController();
  String? _address;
  String? _latitude;
  String? _longitude;

  Future<void> _searchPlace() async {
    if (_formKey.currentState!.validate()) {
      final String placeName = _placeController.text;

      try {
        // Fetch latitude, longitude, and address from OpenStreetMap
        final response = await http.get(
          Uri.parse(
              'https://nominatim.openstreetmap.org/search?q=$placeName+Egypt&format=json'),
        );

        print('OpenStreetMap response: ${response.body}'); // Debug statement

        if (response.statusCode == 200) {
          final List<dynamic> data = json.decode(response.body);
          if (data.isNotEmpty) {
            setState(() {
              _address = data[0]['display_name'];
              _latitude = data[0]['lat'];
              _longitude = data[0]['lon'];
            });
          } else {
            _showManualAddressInput();
          }
        } else {
          _showAlertDialog(widget.appLocalization.translate('Failed to fetch location'),
              widget.appLocalization.translate('Failed to fetch location from OpenStreetMap'));
        }
      } catch (e) {
        print('Error: $e'); // Debug statement
        _showAlertDialog(widget.appLocalization.translate('An error occurred'), e.toString());
      }
    }
  }
  void _showManualAddressInput() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(widget.appLocalization.translate(' Place not found you can Enter Address Manually')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _manualAddressController,
                decoration: InputDecoration(
                  labelText: widget.appLocalization.translate('Address'),
                  hintText: widget.appLocalization.translate('Enter the address manually'),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an address';
                  }
                  return null;
                },
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                widget.appLocalization.translate('Cancel'),
                style: TextStyle(color: Colors.white), // Keep original color
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(
                widget.appLocalization.translate('Confirm'),
                style: TextStyle(color: Colors.white), // Change color to white
              ),
              onPressed: () {
                if (_manualAddressController.text.isNotEmpty) {
                  setState(() {
                    _address = _manualAddressController.text;
                    _latitude = null;
                    _longitude = null;
                  });
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }


  Future<void> _confirmSuggestion() async {
    if ((_latitude != null && _longitude != null && _address != null) ||
        (_address != null && _latitude == null && _longitude == null)) {
      final String placeName = _placeController.text;
      final String touristName = decodeToken(widget.token);
      String apiUrl;

      if (_latitude != null && _longitude != null) {
        apiUrl =
        'http://guideme.somee.com/api/SuggestionPlaces?placeName=$placeName&latitude=$_latitude&longitude=$_longitude&touristName=$touristName';
      } else {
        apiUrl =
        'http://guideme.somee.com/api/SuggestionPlaces?placeName=$placeName&address=$_address&touristName=$touristName';
      }

      try {
        // Send the suggestion to the API
        final apiResponse = await http.post(
          Uri.parse(apiUrl),
          headers: {
            'accept': '/',
            'Authorization': 'Bearer ${widget.token}',
          },
        );

        print('API response: ${apiResponse.body}'); // Debug statement

        if (apiResponse.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(widget.appLocalization.translate('Your suggestion sent successfully'))));

        } else {
          _showAlertDialog(widget.appLocalization.translate('Failed to send suggestion'), apiResponse.body);

        }
      } catch (e) {
        print('Error: $e'); // Debug statement
        _showAlertDialog('An error occurred', e.toString());
      }
    }
  }

  void _showAlertDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  String decodeToken(String token) {
    Map<String, dynamic> decodedToken = Jwt.parseJwt(token);
    return decodedToken[
    'http://schemas.xmlsoap.org/ws/2005/05/identity/claims/name'] ??
        '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            widget.appLocalization.translate('Suggest Place'),

          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Color.fromARGB(255, 246, 243, 177),
        iconTheme: IconThemeData(color: Colors.black),
      ),
      backgroundColor: Color.fromARGB(255, 246, 243, 177),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
          Center(
          child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20.0),
          child: Text(
            widget.appLocalization.translate('Thank you for helping us add more places'),
            style: GoogleFonts.lato(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),

        SizedBox(height: 26),
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _placeController,
                      textAlign: TextAlign.center, // Center the text field
                      decoration: InputDecoration(
                        labelText: widget.appLocalization.translate('PlaceName'),
                        labelStyle: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                        ),
                        // Added bottom black border
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.black),
                        ),
                        // Removed background color and border
                      ),
                      style: TextStyle(color: Colors.black),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a place name';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 26),
                    Center(
                      child: SizedBox(
                        width: 150, // Set the width to your desired value
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: _searchPlace,
                          child: Text(widget.appLocalization.translate('Search')),
                        ),
                      ),
                    ),
                    SizedBox(height: 30),
                    if (_address != null) ...[
                      Text(
                        widget.appLocalization.translate('Address'),
                        style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 25),
                      ),
                      SizedBox(height: 15),
                      Text(
                        _address!,
                        style: TextStyle(color: Colors.black, fontSize: 22),
                      ),
                      SizedBox(height: 26), // Added space after address
                      Center(
                        child: SizedBox(
                          width: 150, // Set the width to your desired value
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              foregroundColor: Colors.white,
                              minimumSize: Size(40, 40), // Set smaller button size
                            ),
                            onPressed: _confirmSuggestion,
                            child: Text(widget.appLocalization.translate('Confirm')),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
