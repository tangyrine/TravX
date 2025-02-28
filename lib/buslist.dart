import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'main.dart';

class BusInfoPage extends StatefulWidget {
  final String source;
  final String destination;

  BusInfoPage({required this.source, required this.destination});

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

    setState(() {
      buses = querySnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
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
                    subtitle: Text('Total Seats: ${bus['total_seats']}'),
                  ),
                );
              },
            ),
    );
  }
}
