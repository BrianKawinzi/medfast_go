import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 16, 253, 44),
        elevation: 10.0,
        title: Row(
          children: [
            // Burger menu
            IconButton(
              onPressed: () {
                // Handle burger functionality
              },
              icon: Icon(
                Icons.menu,
                color: Colors.white,
              ),
            ),

            // Chemist name
            Text(
              'Tala Chemist',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          // Add button
          IconButton(
            onPressed: () {
              // Handle add logic here
            },
            icon: Icon(
              Icons.add,
              color: Colors.white,
            ),
          ),

          // Notifications button
          IconButton(
            onPressed: () {
              // Handle notification logic here
            },
            icon: Icon(
              Icons.notifications,
              color: Colors.white,
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Sales tile
            Card(
              elevation: 5.0,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sales',
                      style: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8.0),
                    Text(
                      'Sales Information',
                      style: TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                    SizedBox(height: 16.0),
                    // Progress Indicators
                    _buildHorizontalProgressIndicators('Current Sales', 70,
                        Colors.purple, 'Target Sales', 60, Colors.orange),
                    _buildHorizontalProgressIndicators('New Sales', 40,
                        Colors.yellow, 'Retarget Sales', 80, Colors.red),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to build circular progress indicators
  Widget _buildHorizontalProgressIndicators(String title1, int percentage1,
      Color color1, String title2, int percentage2, Color color2) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildCircularProgressIndicator(title1, percentage1, color1),
              SizedBox(width: 16.0),
              _buildCircularProgressIndicator(title2, percentage2, color2),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCircularProgressIndicator(
      String title, int percentage, Color color) {
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: 100.0,
          height: 100.0,
          child: CircularProgressIndicator(
            value: percentage / 100,
            strokeWidth: 10.0,
            valueColor: AlwaysStoppedAnimation<Color>(color),
            backgroundColor: Colors.grey[300], // Grey background
          ),
        ),
        Text(
          '$title\n$percentage%',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 16.0,
          ),
        ),
      ],
    );
  }
}
