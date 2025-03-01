import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'buspage.dart';
import 'sidebar.dart';
import 'driver.dart';

class BusInfoPage extends StatefulWidget {
  final String source;
  final String destination;
  final String selectedTime;

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
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  List<Map<String, dynamic>> buses = [];
  bool isLoading = true;
  Future<void> fetchBuses() async {
    setState(() {
      isLoading = true; // Show loading before fetching data
    });

    // Step 1: Get buses matching source
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('bus')
        .where('source_name', isEqualTo: widget.source)
        .get();

    DateTime selectedDateTime = _parseSelectedTime(widget.selectedTime);

    List<Map<String, dynamic>> filteredBuses = [];

    for (var doc in querySnapshot.docs) {
      Map<String, dynamic> busData = doc.data() as Map<String, dynamic>;

      // Step 2: Check if destination matches directly
      if (busData['destination_name'] == widget.destination) {
        // Step 3: Check departure time condition
        List<dynamic> departureTimes = busData['departure'] ?? [];
        bool isValidTime = departureTimes.any((time) {
          if (time is Timestamp) {
            return time.toDate().isAfter(selectedDateTime);
          }
          return false;
        });

        if (isValidTime) {
          filteredBuses.add(busData);
          continue; // Skip checking stops if direct match is found
        }
      }

      // Step 4: If no direct match, check stops inside the route document
      String routeId = busData['route_id']; // Get route document ID

      DocumentSnapshot routeDoc = await FirebaseFirestore.instance
          .collection('bus')
          .doc(doc.id) // Get the bus document first
          .collection(
              'route') // Access the route collection inside the bus document
          .doc(routeId) // Get the specific route document
          .get();

      if (routeDoc.exists) {
        List<dynamic> stops = routeDoc['stops'] ?? [];

        bool hasDestination = stops.any((stop) {
          return stop is Map<String, dynamic> &&
              stop['name'] == widget.destination;
        });

        if (hasDestination) {
          // Step 5: Check departure time condition
          List<dynamic> departureTimes = busData['departure'] ?? [];
          bool isValidTime = departureTimes.any((time) {
            if (time is Timestamp) {
              return time.toDate().isAfter(selectedDateTime);
            }
            return false;
          });

          if (isValidTime) {
            filteredBuses.add(busData);
          }
        }
      }
    }

    setState(() {
      buses = filteredBuses;
      isLoading = false;
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
    Future.delayed(Duration.zero, () {
      LocationService().startLocationSimulation();
    });
    // Automatically navigate to ConductorTrackingScreen
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: AppSidebar(),
      appBar: AppBar(
        backgroundColor: Color(0xFF2853E0),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    "assets/giphy.gif", // Loading GIF
                    width: 200,
                    height: 200,
                  ),
                  SizedBox(height: 20),
                  CircularProgressIndicator(), // Spinner
                ],
              ),
            )
          : Column(
              children: [
                SizedBox(height: 10),
                Container(
                  padding: EdgeInsets.all(15),
                  margin: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 5,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Color(0xFFDDE5FF),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("From",
                                      style: TextStyle(
                                          fontSize: 12, color: Colors.grey)),
                                  SizedBox(height: 5),
                                  Text(widget.source,
                                      style: TextStyle(fontSize: 16)),
                                ],
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            child: Icon(Icons.swap_horiz,
                                color: Colors.blue, size: 30),
                          ),
                          Expanded(
                            child: Container(
                              padding: EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Color(0xFFDDE5FF),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("To",
                                      style: TextStyle(
                                          fontSize: 12, color: Colors.grey)),
                                  SizedBox(height: 5),
                                  Text(widget.destination,
                                      style: TextStyle(fontSize: 16)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 15),
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 16),
                              decoration: BoxDecoration(
                                color: Color(0xFFDDE5FF),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.access_time,
                                      color: Colors.black54),
                                  SizedBox(width: 5),
                                  Text(widget.selectedTime,
                                      style: TextStyle(fontSize: 16)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10),
                Text("Available Buses",
                    style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.bold)),
                SizedBox(height: 10),
                Expanded(
                  child: buses.isEmpty
                      ? Center(
                          child: Text('No buses found',
                              style: TextStyle(color: Colors.white)))
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
                                    Text(
                                        'Seats Available: ${bus['available_seats']}'),
                                    Text(
                                        'Departure from ${bus['source_name']}: ${_formatTime(bus['departure']?.first)}'),
                                    Text(
                                        'Arrival at ${bus['destination_name']}: ${_formatTime(bus['arrival']?.first)}'),
                                  ],
                                ),
                                trailing: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Color(0xFF2853E0),
                                    foregroundColor: Colors.white,
                                  ),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => BusPage(
                                          busNo: int.tryParse(
                                                  bus['bus_no'].toString()) ??
                                              0, // Ensures a valid int
                                        ),
                                      ),
                                    );
                                  },
                                  child: Text("View Details"),
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }

  String _formatTime(dynamic time) {
    if (time is Timestamp) {
      return DateFormat('h:mm a').format(time.toDate());
    }
    return "No data available";
  }
}
