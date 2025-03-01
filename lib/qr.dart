import 'package:flutter/material.dart';
import 'ticketdetails.dart';

class QRPage extends StatelessWidget {
  final String source;
  final String destination;
  final String date;
  final String departureTime;
  final String arrivalTime;
  final double ticketPrice;
  final int busNo;

  const QRPage({
    Key? key,
    required this.source,
    required this.destination,
    required this.date,
    required this.departureTime,
    required this.arrivalTime,
    required this.ticketPrice,
    required this.busNo,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2853E0),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2853E0),
        title: const Text("QR Code Payment"),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Scan the code and pay",
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            const SizedBox(height: 20),
            Image.asset(
              'assets/qr.png',
              width: 200,
              height: 200,
              errorBuilder: (context, error, stackTrace) {
                return Text('Error loading image: $error');
              },
            ), // Replace with actual QR code
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TicketDetails(
                      source: source,
                      destination: destination,
                      date: date,
                      departureTime: departureTime,
                      arrivalTime: arrivalTime,
                      ticketPrice: ticketPrice,
                      busNo: busNo,
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30)),
              ),
              child: const Text("View Ticket",
                  style: TextStyle(color: Colors.white, fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }
}
