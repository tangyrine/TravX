import 'package:flutter/material.dart';
import 'mappage.dart';
import 'businfo.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:latlong2/latlong.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController sourceController = TextEditingController();
  final TextEditingController destinationController = TextEditingController();
  LatLng? sourceCoords;
  LatLng? destinationCoords;

  void searchBuses() async {
    if (sourceController.text.isEmpty || destinationController.text.isEmpty) {
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BusInfoPage(
          source: sourceController.text,
          destination: destinationController.text,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Bus Search')),
      body: Column(
        children: [
          TextField(
              controller: sourceController,
              decoration: InputDecoration(labelText: 'Enter Source')),
          TextField(
              controller: destinationController,
              decoration: InputDecoration(labelText: 'Enter Destination')),
          SizedBox(height: 10),
          ElevatedButton(onPressed: searchBuses, child: Text('Search Buses')),
          Expanded(
            child: GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MapPage()),
              ),
              child: Container(
                height: 200,
                color: Colors.grey[300],
                child: Center(child: Text('Tap to open Map')),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
