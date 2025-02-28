import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'bookticket.dart';

class BusPage extends StatefulWidget {
  final int busNo;

  const BusPage({super.key, required this.busNo});

  @override
  _BusPageState createState() => _BusPageState();
}

class _BusPageState extends State<BusPage> {
  Map<String, dynamic>? busData;

  @override
  void initState() {
    super.initState();
    fetchBusDetails();
  }

  Future<void> fetchBusDetails() async {
    QuerySnapshot busSnapshot = await FirebaseFirestore.instance
        .collection('bus')
        .where('bus_no', isEqualTo: widget.busNo)
        .get();

    if (busSnapshot.docs.isNotEmpty) {
      var busDoc = busSnapshot.docs.first;
      String routeId = busDoc['route_id'];

      DocumentSnapshot routeSnapshot =
          await busDoc.reference.collection('route').doc(routeId).get();

      if (routeSnapshot.exists) {
        Map<String, dynamic> routeData =
            routeSnapshot.data() as Map<String, dynamic>;

        // Extract stops dynamically
        List<dynamic>? stops = routeData['stops'] ?? [];

        setState(() {
          busData = {
            'source_name': busDoc['source_name'],
            'destination_name': busDoc['destination_name'],
            'arrival': busDoc['arrival'],
            'available_seats': busDoc['available_seats'],
            'stops': stops, // Store stops list
          };
        });
      }
    }
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

    // Check if stops exist in the Firestore data
    List<dynamic>? stops = busData!['stops'];

    return Scaffold(
      backgroundColor: Color(0xFF2853E0),
      appBar: AppBar(
        backgroundColor: Color(0xFF2853E0),
        elevation: 0,
        title: Text('Bus Details', style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(15),
        child: Column(
          children: [
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Bus No: ${widget.busNo}',
                      style:
                          TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 20),

                    // Source location
                    _locationTile("Your Location", source,
                        Icons.directions_walk, Colors.blue),

                    // Add stops if available
                    if (stops != null && stops.isNotEmpty) ...[
                      for (int i = 0; i < stops.length; i++) ...[
                        _verticalDivider(),
                        _locationTile("Stop", stops[i], Icons.directions_bus,
                            Colors.orange.shade700),
                      ],
                      _verticalDivider(), // Divider before destination
                    ],

                    // Destination
                    _locationTile("Destination", destination, Icons.location_on,
                        Colors.green),

                    SizedBox(height: 20),
                    Text(
                      "Estimated Arrival Time From Your Location to the Destination",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    SizedBox(height: 5),
                    Text(
                      estimatedTime,
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 15),
                    Text(
                      "Available Seats: $availableSeats Seats",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 15),
            SizedBox(
              width: MediaQuery.of(context).size.width - 30,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange.shade700,
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
                      builder: (context) => Bookticket(busNo: widget.busNo),
                    ),
                  );
                },
                child: Text("Book Ticket", style: TextStyle(fontSize: 18)),
              ),
            ),
          ],
        ),
      ),
    );
  }

// Updated _locationTile function without unnecessary string parameter
  Widget _locationTile(
      String title, String location, IconData icon, Color circleColor) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: circleColor,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.white, size: 22),
        ),
        SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              Text(location,
                  style: TextStyle(fontSize: 14, color: Colors.grey)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _verticalDivider() {
    return Padding(
      padding: EdgeInsets.only(
          left: 19), // Aligns the line with the left side of the icons
      child: Container(
        width: 2,
        height: 40,
        color: Colors.grey,
      ),
    );
  }

  String _formatTime(List<dynamic>? times) {
    if (times == null || times.isEmpty) return "Unknown";

    DateTime now = DateTime.now();
    List<DateTime> validTimes = times
        .where((t) => t is Timestamp)
        .map((t) => (t as Timestamp).toDate())
        .where((time) => time.isAfter(now))
        .toList();

    if (validTimes.isNotEmpty) {
      validTimes.sort();
      return DateFormat('h:mm a').format(validTimes.first);
    }

    return "Unknown";
  }
}
