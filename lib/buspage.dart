import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as latlong;
import 'bookticket.dart';
import 'sidebar.dart';
import 'driver.dart';

class BusPage extends StatefulWidget {
  final int busNo;

  const BusPage({super.key, required this.busNo});

  @override
  _BusPageState createState() => _BusPageState();
}

class _BusPageState extends State<BusPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  Map<String, dynamic>? busData;
  String driverLocationName = "Fetching location...";
  double? driverLatitude;
  double? driverLongitude;
  List<dynamic>? stops = [];

  @override
  void initState() {
    super.initState();
    fetchBusDetails();
    fetchDriverLocation();
    Future.delayed(Duration.zero, () {
      LocationService().startLocationSimulation();
    });
  }

  Future<void> fetchBusDetails() async {
    QuerySnapshot busSnapshot = await FirebaseFirestore.instance
        .collection('bus')
        .where('bus_no', isEqualTo: widget.busNo)
        .get();

    if (busSnapshot.docs.isNotEmpty) {
      var busDoc = busSnapshot.docs.first;
      // Retrieve route details from a subcollection if available
      String routeId = busDoc['route_id'];
      DocumentSnapshot routeSnapshot =
          await busDoc.reference.collection('route').doc(routeId).get();

      if (routeSnapshot.exists) {
        Map<String, dynamic> routeData =
            routeSnapshot.data() as Map<String, dynamic>;
        stops = routeData['stops'] ?? [];
      }

      setState(() {
        busData = {
          'source_name': busDoc['source_name'],
          'destination_name': busDoc['destination_name'],
          'arrival': busDoc['arrival'],
          'available_seats': busDoc['available_seats'],
          'stops': stops,
        };
      });
    }
  }

  void fetchDriverLocation() {
    FirebaseFirestore.instance
        .collection('driver')
        .doc('driverLocation')
        .snapshots()
        .listen((driverSnapshot) {
      if (driverSnapshot.exists) {
        Map<String, dynamic> driverData =
            driverSnapshot.data() as Map<String, dynamic>;
        setState(() {
          driverLatitude = driverData['latitude'];
          driverLongitude = driverData['longitude'];
          driverLocationName = "Lat: $driverLatitude, Lon: $driverLongitude";
        });
      }
    }, onError: (error) {
      print("Error fetching driver location: $error");
    });
  }

  // Function to extract only the name from the stop data
  String extractStopName(dynamic stopData) {
    if (stopData is Map) {
      return stopData['name'] ?? "Unknown Stop";
    } else if (stopData is String) {
      // If it's already a string, parse it if it looks like a map representation
      if (stopData.contains('name:')) {
        // Basic string parsing to extract name between "name:" and the next comma or closing brace
        final nameStart = stopData.indexOf('name:') + 5;
        int nameEnd = stopData.indexOf(',', nameStart);
        if (nameEnd == -1) nameEnd = stopData.indexOf('}', nameStart);
        if (nameEnd == -1) nameEnd = stopData.length;

        return stopData.substring(nameStart, nameEnd).trim();
      }
      return stopData;
    }
    return "Unknown Stop";
  }

  @override
  Widget build(BuildContext context) {
    if (busData == null) {
      return Scaffold(
        backgroundColor: Color(0xFF2853E0),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    String source = busData!['source_name'] ?? "Unknown";
    String destination = busData!['destination_name'] ?? "Unknown";
    String estimatedTime = _formatTime(busData!['arrival']);
    String availableSeats = busData!['available_seats'].toString();

    return Scaffold(
      key: _scaffoldKey,
      drawer: AppSidebar(),
      appBar: AppBar(
        backgroundColor: Color(0xFF2853E0),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // White container with bus details
            Expanded(
              child: Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 5,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text('Bus No: ${widget.busNo}',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 22, fontWeight: FontWeight.bold)),
                      SizedBox(height: 20),
                      // Display source, stops (if available), and destination
                      _locationTile("Your Location", source,
                          Icons.directions_walk, "", Colors.blue),
                      if (stops != null && stops!.isNotEmpty) ...[
                        Center(child: _verticalDivider()),
                        for (var stop in stops!) ...[
                          _locationTile("Stop", extractStopName(stop),
                              Icons.stop, "", Colors.orange),
                          Center(child: _verticalDivider()),
                        ],
                      ],
                      _locationTile("Destination", destination,
                          Icons.location_on, "", Colors.green),
                      SizedBox(height: 20),
                      Text("Estimated Arrival Time",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 14, color: Colors.grey)),
                      SizedBox(height: 5),
                      Text(estimatedTime,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold)),
                      SizedBox(height: 15),
                      Text("Total Seats: $availableSeats Seats",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                      SizedBox(height: 20),
                      Text("Driver's Current Location:",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                      Text(driverLocationName,
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16, color: Colors.grey)),
                      SizedBox(height: 10),
                      Center(
                        child: ElevatedButton(
                          onPressed: () {
                            if (driverLatitude != null &&
                                driverLongitude != null) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => MapPage(
                                    latitude: driverLatitude!,
                                    longitude: driverLongitude!,
                                  ),
                                ),
                              );
                            }
                          },
                          child: Text("View on Map"),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 15),
            // Book Ticket button
            Center(
              child: SizedBox(
                width: MediaQuery.of(context).size.width - 30,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Bookticket(
                          busNo: widget.busNo, // Passing the bus number
                        ),
                      ),
                    );
                  },
                  child: Text("Book Ticket", style: TextStyle(fontSize: 18)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _locationTile(String title, String location, IconData icon,
      String time, Color circleColor) {
    return Column(
      children: [
        // Center the icon
        Center(
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: circleColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 22),
          ),
        ),
        SizedBox(height: 8), // Add space between icon and text
        // Center the text
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(title,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Text(location,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey)),
            if (time.isNotEmpty)
              Text(time,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
      ],
    );
  }

  Widget _verticalDivider() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 20), // Increased vertical spacing
      child: Container(
        width: 2,
        height: 40,
        color: Colors.grey,
      ),
    );
  }
}

String _formatTime(List<dynamic>? times) {
  if (times == null || times.isEmpty) return "Unknown";
  DateTime now = DateTime.now();
  List<DateTime> validTimes = times
      .whereType<Timestamp>()
      .map((t) => (t as Timestamp).toDate())
      .where((time) => time.isAfter(now))
      .toList();
  if (validTimes.isNotEmpty) {
    validTimes.sort();
    return DateFormat('h:mm a').format(validTimes.first);
  }
  return "Unknown";
}

class MapPage extends StatelessWidget {
  final double latitude;
  final double longitude;

  const MapPage({super.key, required this.latitude, required this.longitude});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Driver Location',
          style: TextStyle(color: Colors.white), // White text
        ),
        centerTitle: true, // Center the title
        backgroundColor: Color(0xFF2853E0), // Blue color
        iconTheme: IconThemeData(color: Colors.white), // White back button
      ),
      body: FlutterMap(
        options: MapOptions(
          center: latlong.LatLng(latitude, longitude),
          zoom: 13.0,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.app',
          ),
          MarkerLayer(
            markers: [
              Marker(
                point: latlong.LatLng(latitude, longitude),
                width: 80,
                height: 80,
                child: Icon(Icons.location_on, color: Colors.red, size: 40),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
