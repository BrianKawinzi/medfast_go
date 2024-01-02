import 'package:flutter/material.dart';
import 'package:medfast_go/pages/home_page.dart';
import 'package:medfast_go/pages/notification.dart';
import 'package:medfast_go/pages/widgets/navigation_drawer.dart';

void main() {
  runApp(MaterialApp(
    home: DashboardPage(),
  ));
}

class DashboardPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: Colors.green, // Changed app bar color to green
      ),
      body: Stack(
        children: [
          YourExistingBodyWidget(), // Your existing body content
          Positioned(
            bottom: 80, // Adjust this value to place it according to your UI
            left: 0,
            right: 0,
            child: Center(
            ),
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
    return Center(
      child: Text(
        'Your existing body content',
        style: TextStyle(fontSize: 20),
      ),
    );
  }
}
