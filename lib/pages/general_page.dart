import 'package:flutter/material.dart';
import 'package:medfast_go/business/activity.dart';
import 'package:medfast_go/business/customers.dart';
import 'package:medfast_go/business/expenses.dart';
import 'package:medfast_go/business/other_incomes.dart';
import 'package:medfast_go/business/purchase_order.dart';
import 'package:medfast_go/business/representative.dart';
import 'package:medfast_go/business/sale_order.dart';
import 'package:medfast_go/business/stores.dart';
import 'package:medfast_go/business/suppliers.dart';
import 'package:medfast_go/data/DatabaseHelper.dart';
import 'package:medfast_go/pages/bottom_navigation.dart';
import 'package:medfast_go/pages/widgets/navigation_drawer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:medfast_go/pages/notification.dart';
import 'package:medfast_go/pages/faq.dart';

class GeneralPage extends StatelessWidget {
  GeneralPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    checkTwoDaysExpiryNotifications();
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 207, 210, 207),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 16, 253, 44),
        elevation: 10.0,
        title: FutureBuilder<String>(
          future: getPharmacyName(), // Fetch pharmacy name dynamically
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return Text(
                snapshot.data!,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              );
            }
            // Display a placeholder or loading indicator as needed
            return const CircularProgressIndicator(
              color: Colors.white,
            );
          },
        ),
        actions: [
          Stack(
            children: [
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const NotificationsPage(),
                    ),
                  );
                },
                icon: const Icon(
                  Icons.notifications,
                  color: Colors.white,
                ),
              ),
              if (hasTwoDaysExpiryNotification)
                Positioned(
                  right: 14,
                  top: 11,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 10,
                      minHeight: 10,
                    ),
                  ),
                ),
            ],
          ),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const FAQ()),
              );
            },
            icon: const Icon(
              Icons.help_outline_rounded,
              color: Colors.white,
            ),
          ),
        ],
      ),
      drawer: Drawer(
        width: MediaQuery.of(context).size.width * 0.9,
        child:  NavigationDrawerWidget(),
      ),
      body: GridView.count(
        crossAxisCount: 2,
        children: [
          buildTile(context, "Expenses", Icons.money_off, false),
          buildTile(context, "Stores", Icons.store, true),
          buildTile(context, "Purchase Order", Icons.shopping_cart, true),
          buildTile(context, "Supplier", Icons.person, true),
          buildTile(
              context, "Activity", Icons.notifications_active_outlined, false),
          buildTile(context, "Customers", Icons.people, false),
          buildTile(
              context, "Manage Employee", Icons.person_add_alt_1_sharp, true),
          buildTile(context, "Sale History", Icons.receipt, false),
          buildTile(context, "Other Income", Icons.monetization_on, true),
        ],
      ),
    );
  }

  Widget buildTile(
      BuildContext context, String title, IconData icon, bool isPremium) {
    return GestureDetector(
      onTap: isPremium ? null : () => navigateToPage(context, title),
      child: Stack(
        children: [
          buildTileContent(title, icon),
          if (isPremium)
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(4),
                color: const Color.fromARGB(255, 227, 205, 116),
                child: const Text(
                  'Premium',
                  style: TextStyle(
                    color: Color.fromARGB(255, 1, 1, 1),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget buildTileContent(String title, IconData icon) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 50.0),
            Text(
              title,
              style:
                  const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Future<String> getPharmacyName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('pharmacy_name') ?? 'Default Pharmacy';
  }

  void navigateToPage(BuildContext context, String pageTitle) {
    switch (pageTitle) {
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
        Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const BottomNavigation()));
    }
  }

  bool hasTwoDaysExpiryNotification = false;

  Future<void> checkTwoDaysExpiryNotifications() async {
    final dbHelper = DatabaseHelper();
    final products = await dbHelper.getProducts();

    final twoDaysFromNow = DateTime.now().add(const Duration(days: 2));
    for (var product in products) {
      final expiryDate = DateTime.parse(product.expiryDate);
      if (expiryDate.isBefore(twoDaysFromNow)) {
        hasTwoDaysExpiryNotification = true;
        return;
      }
    }

    hasTwoDaysExpiryNotification = false;
  }
}
