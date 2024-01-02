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
              child: SalesTileWidget(),
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

class SalesTileWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SalesCircle(
            color: Colors.blue,
            metric: 'Current Sales',
            percentage: '75%',
          ),
          SizedBox(height: 20),
          SalesCircle(
            color: Colors.orange,
            metric: 'Target Sales',
            percentage: '50%',
          ),
          SizedBox(height: 20),
          SalesCircle(
            color: Colors.green,
            metric: 'New Sales',
            percentage: '90%',
          ),
          SizedBox(height: 20),
          SalesCircle(
            color: Colors.red,
            metric: 'Retarget Sales',
            percentage: '30%',
          ),
        ],
      ),
    );
  }
}

class SalesCircle extends StatelessWidget {
  final Color color;
  final String metric;
  final String percentage;

  const SalesCircle({
    required this.color,
    required this.metric,
    required this.percentage,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              metric,
              style: TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              percentage,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ],
        ),
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
          ),
          child: Center(
            child: Text(
              'Sales',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
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
