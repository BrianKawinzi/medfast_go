import 'package:flutter/material.dart';
import 'package:medfast_go/business/activity.dart';
import 'package:medfast_go/business/customers.dart';
import 'package:medfast_go/business/expenses.dart';
import 'package:medfast_go/business/other_incomes.dart';
import 'package:medfast_go/business/products.dart';
import 'package:medfast_go/business/purchase_order.dart';
import 'package:medfast_go/business/representative.dart';
import 'package:medfast_go/business/sale_order.dart';
import 'package:medfast_go/business/stores.dart';
import 'package:medfast_go/business/suppliers.dart';
import 'package:medfast_go/data/DatabaseHelper.dart';
import 'package:medfast_go/pages/bottom_navigation.dart';
import 'package:medfast_go/pages/components/tile.dart';
import 'package:medfast_go/pages/widgets/navigation_drawer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:medfast_go/pages/notification.dart';

class GeneralPage extends StatelessWidget {
  const GeneralPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    checkTwoDaysExpiryNotifications();
    return Scaffold(
      backgroundColor: Colors.grey[300],
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
            onPressed: () {},
            icon: const Icon(
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
          GestureDetector(
            onTap: () => navigateToPage(context, "Products"),
            child: buildTile("Products", Icons.shopping_bag),
          ),
          GestureDetector(
            onTap: () => navigateToPage(context, "Expenses"),
            child: buildTile("Expenses", Icons.money_off),
          ),
          GestureDetector(
            onTap: () => navigateToPage(context, "Stores"),
            child: buildTile("Stores", Icons.store),
          ),
          GestureDetector(
            onTap: () => navigateToPage(context, "Purchase Order"),
            child: buildTile("Purchase Order", Icons.shopping_cart),
          ),
          GestureDetector(
            onTap: () => navigateToPage(context, "Supplier"),
            child: buildTile("Supplier", Icons.person),
          ),
          GestureDetector(
            onTap: () => navigateToPage(context, "Activity"),
            child: buildTile("Activity", Icons.notifications_active_outlined),
          ),
          GestureDetector(
            onTap: () => navigateToPage(context, "Customers"),
            child: buildTile("Customers", Icons.people),
          ),
          GestureDetector(
            onTap: () => navigateToPage(context, "Representative"),
            child: buildTile("Representative", Icons.person_add_alt_1_sharp),
          ),
          GestureDetector(
            onTap: () => navigateToPage(context, "Sale History"),
            child: buildTile("Sale History", Icons.receipt),
          ),
          GestureDetector(
            onTap: () => navigateToPage(context, "Other Income"),
            child: buildTile("Other Income", Icons.monetization_on),
          ),
        ],
      ),
    );
  }
}

Future<String> getPharmacyName() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('pharmacy_name') ?? 'Default Pharmacy';
}

void navigateToPage(BuildContext context, String pageTitle) {
  switch (pageTitle) {
    case 'Products':
      Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => const Products(productName: '')));
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
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (context) => const PurchaseOrder()));
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
