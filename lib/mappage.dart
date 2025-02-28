import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  LatLng? userLocation;
  List<LatLng> busStops = [
    LatLng(15.2993, 74.1240), // Example bus stop 1
    LatLng(15.4945, 73.8213), // Example bus stop 2
  ];

  // Fetch User Location
  Future<void> getUserLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Location Required'),
          content: Text('Please enable location services.'),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context), child: Text('OK'))
          ],
        ),
      );
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return;
      }
    }

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    setState(() {
      userLocation = LatLng(position.latitude, position.longitude);
    });
  }

  @override
  void initState() {
    super.initState();
    getUserLocation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Map')),
      body: FlutterMap(
        options: MapOptions(
          initialCenter: userLocation ?? LatLng(15.2993, 74.1240),
          initialZoom: 13,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
            subdomains: ['a', 'b', 'c'],
          ),
          MarkerLayer(
            markers: [
              if (userLocation != null)
                Marker(
                  point: userLocation!,
                  width: 40,
                  height: 40,
                  child: Icon(Icons.location_pin, color: Colors.blue, size: 30),
                ),
              ...busStops.map(
                (stop) => Marker(
                  point: stop,
                  width: 40,
                  height: 40,
                  child:
                      Icon(Icons.directions_bus, color: Colors.red, size: 30),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
