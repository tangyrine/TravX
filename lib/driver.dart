import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:latlong2/latlong.dart';

class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;

  LocationService._internal();

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
  Timer? _timer;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void startLocationSimulation() {
    _timer?.cancel(); // Ensure no multiple timers are running
    _timer = Timer.periodic(Duration(minutes: 2), (timer) {
      if (_currentIndex < route.length - 1) {
        _currentIndex++;

        _firestore.collection('driver').doc('driverLocation').set({
          'latitude': route[_currentIndex].latitude,
          'longitude': route[_currentIndex].longitude,
          'timestamp': DateTime.now().toIso8601String(),
        }, SetOptions(merge: true)); // Merge updates instead of overwriting
      } else {
        _timer?.cancel();
      }
    });
  }

  void stopLocationSimulation() {
    _timer?.cancel();
  }
}
