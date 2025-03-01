import 'package:flutter/material.dart';
import 'profile.dart';
import 'tickethistory.dart';
import 'homepage.dart';

class AppSidebar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 50),

          // Back Button
          Padding(
            padding: const EdgeInsets.only(left: 20),
            child: IconButton(
              icon: Icon(Icons.arrow_back, size: 30, color: Colors.blue),
              onPressed: () => Navigator.pop(context),
            ),
          ),

          Center(
            child: Text(
              "Menu",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
          ),

          SizedBox(height: 30),

          // Home Button
          ListTile(
            title: Center(
              child: Text(
                "Home",
                style: TextStyle(fontSize: 16, color: Colors.blue),
              ),
            ),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => HomePage()),
              );
            },
          ),

          // My Profile Button
          ListTile(
            title: Center(
              child: Text(
                "My Profile",
                style: TextStyle(fontSize: 16, color: Colors.blue),
              ),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProfilePage()),
              );
            },
          ),

          // Ticket History Button
          ListTile(
            title: Center(
              child: Text(
                "Ticket History",
                style: TextStyle(fontSize: 16, color: Colors.blue),
              ),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => TicketHistory()),
              );
            },
          ),

          SizedBox(height: 30),

          // Logout Button
          Center(
            child: ElevatedButton(
              onPressed: () {
                // Implement logout function
                print("User logged out");
                Navigator.pop(context); // Close drawer
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: EdgeInsets.symmetric(horizontal: 50, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: Text(
                "Log Out",
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
