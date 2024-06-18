import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medfast_go/controllers/authentication_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:medfast_go/business/activity.dart';
import 'package:medfast_go/business/customers.dart';
import 'package:medfast_go/business/expenses.dart';
import 'package:medfast_go/business/other_incomes.dart';
import 'package:medfast_go/business/products/products.dart';
import 'package:medfast_go/business/purchase_order.dart';
import 'package:medfast_go/business/reports/reports.dart';
import 'package:medfast_go/business/representative.dart';
import 'package:medfast_go/business/sale_order.dart';
import 'package:medfast_go/business/sales.dart';
import 'package:medfast_go/business/stores.dart';
import 'package:medfast_go/business/suppliers.dart';
import 'package:medfast_go/pages/notification.dart';
import 'package:medfast_go/pages/widgets/navigation_drawer.dart';

void main() {
  runApp(const MaterialApp(
    home: HomePage(),
  ));
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final AuthenticationController authenticationController = Get.find();
  final List<String> tileNames = [
    'Sales',
    'Products',
    'Reports',
    'Expenses',
    'Stores',
    'Purchase Order',
    'Supplier',
    'Activity',
    'Customers',
    'Representative',
    'Sale History',
    'Other Income',
  ];

  final List<IconData> tileIcons = [
    Icons.attach_money_outlined,
    Icons.inventory_2_outlined,
    Icons.analytics,
    Icons.money_off,
    Icons.store,
    Icons.shopping_cart,
    Icons.person,
    Icons.notifications_active_outlined,
    Icons.people,
    Icons.person_add_alt_1_sharp,
    Icons.receipt,
    Icons.monetization_on,
  ];

  Future<String> getPharmacyName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('pharmacy_name') ?? 'Default Pharmacy';
  }

  int getCrossAxisCount(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth > 1200) {
      return 4; // large screen
    } else if (screenWidth > 600) {
      return 3; // medium screen
    } else {
      return 2; // small screen
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: FutureBuilder<String>(
          future: getPharmacyName(),
          builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
            return Text(snapshot.hasData ? snapshot.data! : 'Loading...');
          },
        ),
        backgroundColor: const Color.fromRGBO(58, 205, 50, 1),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const NotificationsPage()));
            },
          ),
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () {
              // Define help action
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: getCrossAxisCount(context),
            childAspectRatio: 1.0,
            crossAxisSpacing: 20,
            mainAxisSpacing: 20,
          ),
          itemCount: tileNames.length,
          itemBuilder: (context, index) {
            return Card(
              color: Colors.white,
              elevation: 5,
              child: InkWell(
                onTap: () {
                  // Implement onTap functionality based on the item
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(tileIcons[index],
                        size: 48, color: Theme.of(context).primaryColor),
                    const SizedBox(height: 10),
                    Text(
                      tileNames[index],
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      drawer: Drawer(
        width: MediaQuery.of(context).size.width * 0.9,
        child: const NavigationDrawerWidget(),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color.fromRGBO(58, 205, 50, 1),
        onPressed: () {
          // Implement FAB action
        },
        child: const Icon(Icons.add, size: 40),
      ),
    );
  }

  void navigateToDetailScreen(BuildContext context, String name) {
    switch (name) {
      case 'Sales':
        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => const Sales(
                  initialProducts: [],
                )));
        break;
      case 'Products':
        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => const Products(
                  productName: '',
                )));
        break;
      case 'Reports':
        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => const Reports(
                  products: [],
                )));
        break;
      case 'Expenses':
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => const Expenses()));
        break;
      case 'Stores':
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => const Stores()));
        break;
      case 'Purchase Order':
        Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const PurchaseOrder()));
        break;
      case 'Supplier':
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => Supplier()));
        break;
      case 'Activity':
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => const Activity()));
        break;
      case 'Customers':
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => const Customers()));
        break;
      case 'Representative':
        Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const Representative()));
        break;
      case 'Other Income':
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => OtherIncome()));
        break;
      case 'Sale History':
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) =>
              const SaleOrder(), // No need to pass orderDetails if it's optional
        ));
        break;
      default:
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => const HomePage()));
        break;
    }
  }

  Widget buildClickableTile(BuildContext context, String name, IconData icon) {
    return GestureDetector(
      onTap: () {
        navigateToDetailScreen(context, name);
      },
      child: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Card(
          elevation: 0,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
      ),
    );
  }
}
