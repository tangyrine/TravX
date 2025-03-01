import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:travex/tickethistory.dart';
import 'sidebar.dart'; // Import the sidebar

class Bookticket extends StatefulWidget {
  final int busNo; // Bus number as integer

  const Bookticket({super.key, required this.busNo});

  @override
  _BookticketState createState() => _BookticketState();
}

class _BookticketState extends State<Bookticket> {
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController timeController =
      TextEditingController(text: "8:30");
  String selectedAmPm = "AM";

  DateTime selectedDate = DateTime.now();
  String formattedDate = DateFormat('dd MMMM yyyy').format(DateTime.now());

  String source = "";
  String destination = "";
  double ticketPrice = 10.0; // Default price as shown in the image

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

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

  void _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2025),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        formattedDate = DateFormat('dd MMMM yyyy').format(selectedDate);
      });
    }
  }

  void _updatePrice() {
    int? age = int.tryParse(ageController.text.trim());

    if (age != null) {
      setState(() {
        if (age >= 1 && age <= 22) {
          ticketPrice = 8.0;
        } else if (age > 22 && age <= 59) {
          ticketPrice = 15.0;
        } else if (age >= 60 && age <= 100) {
          ticketPrice = 8.0;
        } else {
          ticketPrice = 0.0;
        }
      });
    } else {
      setState(() {
        ticketPrice = 0.0;
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
      ticketPrice = 8.0;
    } else if (age > 22 && age <= 59) {
      category = "adult";
      ticketPrice = 15.0;
    } else if (age >= 60 && age <= 100) {
      category = "senior_citizen";
      ticketPrice = 8.0;
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

    // Reference to the bus document
    QuerySnapshot busSnapshot = await FirebaseFirestore.instance
        .collection('bus')
        .where('bus_no', isEqualTo: widget.busNo)
        .limit(1)
        .get();

    if (busSnapshot.docs.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Bus not found')),
      );
      return;
    }

    DocumentReference busDocRef = busSnapshot.docs.first.reference;
    Map<String, dynamic> busData =
        busSnapshot.docs.first.data() as Map<String, dynamic>;

    int availableSeats = busData['available_seats'] ?? 0;

    if (availableSeats <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No seats available')),
      );
      return;
    }

    // Format time
    String time = "${timeController.text} $selectedAmPm";

    // Book ticket
    await ticketsCollection.add({
      'first_name': firstName,
      'last_name': lastName,
      'age': age,
      'category': category,
      'price': ticketPrice,
      'bus_no': widget.busNo,
      'source': source,
      'destination': destination,
      'time': time,
      'date': formattedDate,
    });

    // Decrement available seats
    await busDocRef.update({
      'available_seats': availableSeats - 1,
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
    String busNoFormatted = "GA ${widget.busNo.toString().padLeft(4, '0')}";

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color.fromARGB(255, 23, 75, 245),
      endDrawer: AppSidebar(), // Use the Sidebar widget as the end drawer
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 40, 57, 238),
        foregroundColor: Colors.white,
        title: Text("Payment Details"),
        centerTitle: true,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: Icon(Icons.menu),
            onPressed: () {
              _scaffoldKey.currentState
                  ?.openEndDrawer(); // Open drawer from right
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Card with bus details
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "Bus No: $busNoFormatted",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 20),

                    // From - To section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          children: [
                            Text(
                              "From",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                            SizedBox(height: 8),
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.blue[50],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                source.isEmpty ? "Loading..." : source,
                                style: TextStyle(
                                  color: Colors.blue[800],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.grey[200],
                          ),
                          padding: EdgeInsets.all(8),
                          child: Icon(Icons.compare_arrows, color: Colors.blue),
                        ),
                        Column(
                          children: [
                            Text(
                              "To",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                            SizedBox(height: 8),
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.blue[50],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                destination.isEmpty
                                    ? "Loading..."
                                    : destination,
                                style: TextStyle(
                                  color: Colors.blue[800],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    SizedBox(height: 20),

                    // Time section
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Time",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 16),
                                decoration: BoxDecoration(
                                  color: Colors.blue[50],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.access_time, color: Colors.blue),
                                    SizedBox(width: 8),
                                    Expanded(
                                      child: TextField(
                                        controller: timeController,
                                        decoration: InputDecoration(
                                          border: InputBorder.none,
                                          hintText: "8:30",
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              flex: 1,
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 12),
                                decoration: BoxDecoration(
                                  color: Colors.blue[50],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: DropdownButton<String>(
                                  value: selectedAmPm,
                                  isExpanded: true,
                                  underline: SizedBox(),
                                  items: ["AM", "PM"].map((String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(value),
                                    );
                                  }).toList(),
                                  onChanged: (newValue) {
                                    setState(() {
                                      selectedAmPm = newValue!;
                                    });
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    SizedBox(height: 20),

                    // Date section
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Date",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        SizedBox(height: 8),
                        Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.blue[50],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.calendar_today, color: Colors.blue),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(formattedDate),
                              ),
                              TextButton(
                                onPressed: () => _selectDate(context),
                                child: Text(
                                  "",
                                  style: TextStyle(color: Colors.blue),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              SizedBox(height: 20),

              // Passenger details section
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildFieldLabel("First name"),
                  SizedBox(height: 8),
                  buildTextField(firstNameController),
                  SizedBox(height: 16),
                  buildFieldLabel("Last name"),
                  SizedBox(height: 8),
                  buildTextField(lastNameController),
                  SizedBox(height: 16),
                  buildFieldLabel("Age"),
                  SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: TextField(
                      controller: ageController,
                      keyboardType: TextInputType.number,
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                      onChanged: (value) => _updatePrice(),
                    ),
                  ),
                  SizedBox(height: 24),
                ],
              ),

              // Payment button - Full width with margins
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 255, 132, 0),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(30), // More rounded corners
                    ),
                    minimumSize: Size(
                        double.infinity, 56), // Full width with fixed height
                  ),
                  onPressed: () async {
                    await bookTicket(); // Book ticket first
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              UserTicketsPage()), // Navigate to TicketHistory
                    );
                  },
                  child: Text(
                    "Pay ${ticketPrice.toStringAsFixed(2)}",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildFieldLabel(String label) {
    return Text(
      label,
      style: TextStyle(
        color: Colors.white,
        fontSize: 14,
      ),
    );
  }

  Widget buildTextField(TextEditingController controller,
      {TextInputType keyboardType = TextInputType.text}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: TextStyle(color: Colors.white),
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }
}
