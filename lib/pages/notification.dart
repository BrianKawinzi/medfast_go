import 'dart:io';
import 'package:flutter/material.dart';
import 'package:medfast_go/data/DatabaseHelper.dart'; // Import DatabaseHelper to use its methods
import 'package:medfast_go/pages/bottom_navigation.dart';
import 'package:medfast_go/models/product.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({Key? key}) : super(key: key);

  @override
  _NotificationsPageState createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  bool showAllNotifications = true;
  List<String> expiredProductNotifications =
      []; // Store expired product notifications
  // List to store products
  List<Product> products = [];
  // Variable to store the deleted notification temporarily
  String? _deletedNotification;

  // Function to fetch products from the database
  Future<void> _fetchProducts() async {
    final dbHelper = DatabaseHelper();
    final fetchedProducts = await dbHelper.getProducts();
    setState(() {
      products = fetchedProducts;
    });
  }

  // Function to check for expired products and generate notifications
  Future<void> checkExpiredProducts() async {
    final dbHelper = DatabaseHelper();
    final allProducts = await dbHelper.getProducts();

    // Clear previous notifications
    setState(() {
      expiredProductNotifications.clear();
    });

    // Check each product for expiry
    final currentDate = DateTime.now();
    final twoWeeksFromNow = DateTime.now().add(Duration(days: 14));
    final oneWeekFromNow = DateTime.now().add(Duration(days: 7));
    final twoDaysFromNow = DateTime.now().add(Duration(days: 2));
    final oneMonthFromNow = DateTime.now().add(Duration(days: 30));
    for (var product in allProducts) {
      final expiryDate = DateTime.parse(product.expiryDate);
      if (expiryDate.isBefore(currentDate)) {
        // Product has expired, add notification in red
        setState(() {
          expiredProductNotifications.add(
            '${product.productName} has expired on ${product.expiryDate}',
          );
        });
      } else if (expiryDate.isAfter(currentDate) &&
          expiryDate.isBefore(twoDaysFromNow)) {
        // Product is expiring in 2 days, add notification in red
        setState(() {
          expiredProductNotifications.add(
            '${product.productName} will expire in 2 days',
          );
        });
      } else if (expiryDate.isAfter(currentDate) &&
          expiryDate.isBefore(oneWeekFromNow)) {
        // Product is expiring in 1 week, add notification in red
        setState(() {
          expiredProductNotifications.add(
            '${product.productName} will expire in 1 week',
          );
        });
      } else if (expiryDate.isAfter(currentDate) &&
          expiryDate.isBefore(twoWeeksFromNow)) {
        // Product is expiring in 2 weeks, add notification in brown
        setState(() {
          expiredProductNotifications.add(
            '${product.productName} will expire in 2 weeks',
          );
        });
      } else if (expiryDate.isAfter(currentDate) &&
          expiryDate.isBefore(oneMonthFromNow)) {
        // Product is expiring in one month, add notification in brown
        setState(() {
          expiredProductNotifications.add(
            '${product.productName} will expire in one month',
          );
        });
      }
    }
  }

  // Call checkExpiredProducts() in initState() to check for expired products when the page is loaded
  @override
  void initState() {
    super.initState();
    _fetchProducts();
    checkExpiredProducts();
  }

  Widget _buildNotificationsList() {
    return ListView.builder(
      itemCount: expiredProductNotifications.length,
      itemBuilder: (context, index) {
        // Check if the notification contains specific strings to determine expiration duration
        final isTwoDays = expiredProductNotifications[index]
            .contains("will expire in 2 days");
        final isOneWeek = expiredProductNotifications[index]
            .contains("will expire in 1 week");
        final isTwoWeeks = expiredProductNotifications[index]
            .contains("will expire in 2 weeks");
        final isOneMonth = expiredProductNotifications[index]
            .contains("will expire in one month");

        // Determine the background color and text color based on expiration duration
        Color backgroundColor;
        Color textColor = Colors.white;

        if (isTwoDays) {
          backgroundColor =
              Colors.brown; // Products expiring in 2 days - brown color
        } else if (isOneWeek) {
          backgroundColor = Colors
              .grey[800]!; // Products expiring in 1 week - dark grey color
        } else if (isTwoWeeks) {
          backgroundColor = Colors
              .blue[900]!; // Products expiring in 2 weeks - navy blue color
        } else if (isOneMonth) {
          backgroundColor = Colors
              .blue[200]!; // Products expiring in 1 month - light blue color
        } else {
          backgroundColor = Colors.red; // Default color for expired products
        }

        // Extract the image file path from the product if available
        var product = products[index];
        var imageFile = File(product.image ?? '');

        return GestureDetector(
          onTap: () {
            _showExpiryDateDialog(context, product.expiryDate);
          }, // Show the expiry date dialog on tap
          child: Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            child: Container(
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: ListTile(
                leading: ClipOval(
                  child: Container(
                    color: Colors.white, // Set the background color to white
                    child: SizedBox(
                      width: 35, // Adjust width as needed
                      height: 35, // Adjust height as needed
                      child: imageFile.existsSync()
                          ? Image.file(
                              imageFile,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(Icons.error);
                              },
                            )
                          : const Placeholder(), // Display a placeholder if no image is available
                    ),
                  ),
                ),
                title: Text(
                  expiredProductNotifications[index],
                  style: TextStyle(
                    color: textColor,
                  ),
                ),
                trailing: IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () async {
                    await _deleteNotification(index);
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _deleteNotification(int index) async {
    setState(() {
      // Store the deleted notification temporarily
      _deletedNotification = expiredProductNotifications[index];
      // Check if the index is within the bounds of the list
      if (index >= 0 && index < expiredProductNotifications.length) {
        expiredProductNotifications.removeAt(index);
      }
    });

    // Remove the notification from the database as well
    final dbHelper = DatabaseHelper();
    // Here, you need to implement a method in DatabaseHelper to delete the notification based on its content
    await dbHelper.deleteNotification(_deletedNotification!);

    // Show a Snackbar with an "Undo" action
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text("Notification deleted"),
      action: SnackBarAction(
        label: "Undo",
        onPressed: () {
          // Restore the deleted notification if "Undo" is clicked
          setState(() {
            expiredProductNotifications.add(_deletedNotification!);
            _deletedNotification = null; // Clear the temporary variable
          });
        },
      ),
    ));
  }

  // Function to show a dialog with the expiry date
  void _showExpiryDateDialog(BuildContext context, String expiryDate) {
    // Check if the expiry date has passed
    final isExpired = DateTime.parse(expiryDate).isBefore(DateTime.now());

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Expiry Date"),
          content: isExpired
              ? Text("This product expired on: $expiryDate")
              : Text("This product will expire on: $expiryDate"),
          actions: <Widget>[
            TextButton(
              child: Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        centerTitle: true,
        backgroundColor: const Color.fromRGBO(58, 205, 50, 1),
        leading: GestureDetector(
          onTap: () {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => const BottomNavigation(),
              ),
            );
          },
          child: const Icon(Icons.arrow_back),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        showAllNotifications = true;
                      });
                    },
                    child: Column(
                      children: [
                        Text(
                          'All',
                          style: TextStyle(
                            fontWeight: showAllNotifications
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: showAllNotifications
                                ? Theme.of(context).primaryColor
                                : Colors.grey,
                          ),
                        ),
                        Container(
                          width: 24.0, // Adjust as needed
                          height: 2.0,
                          color: showAllNotifications
                              ? Theme.of(context).primaryColor
                              : Colors.transparent,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        showAllNotifications = false;
                      });
                    },
                    child: Column(
                      children: [
                        Text(
                          'Mark all as read',
                          style: TextStyle(
                            fontWeight: !showAllNotifications
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: !showAllNotifications
                                ? Theme.of(context).primaryColor
                                : Colors.grey,
                          ),
                        ),
                        Container(
                          width: 80.0, // Adjust as needed
                          height: 2.0,
                          color: !showAllNotifications
                              ? Theme.of(context).primaryColor
                              : Colors.transparent,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          // Display expired product notifications
          Expanded(
            child: _buildNotificationsList(),
          ),
        ],
      ),
    );
  }
}
