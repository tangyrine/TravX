import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class BusPage extends StatefulWidget {
  final String busNo;

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
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('bus')
        .where('bus_no', isEqualTo: int.tryParse(widget.busNo) ?? widget.busNo)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      setState(() {
        busData = querySnapshot.docs.first.data() as Map<String, dynamic>;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (busData == null) {
      return Scaffold(
        appBar: AppBar(title: Text('Bus Details')),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    List<dynamic> stops = busData!['stops'] ?? [];
    String source = busData!['source_name'] ?? "Unknown";
    String destination = busData!['destination_name'] ?? "Unknown";
    String estimatedTime = _formatTime(busData!['arrival']);

    return Scaffold(
      appBar: AppBar(title: Text('Bus Details')),
      body: Padding(
        padding: EdgeInsets.all(15),
        child: Column(
          children: [
            Text(
              'Bus No: ${widget.busNo}',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView(
                children: [
                  _stopTile("Your Location", source, Icons.directions_walk),
                  for (var stop in stops)
                    _stopTile("Stop", stop, Icons.directions_bus),
                  _stopTile("Destination", destination, Icons.location_on),
                ],
              ),
            ),
            SizedBox(height: 20),
            Text(
              "Estimated Time: $estimatedTime",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              "Seats Available: ${busData!['available_seats']}",
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
              ),
              onPressed: () {
                // Implement booking logic
              },
              child: Text("Book Ticket"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _stopTile(String title, String location, IconData icon) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, color: Colors.blue, size: 30),
            SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  Text(location,
                      style: TextStyle(fontSize: 14, color: Colors.grey)),
                ],
              ),
            ), // Placeholder time, replace with actual
          ],
        ),
        Padding(
          padding: EdgeInsets.only(left: 15, top: 5, bottom: 5),
          child: Container(
              width: 2, height: 30, color: Colors.grey), // Vertical line
        ),
      ],
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
      validTimes.sort(); // Sort to get the next arrival time
      return DateFormat('h:mm a').format(validTimes.first);
    }

    return "Unknown";
  }
}
