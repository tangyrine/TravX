import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // Import for formatting time

class BusInfoPage extends StatefulWidget {
  final String source;
  final String destination;

  const BusInfoPage({
    super.key,
    required this.source,
    required this.destination,
  });

  @override
  _BusInfoPageState createState() => _BusInfoPageState();
}

class _BusInfoPageState extends State<BusInfoPage> {
  List<Map<String, dynamic>> buses = [];

  Future<void> fetchBuses() async {
    print("Fetching buses for: ${widget.source} -> ${widget.destination}");
    print("Querying Firestore...");

    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('bus')
        .where('source_name', isEqualTo: widget.source)
        .where('destination_name', isEqualTo: widget.destination)
        .get();

    DateTime now = DateTime.now(); // Current timestamp

    setState(() {
      buses = querySnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .where((bus) {
        List<dynamic> departureTimes = bus['departure'] ?? [];

        // Filter only buses that haven't departed yet
        return departureTimes.any((time) {
          if (time is Timestamp) {
            return time.toDate().isAfter(now);
          }
          return false; // Ignore invalid formats
        });
      }).toList();
    });
  }

  @override
  void initState() {
    super.initState();
    fetchBuses();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Available Buses')),
      body: buses.isEmpty
          ? Center(child: Text('No buses found'))
          : ListView.builder(
              itemCount: buses.length,
              itemBuilder: (context, index) {
                final bus = buses[index];
                return Card(
                  child: ListTile(
                    title: Text('Bus No: ${bus['bus_no']}'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Total Seats: ${bus['total_seats']}'),
                        Text('Available Seats: ${bus['available_seats']}'),
                        Text(
                          'Departure from ${bus['source_name']}: ${_formatTime(bus['departure'])}',
                        ),
                        Text(
                          'Arrival at ${bus['destination_name']}: ${_formatTime(bus['arrival'])}',
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  String _formatTime(List<dynamic>? times) {
    if (times == null || times.isEmpty) return "No data available";
    DateTime now = DateTime.now();

    for (var time in times) {
      if (time is Timestamp) {
        DateTime busTime = time.toDate();
        if (busTime.isAfter(now)) {
          return DateFormat('HH:mm').format(busTime); // Show time in HH:mm
        }
      }
    }

    return "No upcoming times";
  }
}
