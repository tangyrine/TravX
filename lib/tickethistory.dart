import 'package:flutter/material.dart';
import 'ticketdetails.dart';

class TicketHistory extends StatelessWidget {
  const TicketHistory({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Static ticket data
    final List<Map<String, dynamic>> tickets = [
      {
        'source': 'Mapusa',
        'destination': 'Porvorim',
        'date': '01 March 2025',
        'departureTime': '8:30 AM',
        'arrivalTime': '9:00 AM',
        'ticketPrice': 10.0,
        'busNo': 1234,
        'status': 'Completed',
        'color': const Color(0xFF2853E0),
      },
      {
        'source': 'Mapusa',
        'destination': 'Panjim',
        'date': '28 February 2025',
        'departureTime': '10:15 AM',
        'arrivalTime': '11:45 AM',
        'ticketPrice': 15.0,
        'busNo': 5678,
        'status': 'Cancelled',
        'color': Colors.red,
      },
      {
        'source': 'Margao',
        'destination': 'Panjim',
        'date': '27 February 2025',
        'departureTime': '2:00 PM',
        'arrivalTime': '4:30 PM',
        'ticketPrice': 20.0,
        'busNo': 9101,
        'status': 'Completed',
        'color': const Color(0xFF2853E0),
      },
    ];

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Ticket History"),
        centerTitle: true,
        backgroundColor: const Color(0xFF2853E0),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView.builder(
            itemCount: tickets.length,
            itemBuilder: (context, index) {
              final ticket = tickets[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: _buildTicketCard(context, ticket),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildTicketCard(BuildContext context, Map<String, dynamic> ticket) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TicketDetails(
              source: ticket['source'],
              destination: ticket['destination'],
              date: ticket['date'],
              departureTime: ticket['departureTime'],
              arrivalTime: ticket['arrivalTime'],
              ticketPrice: ticket['ticketPrice'],
              busNo: ticket['busNo'],
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Bus No: ${ticket['busNo']}",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: ticket['color'].withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          ticket['status'],
                          style: TextStyle(
                            color: ticket['color'],
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildLocationTime(
                        ticket['source'],
                        ticket['departureTime'],
                        CrossAxisAlignment.start,
                      ),
                      Column(
                        children: [
                          const Icon(
                            Icons.arrow_forward,
                            color: Colors.grey,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            ticket['date'],
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      _buildLocationTime(
                        ticket['destination'],
                        ticket['arrivalTime'],
                        CrossAxisAlignment.end,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Dashed line
            Container(
              height: 1,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: List.generate(
                  30,
                  (index) => Expanded(
                    child: Container(
                      color: index % 2 == 0
                          ? Colors.transparent
                          : Colors.grey[300],
                      height: 1,
                    ),
                  ),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(16),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Total Cost",
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    "${ticket['ticketPrice'].toInt()} Rs",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
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

  Widget _buildLocationTime(
      String location, String time, CrossAxisAlignment alignment) {
    return Column(
      crossAxisAlignment: alignment,
      children: [
        Text(
          location,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          time,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}
