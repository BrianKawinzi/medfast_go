import 'package:flutter/material.dart';
import 'package:medfast_go/pages/widgets/progress_indicator.dart';


class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
  });


  

  


  //calculate revenue method
  Future<double> calculateTotalRevenue() async {
    double totalRevenue = 0;

    List<double> monthlyAmounts = [10000, 20000, 15000, 25000, 18000, 22000, 30500, 28000, 35000, 32000, 28000, 40000];
    
    for (double amount in monthlyAmounts) {
      totalRevenue += amount;
    }

    return totalRevenue;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 16, 253, 44),
        elevation: 10.0,
        title: Row(
          children: [
            //Burger menu
            IconButton(
              onPressed: () {
                //Handle burger functionality
              }, 
              icon: Icon(
                Icons.menu,
                color: Colors.white,
              ),
            ),

            //chemist name this is an example later on it will be connected so as to change with the specific chemist
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

          //Notification button
          IconButton(
            onPressed: () {
              //Handle notification logic here
            }, 
            icon: Icon(
              Icons.notifications,
              color: Colors.white,
            ),
          ),

          //help button
          IconButton(
            onPressed: () {
              //handle help logic here
            }, 
            icon: Icon(
              Icons.help_outline_rounded,
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

              //sales tile
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

                      const SizedBox(height: 8.0),

                      Text(
                        'Sales Infromation',
                        style: TextStyle(
                          color: Colors.grey,
                        ),
                      ),

                      const SizedBox(height: 16.0),

                      //Progress indicators
                      buildHorizontalProgressIndicators(
                        'Daily Sales',
                         70, 
                         Colors.purple, 
                         'Monthly Sales', 
                         59, 
                         Colors.orange,
                      ),

                      buildHorizontalProgressIndicators(
                        'Annual Sales',
                         43, 
                         Colors.yellow, 
                         'Target Sales', 
                         87, 
                         Colors.orange,
                      ),
                      
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}