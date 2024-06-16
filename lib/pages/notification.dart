import 'dart:io';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:medfast_go/data/DatabaseHelper.dart';
import 'package:medfast_go/pages/bottom_navigation.dart';
import 'package:medfast_go/models/product.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationItem {
  String message;
  DateTime timestamp;
  bool read; // Added read status

  NotificationItem({
    required this.message,
    required this.timestamp,
    this.read = false, // Default read status is false
  });
}

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({Key? key}) : super(key: key);

  @override
  _NotificationsPageState createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  bool showAllNotifications = true;
  List<NotificationItem> expiredProductNotifications = [];
  List<Product> products = [];
  String? _deletedNotification;
  Set<String> readNotifications = {}; // Changed to store message strings

  @override
  void initState() {
    super.initState();
    _fetchProducts();
    checkExpiredProducts();
    checkProductQuantities();
    _loadReadNotifications();
  }

  Future<void> _fetchProducts() async {
    final dbHelper = DatabaseHelper();
    final fetchedProducts = await dbHelper.getProducts();
    setState(() {
      products = fetchedProducts;
    });
  }

  Future<void> checkExpiredProducts() async {
    final dbHelper = DatabaseHelper();
    final allProducts = await dbHelper.getProducts();

    setState(() {
      expiredProductNotifications.clear();
    });

    final currentDate = DateTime.now();
    final twoWeeksFromNow = DateTime.now().add(Duration(days: 14));
    final oneWeekFromNow = DateTime.now().add(Duration(days: 7));
    final twoDaysFromNow = DateTime.now().add(Duration(days: 2));
    final oneMonthFromNow = DateTime.now().add(Duration(days: 30));

    for (var product in allProducts) {
      final expiryDate = DateTime.parse(product.expiryDate);
      if (expiryDate.isBefore(currentDate)) {
        setState(() {
          expiredProductNotifications.add(NotificationItem(
            message: '${product.productName} has expired on ${product.expiryDate}',
            timestamp: DateTime.now(),
            read: readNotifications.contains('${product.productName} has expired on ${product.expiryDate}'),
          ));
        });
      } else if (expiryDate.isAfter(currentDate) && expiryDate.isBefore(twoDaysFromNow)) {
        setState(() {
          expiredProductNotifications.add(NotificationItem(
            message: '${product.productName} will expire in 2 days',
            timestamp: DateTime.now(),
            read: readNotifications.contains('${product.productName} will expire in 2 days'),
          ));
        });
      } else if (expiryDate.isAfter(currentDate) && expiryDate.isBefore(oneWeekFromNow)) {
        setState(() {
          expiredProductNotifications.add(NotificationItem(
            message: '${product.productName} will expire in 1 week',
            timestamp: DateTime.now(),
            read: readNotifications.contains('${product.productName} will expire in 1 week'),
          ));
        });
      } else if (expiryDate.isAfter(currentDate) && expiryDate.isBefore(twoWeeksFromNow)) {
        setState(() {
          expiredProductNotifications.add(NotificationItem(
            message: '${product.productName} will expire in 2 weeks',
            timestamp: DateTime.now(),
            read: readNotifications.contains('${product.productName} will expire in 2 weeks'),
          ));
        });
      } else if (expiryDate.isAfter(currentDate) && expiryDate.isBefore(oneMonthFromNow)) {
        setState(() {
          expiredProductNotifications.add(NotificationItem(
            message: '${product.productName} will expire in one month',
            timestamp: DateTime.now(),
            read: readNotifications.contains('${product.productName} will expire in one month'),
          ));
        });
      }
    }

    sortNotifications(); // Sort notifications after adding
  }

  Future<void> checkProductQuantities() async {
    final dbHelper = DatabaseHelper();
    final allProducts = await dbHelper.getProducts();

    for (var product in allProducts) {
      if (product.quantity <= 10) {
        addLowStockNotification(product);
      }
    }
  }

  void addLowStockNotification(Product product) {
    final notificationMessage = 'Running low on ${product.productName}';
    final notification = NotificationItem(
      message: notificationMessage,
      timestamp: DateTime.now(),
      read: false,
    );

    setState(() {
      expiredProductNotifications.insert(0, notification);
    });
  }

  void sortNotifications() {
    expiredProductNotifications.sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  Future<void> _loadReadNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final readNotificationsList = prefs.getStringList('readNotifications') ?? [];
    setState(() {
      readNotifications = readNotificationsList.toSet(); // Convert to set of message strings
    });
  }

  Future<void> _saveReadNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final readNotificationsList = readNotifications.toList(); // Convert set to list of message strings
    await prefs.setStringList('readNotifications', readNotificationsList);
  }

  void _markAllAsRead() {
    setState(() {
      expiredProductNotifications.forEach((notification) {
        notification.read = true;
        readNotifications.add(notification.message);
      });
    });
    _saveReadNotifications();
  }

  Widget _buildNotificationsList() {
    return ListView.builder(
      itemCount: expiredProductNotifications.length,
      itemBuilder: (context, index) {
        var notification = expiredProductNotifications[index];
        Color backgroundColor;
        Color textColor = Colors.white;

        if (notification.message.contains("will expire in 2 days")) {
          backgroundColor = Colors.brown;
        } else if (notification.message.contains("will expire in 1 week")) {
          backgroundColor = Colors.grey[800]!;
        } else if (notification.message.contains("will expire in 2 weeks")) {
          backgroundColor = Colors.blue[900]!;
        } else if (notification.message.contains("will expire in one month")) {
          backgroundColor = Colors.blue[200]!;
        } else if (notification.message.contains("Running low on")) {
          backgroundColor = Colors.orange;
        } else {
          backgroundColor = Colors.red;
        }

        if (notification.read) {
          backgroundColor = Colors.grey;
        }

        var product = products.firstWhereOrNull((p) => notification.message.contains(p.productName));
        var imageFile = product != null && product.image != null ? File(product.image!) : null;

        return GestureDetector(
          onTap: () {
            if (notification.message.contains("Running low on")) {
              _showProductQuantityDialog(context, product, notification);
            } else {
              _showExpiryDateDialog(context, notification);
            }
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            child: Container(
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: ListTile(
                leading: ClipOval(
                  child: Container(
                    color: Colors.white,
                    child: SizedBox(
                      width: 35,
                      height: 35,
                      child: imageFile != null && imageFile.existsSync()
                          ? Image.file(
                              imageFile,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(Icons.error);
                              },
                            )
                          : Image.asset('lib/assets/noimage.png', fit: BoxFit.cover),
                    ),
                  ),
                ),
                title: Text(
                  notification.message,
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
      _deletedNotification = expiredProductNotifications[index].message;
      if (index >= 0 && index < expiredProductNotifications.length) {
        expiredProductNotifications.removeAt(index);
      }
    });

    final dbHelper = DatabaseHelper();
    await dbHelper.deleteNotification(_deletedNotification!);

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text("Notification deleted"),
      action: SnackBarAction(
        label: "Undo",
        onPressed: () {
          setState(() {
            expiredProductNotifications.insert(
              index,
              NotificationItem(
                message: _deletedNotification!,
                timestamp: DateTime.now(),
              ),
            );
            _deletedNotification = null;
          });
        },
      ),
    ));
  }

  void _showProductQuantityDialog(BuildContext context, Product? product, NotificationItem notification) {
    if (product == null) return;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Product Details'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Product Name: ${product.productName}'),
              Text('Quantity in Stock: ${product.quantity}'),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text("OK"),
              onPressed: () {
                setState(() {
                  notification.read = true; // Mark notification as read
                  readNotifications.add(notification.message); // Add message to read notifications
                });
                _saveReadNotifications();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showExpiryDateDialog(BuildContext context, NotificationItem notification) {
    String expiryDate = notification.message.split(' on ')[1];
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
                setState(() {
                  notification.read = true; // Mark notification as read
                  readNotifications.add(notification.message); // Add message to read notifications
                });
                _saveReadNotifications();
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
            padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
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
                            fontWeight: showAllNotifications ? FontWeight.bold : FontWeight.normal,
                            color: showAllNotifications ? Theme.of(context).primaryColor : Colors.grey,
                          ),
                        ),
                        Container(
                          width: 24.0,
                          height: 2.0,
                          color: showAllNotifications ? Theme.of(context).primaryColor : Colors.transparent,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        showAllNotifications = false;
                        _markAllAsRead();
                      });
                    },
                    child: Column(
                      children: [
                        Text(
                          'Mark all as read',
                          style: TextStyle(
                            fontWeight: !showAllNotifications ? FontWeight.bold : FontWeight.normal,
                            color: !showAllNotifications ? Theme.of(context).primaryColor : Colors.grey,
                          ),
                        ),
                        Container(
                          width: 80.0,
                          height: 2.0,
                          color: !showAllNotifications ? Theme.of(context).primaryColor : Colors.transparent,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: _buildNotificationsList(),
          ),
        ],
      ),
    );
  }
}
