import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'buslist.dart';
import 'buspage.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController sourceController = TextEditingController();
  final TextEditingController destinationController = TextEditingController();
  final TextEditingController searchController = TextEditingController();
  String selectedTime = "8:30";
  String selectedPeriod = "AM";

  Future<void> searchBus(int busNumber) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('bus')
        .where('bus_no', isEqualTo: busNumber)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      Map<String, dynamic> busData =
          querySnapshot.docs.first.data() as Map<String, dynamic>;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => BusPage(busNo: busData['bus_no'].toString()),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("No bus found with number $busNumber")),
      );
    }
  }

  void searchBuses() {
    if (sourceController.text.isEmpty || destinationController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please enter source and destination")),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BusInfoPage(
          source: sourceController.text,
          destination: destinationController.text,
          selectedTime: "$selectedTime $selectedPeriod",
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header with search bar
            Container(
              padding: EdgeInsets.symmetric(vertical: 20, horizontal: 15),
              decoration: BoxDecoration(
                color: Color(0xFF2D5FFF),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 40),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: TextField(
                            controller: searchController,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              hintText: "Search bus number",
                              prefixIcon: Icon(Icons.search),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            onSubmitted: (value) async {
                              if (value.isNotEmpty) {
                                int? busNumber = int.tryParse(
                                    value.trim()); // Convert input to number
                                if (busNumber != null) {
                                  await searchBus(busNumber); // Pass as integer
                                } else {
                                  // Handle invalid input
                                  print("Please enter a valid bus number");
                                }
                              }
                            }),
                      ),
                      SizedBox(width: 10),
                      Icon(Icons.menu, color: Colors.white, size: 30),
                    ],
                  ),

                  SizedBox(height: 20),

                  // White card with input fields
                  Container(
                    padding: EdgeInsets.all(15),
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
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("From",
                                      style: TextStyle(
                                          fontSize: 12, color: Colors.grey)),
                                  SizedBox(height: 5),
                                  TextField(
                                    controller: sourceController,
                                    decoration: InputDecoration(
                                      hintText: "Enter Source",
                                      filled: true,
                                      fillColor: Color(0xFFDDE5FF),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: BorderSide.none,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(Icons.swap_horiz, color: Colors.blue),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("To",
                                      style: TextStyle(
                                          fontSize: 12, color: Colors.grey)),
                                  SizedBox(height: 5),
                                  TextField(
                                    controller: destinationController,
                                    decoration: InputDecoration(
                                      hintText: "Enter Destination",
                                      filled: true,
                                      fillColor: Color(0xFFDDE5FF),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: BorderSide.none,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 15),

                        // Time selection
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
                                    GestureDetector(
                                      onTap: () async {
                                        TimeOfDay? pickedTime =
                                            await showTimePicker(
                                          context: context,
                                          initialTime:
                                              TimeOfDay(hour: 8, minute: 30),
                                        );
                                        if (pickedTime != null) {
                                          setState(() {
                                            selectedTime =
                                                "${pickedTime.hourOfPeriod}:${pickedTime.minute.toString().padLeft(2, '0')}";
                                            selectedPeriod =
                                                pickedTime.period ==
                                                        DayPeriod.am
                                                    ? "AM"
                                                    : "PM";
                                          });
                                        }
                                      },
                                      child: Text(
                                        selectedTime,
                                        style: TextStyle(fontSize: 16),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(width: 10),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              decoration: BoxDecoration(
                                color: Color(0xFFDDE5FF),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: selectedPeriod,
                                  items: ["AM", "PM"].map((String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(value,
                                          style: TextStyle(fontSize: 16)),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      selectedPeriod = value!;
                                    });
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 15),

                        // Search button
                        ElevatedButton(
                          onPressed: searchBuses,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF2D5FFF),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: EdgeInsets.symmetric(vertical: 15),
                            minimumSize: Size(double.infinity, 50),
                          ),
                          child: Text("Search Buses",
                              style:
                                  TextStyle(fontSize: 16, color: Colors.white)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
