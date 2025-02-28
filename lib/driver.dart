import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Firestore for real-time updates

class ConductorTrackingScreen extends StatefulWidget {
  @override
  _ConductorTrackingScreenState createState() =>
      _ConductorTrackingScreenState();
}

class _ConductorTrackingScreenState extends State<ConductorTrackingScreen> {
  final List<LatLng> route = [
    LatLng(15.3000, 73.9000), // Bus Stop (Margao KTC)
    LatLng(15.3025, 73.9050),
    LatLng(15.3050, 73.9100),
    LatLng(15.3080, 73.9150), // Midway
    LatLng(15.3120, 73.9200),
    LatLng(15.3150, 73.9250), // Destination
  ];

  int _currentIndex = 0;
  late Timer _timer;
  late FirebaseFirestore _firestore;

  @override
  void initState() {
    super.initState();
    _firestore = FirebaseFirestore.instance;
    _startLocationSimulation();
  }

  void _startLocationSimulation() {
    _timer = Timer.periodic(Duration(seconds: 5), (timer) {
      if (_currentIndex < route.length - 1) {
        setState(() {
          _currentIndex++;
        });

        // Update Firestore (Optional - Use for real-time updates)
        _firestore.collection('driver').doc('').set({
          'latitude': route[_currentIndex].latitude,
          'longitude': route[_currentIndex].longitude,
          'timestamp': DateTime.now().toIso8601String(),
        });
      } else {
        _timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Conductor Tracking")),
      body: FlutterMap(
        options: MapOptions(
          center: route.first,
          zoom: 15.0,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
          ),
          MarkerLayer(
            markers: [
              Marker(
                width: 40.0,
                height: 40.0,
                point: route[_currentIndex],
                child: Icon(Icons.directions_bus, color: Colors.red, size: 30),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
