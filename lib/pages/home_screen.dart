import 'package:flutter/material.dart';
import 'package:medfast_go/pages/widgets/circular_progress_indicator.dart';

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
      body: SingleChildScrollView(
        child: Padding(
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
                      _buildHorizontalProgressIndicators(
                        'Current Sales',
                        70,
                        Colors.purple,
                        'Target Sales',
                        60,
                        Colors.orange,
                      ),
                      _buildHorizontalProgressIndicators(
                        'New Sales',
                        40,
                        Colors.yellow,
                        'Retarget Sales',
                        80,
                        Colors.red,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 10),
      
              //revenue card
              Card(
                elevation: 5.0,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total \n Revenue',
                            style: TextStyle(
                              fontSize: 16.0,
                              color: Colors.grey,
                            ),
                          ),

                          Text(
                            'KSH \n 4,200,000',
                            style: TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          DropdownButton<String>(
                            items: <String>['2022', '2023', '2024', '2025', '2026', '2027']
                              .map((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(), 
                            onChanged: (String? newValue) {
                              //Handle dropdown value change logic
                            },
                            value: '2022',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              )
              
            ],
          ),
        ),
      ),
    );
  }

  // Helper method to build horizontal progress indicators
  Widget _buildHorizontalProgressIndicators(
    String title1,
    int percentage1,
    Color color1,
    String title2,
    int percentage2,
    Color color2,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          MyCircularProgressIndicator(title: title1, percentage: percentage1, color: color1),
          SizedBox(width: 16.0),
          MyCircularProgressIndicator(title: title2, percentage: percentage2, color: color2),
        ],
      ),
    );
  }
}
