import 'package:flutter/material.dart';
import 'package:medfast_go/business/activity.dart';
import 'package:medfast_go/business/customers.dart';
import 'package:medfast_go/business/expenses.dart';
import 'package:medfast_go/business/other_incomes.dart';
import 'package:medfast_go/business/products.dart';
import 'package:medfast_go/business/purchase_order.dart';
import 'package:medfast_go/business/reports.dart';
import 'package:medfast_go/business/representative.dart';
import 'package:medfast_go/business/sale_order.dart';
import 'package:medfast_go/business/sales.dart';
import 'package:medfast_go/business/stores.dart';
import 'package:medfast_go/business/suppliers.dart';
import 'package:medfast_go/pages/notification.dart';
import 'package:medfast_go/pages/widgets/navigation_drawer.dart';


void main() {
  runApp(MaterialApp(
    home: HomePage(),
  ));
}

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<String> tileNames = [
    'Sale Order',
    'Products',
    'Sales',
    'Reports',
    'Expenses',
    'Stores',
    'Purchase Order',
    'Supplier',
    'Activity',
    'Customers',
    'Representative',
    'Other Income',
  ];

  final List<IconData> tileIcons = [
    Icons.receipt,
    Icons.inventory_2_outlined,
    Icons.attach_money_outlined,
    Icons.analytics,
    Icons.money_off,
    Icons.store,
    Icons.shopping_cart,
    Icons.person,
    Icons.notifications_active_outlined,
    Icons.people,
    Icons.person_add_alt_1_sharp,
    Icons.monetization_on,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tala Chemist'),
        backgroundColor: Color.fromRGBO(58, 205, 50, 1),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications),
            onPressed: () {
              // Handle notification icon click here
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => NotificationsPage(),  // Navigate to the NotificationsPage
              ));
            },
          ),
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () {
              // Handle question mark icon click here
            },
          ),
        ],
      ),
      body: Container(
        color: Color.fromRGBO(58, 205, 50, 1),
        child: Padding(
          padding: const EdgeInsets.all(5.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.9,
                  ),
                  itemCount: tileNames.length,
                  itemBuilder: (context, index) {
                    return buildClickableTile(
                        context, tileNames[index], tileIcons[index]);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      drawer: Drawer(
        width: MediaQuery.of(context).size.width * 0.9,
        child: NavigationDrawerWidget(),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color.fromRGBO(58, 205, 50, 1),
        onPressed: () {
          // Handle floating action button click here
        },
        child: const Icon(Icons.add, size: 40),
      ),
    );
  }

  void navigateToDetailScreen(BuildContext context, String name) {
    switch (name) {
      case 'Sale Order':
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => SaleOrder()));
        break;
      case 'Products':
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => Products()));
        break;
      case 'Sales':
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => Sales()));
        break;
      case 'Reports':
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => Reports()));
        break;
      case 'Expenses':
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => Expenses()));
        break;
      case 'Stores':
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => Stores()));
        break;
      case 'Purchase Order':
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => PurchaseOrder()));
        break;
      case 'Supplier':
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => Supplier()));
        break;
      case 'Activity':
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => Activity()));
        break;
      case 'Customers':
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => Customers()));
        break;
      case 'Representative':
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => Representative()));
        break;
      case 'Other Income':
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => OtherIncome()));
        break;
      default:
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => HomePage()));
        break;
    }
  }

  Widget buildClickableTile(BuildContext context, String name, IconData icon) {
    return GestureDetector(
      onTap: () {
        navigateToDetailScreen(context, name);
      },
      child: Card(
        elevation: 0.2,
        color: const Color.fromRGBO(58, 205, 50, 1),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 94,
              color: Colors.white,
            ),
            const SizedBox(height: 8),
            Text(
              name,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}