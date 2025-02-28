import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'buspage.dart'; // Import the new page

class BusInfoPage extends StatefulWidget {
  final String source;
  final String destination;
  final String selectedTime; // Added to filter buses based on selected time

  const BusInfoPage({
    super.key,
    required this.source,
    required this.destination,
    required this.selectedTime,
  });

  @override
  _BusInfoPageState createState() => _BusInfoPageState();
}

class _BusInfoPageState extends State<BusInfoPage> {
  List<Map<String, dynamic>> buses = [];

  Future<void> fetchBuses() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('bus')
        .where('source_name', isEqualTo: widget.source)
        .where('destination_name', isEqualTo: widget.destination)
        .get();

    DateTime selectedDateTime = _parseSelectedTime(widget.selectedTime);

    setState(() {
      buses = querySnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .where((bus) {
        List<dynamic> departureTimes = bus['departure'] ?? [];
        return departureTimes.any((time) {
          if (time is Timestamp) {
            return time.toDate().isAfter(selectedDateTime);
          }
          return false;
        });
      }).toList();
    });
  }

  DateTime _parseSelectedTime(String selectedTime) {
    final now = DateTime.now();
    final timeParts = selectedTime.split(' ');
    final hourMinute = timeParts[0].split(':');
    int hour = int.parse(hourMinute[0]);
    int minute = int.parse(hourMinute[1]);
    if (timeParts[1] == 'PM' && hour != 12) {
      hour += 12;
    } else if (timeParts[1] == 'AM' && hour == 12) {
      hour = 0;
    }
    return DateTime(now.year, now.month, now.day, hour, minute);
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
                  margin: EdgeInsets.all(10),
                  child: ListTile(
                    title: Text('Bus No: ${bus['bus_no']}'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Seats Available: ${bus['available_seats']}'),
                        Text(
                            'Departure from ${bus['source_name']}: ${_formatTime(bus['departure']?.first)}'),
                        Text(
                            'Arrival at ${bus['destination_name']}: ${_formatTime(bus['arrival']?.first)}'),
                      ],
                    ),
                    trailing: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BusPage(
                                busNo: bus['bus_no']
                                    .toString()), // Convert to String
                          ),
                        );
                      },
                      child: Text("View Details"),
                    ),
                  ),
                );
              },
            ),
    );
  }

  String _formatTime(dynamic time) {
    if (time is Timestamp) {
      return DateFormat('h:mm a')
          .format(time.toDate()); // Convert timestamp to formatted time
    }
    return "No data available";
  }
}
