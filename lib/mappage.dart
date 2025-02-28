import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MapPage extends StatefulWidget {
  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  LatLng? userLocation;
  List<LatLng> busStops = [
    LatLng(15.2993, 74.1240),
    LatLng(15.4945, 73.8213),
  ];

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
    Position position = await Geolocator.getCurrentPosition();
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
        options: MapOptions(center: userLocation ?? LatLng(0, 0), zoom: 13),
        children: [
          TileLayer(
              urlTemplate:
                  'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png'),
          MarkerLayer(markers: [
            if (userLocation != null)
              Marker(
                  point: userLocation!,
                  builder: (context) =>
                      Icon(Icons.location_pin, color: Colors.blue)),
            ...busStops.map((stop) => Marker(
                point: stop,
                builder: (context) =>
                    Icon(Icons.directions_bus, color: Colors.red))),
          ]),
        ],
      ),
    );
  }
}
