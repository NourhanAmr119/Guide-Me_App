
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MapPage extends StatelessWidget {
  final double latitude;
  final double longitude;

  MapPage({required this.latitude, required this.longitude, required String locationName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Map View'),
        backgroundColor: Color.fromARGB(255, 21, 82, 113),
      ),
      body: FlutterMap(
        options: MapOptions(
          initialCenter: LatLng(latitude, longitude),
          initialZoom: 15.0,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
            subdomains: ['a', 'b', 'c'],
          ),
          MarkerLayer(
            markers: [
              Marker(
                width: 80.0,
                height: 80.0,
                point: LatLng(latitude, longitude),
                child: Icon(Icons.location_pin, color: Colors.red, size: 40.0),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
