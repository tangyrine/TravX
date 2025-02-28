import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Bookticket extends StatefulWidget {
  final int busNo; // Bus number as integer

  const Bookticket({super.key, required this.busNo});

  @override
  _Bookticket createState() => _Bookticket();
}

class _Bookticket extends State<Bookticket> {
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController ageController = TextEditingController();

  String source = "";
  String destination = "";
  double ticketPrice = 0.0;

  @override
  void initState() {
    super.initState();
    fetchBusDetails();
  }

  Future<void> fetchBusDetails() async {
    DocumentSnapshot busDoc = await FirebaseFirestore.instance
        .collection('bus')
        .where('bus_no', isEqualTo: widget.busNo)
        .limit(1)
        .get()
        .then((snapshot) => snapshot.docs.first);

    if (busDoc.exists) {
      setState(() {
        source = busDoc['source_name'];
        destination = busDoc['destination_name'];
      });
    }
  }

  Future<void> bookTicket() async {
    String firstName = firstNameController.text.trim();
    String lastName = lastNameController.text.trim();
    int? age = int.tryParse(ageController.text.trim());

    if (firstName.isEmpty || lastName.isEmpty || age == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill all fields correctly')),
      );
      return;
    }

    // Determine the category and price
    String category;
    if (age >= 1 && age <= 22) {
      category = "student";
      ticketPrice = 10.0;
    } else if (age > 22 && age <= 59) {
      category = "adult";
      ticketPrice = 20.0;
    } else if (age >= 60 && age <= 100) {
      category = "senior_citizen";
      ticketPrice = 15.0;
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Invalid age entered')),
      );
      return;
    }

    // Get logged-in user
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User not logged in')),
      );
      return;
    }

    String userId = user.uid;
    CollectionReference ticketsCollection = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('tickets');

    await ticketsCollection.add({
      'first_name': firstName,
      'last_name': lastName,
      'age': age,
      'category': category,
      'price': ticketPrice,
      'bus_no': widget.busNo,
      'source': source,
      'destination': destination,
      'time': DateFormat('h:mm a').format(DateTime.now()),
      'date': DateFormat('dd MMMM yyyy').format(DateTime.now()),
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Ticket booked successfully!')),
    );

    // Clear inputs
    firstNameController.clear();
    lastNameController.clear();
    ageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Payment Details")),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              color: Colors.white,
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text("Bus No: ${widget.busNo}",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          children: [
                            Text("From"),
                            Chip(
                                label: Text(
                                    source.isEmpty ? "Loading..." : source)),
                          ],
                        ),
                        Icon(Icons.compare_arrows),
                        Column(
                          children: [
                            Text("To"),
                            Chip(
                                label: Text(destination.isEmpty
                                    ? "Loading..."
                                    : destination)),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Icon(Icons.access_time),
                        SizedBox(width: 10),
                        Text(DateFormat('h:mm a').format(DateTime.now())),
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Icon(Icons.calendar_today),
                        SizedBox(width: 10),
                        Text(DateFormat('dd MMMM yyyy').format(DateTime.now())),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: firstNameController,
              decoration: InputDecoration(labelText: "First name"),
            ),
            TextField(
              controller: lastNameController,
              decoration: InputDecoration(labelText: "Last name"),
            ),
            TextField(
              controller: ageController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: "Age"),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 40),
              ),
              onPressed: bookTicket,
              child: Text("Pay $ticketPrice"),
            ),
          ],
        ),
      ),
    );
  }
}
