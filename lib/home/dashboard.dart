// dashboard.dart
import 'package:flutter/material.dart';

class DashboardPage extends StatelessWidget {
  final String userEmail;

  const DashboardPage({required this.userEmail});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard'),
      ),
      body: Container(
        color: Colors.blueGrey,
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome, $userEmail!', // Display user's email
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            // Add more widgets as needed for the dashboard
          ],
        ),
      ),
    );
  }
}
