import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ConductorTrackingScreen extends StatefulWidget {
  const ConductorTrackingScreen({super.key});

  @override
  _ConductorTrackingScreenState createState() =>
      _ConductorTrackingScreenState();
}

class _ConductorTrackingScreenState extends State<ConductorTrackingScreen> {
  final List<LatLng> route = [
    LatLng(15.4989, 73.8278), // Panjim
    LatLng(15.5100, 73.8285),
    LatLng(15.5200, 73.8290),
    LatLng(15.5300, 73.8295),
    LatLng(15.5400, 73.8300), // Stop at Porvorim
    LatLng(15.5500, 73.8290),
    LatLng(15.5600, 73.8280),
    LatLng(15.5700, 73.8260),
    LatLng(15.5800, 73.8230),
    LatLng(15.5900, 73.8210),
    LatLng(15.6000, 73.8200), // Destination: Mapusa
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
    _timer = Timer.periodic(Duration(minutes: 2), (timer) {
      if (_currentIndex < route.length - 1) {
        setState(() {
          _currentIndex++;
        });

        // Update Firestore in a single document
        _firestore.collection('driver').doc('driverLocation').set({
          'latitude': route[_currentIndex].latitude,
          'longitude': route[_currentIndex].longitude,
          'timestamp': DateTime.now().toIso8601String(),
        }, SetOptions(merge: true)); // Ensures only fields are updated
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
          zoom: 13.0,
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
