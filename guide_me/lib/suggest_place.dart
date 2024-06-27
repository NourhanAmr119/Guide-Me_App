import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decode/jwt_decode.dart';

class SuggestionPage extends StatefulWidget {
  final String token;

  SuggestionPage({required this.token});

  @override
  _SuggestionPageState createState() => _SuggestionPageState();
}

class _SuggestionPageState extends State<SuggestionPage> {
  final TextEditingController _controller = TextEditingController();
  LatLng _selectedLocation = LatLng(0, 0); // Initialize with a default value
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _searchLocation(String placeName) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      List<Location> locations = await locationFromAddress(placeName);

      if (locations.isNotEmpty) {
        setState(() {
          _selectedLocation = LatLng(locations.first.latitude, locations.first.longitude);
          _isLoading = false;
        });
      } else {
        setState(() {
          _selectedLocation = LatLng(0, 0); // Reset to default value
          _isLoading = false;
          _errorMessage = 'Location not found';
        });
      }
    } catch (e) {
      print('Error fetching location: $e');
      setState(() {
        _selectedLocation = LatLng(0, 0); // Reset to default value
        _isLoading = false;
        _errorMessage = 'Error fetching location: ${e.toString()}';
      });
    }
  }

  Future<void> _submitSuggestion() async {
    if (_selectedLocation.latitude != 0 && _selectedLocation.longitude != 0 && _controller.text.isNotEmpty) {
      final touristName = decodeToken(widget.token);
      final url = Uri.parse('http://guide-me.somee.com/api/SuggestionPlaces?placeName=${_controller.text}&latitude=${_selectedLocation.latitude}&longitude=${_selectedLocation.longitude}&touristName=$touristName');
      final response = await http.post(
        url,
        headers: {
          'accept': '/',
          'Authorization': 'Bearer ${widget.token}',
        },
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Suggestion submitted successfully.')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit suggestion.')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter a place name and select a location.')),
      );
    }
  }

  String decodeToken(String token) {
    Map<String, dynamic> decodedToken = Jwt.parseJwt(token);
    return decodedToken['http://schemas.xmlsoap.org/ws/2005/05/identity/claims/name'] ?? '';
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Suggest a Place'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              TextField(
                controller: _controller,
                decoration: InputDecoration(
                  labelText: 'Place Name',
                  suffixIcon: IconButton(
                    icon: Icon(Icons.search),
                    onPressed: () {
                      _searchLocation(_controller.text);
                    },
                  ),
                ),
              ),
              if (_isLoading) CircularProgressIndicator(),
              if (_errorMessage != null) Text(_errorMessage!, style: TextStyle(color: Colors.red)),
              Container(
                height: MediaQuery.of(context).size.height * 0.5, // Adjust height as needed
                child: FlutterMap(
                  options: MapOptions(
                    initialCenter: _selectedLocation ?? LatLng(0, 0),
                    initialZoom: _selectedLocation != null ? 15.0 : 2.0,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                      subdomains: ['a', 'b', 'c'],
                    ),
                    TileLayer(
                      urlTemplate:'https://{s}.tile.openstreetmap.fr/hot/{z}/{x}/{y}.png',
                      subdomains: ['a', 'b', 'c'],
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          width: 80.0,
                          height: 80.0,
                          point: _selectedLocation!,
                          child: Icon(Icons.location_pin, color: Colors.red, size: 40.0),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: _submitSuggestion,
                child: Text('Submit Suggestion'),
              ),
            ],
          ),
        ),
      ),
    );
  }

}