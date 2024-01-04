import 'package:flutter/material.dart';


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
          ],
        ),
      ),
    );
  }
}