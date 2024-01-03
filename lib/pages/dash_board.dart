import 'package:flutter/material.dart';
import 'package:medfast_go/pages/home_page.dart';
import 'package:medfast_go/pages/widgets/navigation_drawer.dart';

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
            // IconButton(
            //   onPressed: () {
            //     // Handle burger functionality
            //   },
            //   icon: Icon(
            //     Icons.menu,
            //     color: Colors.white,
            //   ),
            // ),

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
      body: Stack(
        children: [
          YourExistingBodyWidget(), // Your existing body content
          Positioned(
            bottom: 80, // Adjust this value to place it according to your UI
            left: 0,
            right: 0,
            child: Center(),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              color: Colors.grey[200], // Grey background for bottom navigation
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  // Bottom navigation buttons with text below icons
                  Column(
                    children: [
                      IconButton(
                        onPressed: () {
                          // Handle left button click
                        },
                        icon: Icon(
                          Icons.dashboard,
                          color: Colors.blue,
                          size: 37,
                        ),
                      ),
                      Text(
                        'Dashboard',
                        style: TextStyle(color: Colors.black),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      IconButton(
                        onPressed: () {
                          // Handle button click to navigate to General screen
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => HomePage(),
                          ));
                        },
                        icon: Icon(
                          Icons.grid_view,
                          color: Colors.black,
                          size: 37,
                        ),
                      ),
                      Text(
                        'General',
                        style: TextStyle(color: Colors.black),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      IconButton(
                        onPressed: () {
                          // Handle right button click
                        },
                        icon: Icon(
                          Icons.group,
                          color: Color.fromARGB(255, 3, 145, 8),
                          size: 37,
                        ),
                      ),
                      Text(
                        'Employees',
                        style: TextStyle(color: Colors.black),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      drawer: Drawer(
        width: MediaQuery.of(context).size.width * 0.9,
        child: const NavigationDrawerWidget(),
      ),
    );
  }
}

class YourExistingBodyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
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
        ],
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
          _buildCircularProgressIndicator(title1, percentage1, color1),
          SizedBox(width: 16.0),
          _buildCircularProgressIndicator(title2, percentage2, color2),
        ],
      ),
    );
  }

  // Helper method to build circular progress indicators
  Widget _buildCircularProgressIndicator(
    String title,
    int percentage,
    Color color,
  ) {
    return Column(
      children: [
        Stack(
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
              '$percentage%',
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 16.0,
              ),
            ),
          ],
        ),
        SizedBox(height: 8.0),
        Text(
          title,
          style: TextStyle(
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}
