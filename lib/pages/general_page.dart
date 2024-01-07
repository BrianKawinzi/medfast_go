import 'package:flutter/material.dart';
import 'package:medfast_go/pages/components/tile.dart';
import 'package:medfast_go/pages/widgets/navigation_drawer.dart';


class GeneralPage extends StatelessWidget {
  const GeneralPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 16, 253, 44),
        elevation: 10.0,
        title: Row(

          children: [
            Padding(
              padding: const EdgeInsets.only(right: 13),
              child: Text(
                'Tala Chemist',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            
          ),
          ],
        ),

        actions: [

          IconButton(
            onPressed: () {

            }, 
            icon: Icon(
              Icons.notifications,
              color: Colors.white,
            ),
          ),

           IconButton(
            onPressed: () {

            }, 
            icon: Icon(
              Icons.help_outline_rounded,
              color: Colors.white,
            ),
          ),

          
        ],
      ),
      drawer: Drawer(
        width: MediaQuery.of(context).size.width * 0.9,
        child: const NavigationDrawerWidget(),
      ),
      body: GridView.count(
        crossAxisCount: 2,
        children: [
          buildTile("sales"),
          buildTile("Expenses"),
          buildTile("Stores"),
          buildTile("Purchase Order"),
          buildTile("Supplier"),
          buildTile("Activity"),
          buildTile("Customers"),
          buildTile("Representative"),
          buildLongTile("Other Income", context)
        ],
      ),
    );
  }
}