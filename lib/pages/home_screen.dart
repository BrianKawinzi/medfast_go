import 'package:flutter/material.dart';
import 'package:medfast_go/data/DatabaseHelper.dart';
import 'package:medfast_go/models/OrderDetails.dart';
import 'package:medfast_go/models/product.dart';
import 'package:medfast_go/pages/components/circular_progress.dart';
import 'package:medfast_go/pages/widgets/CustomProgressIndicator.dart';
import 'package:medfast_go/pages/widgets/navigation_drawer.dart';
import 'package:medfast_go/bargraph/individual_bar.dart';
import 'package:medfast_go/pages/widgets/progress_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Import shared_preferences
import 'package:medfast_go/pages/notification.dart';
import 'dart:math' as math;

class HomeScreen extends StatefulWidget {
  final List<OrderDetails> completedOrders;

  const HomeScreen({super.key, required this.completedOrders});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late List<OrderDetails> _completedOrders;
  late List<int> _years = [2022, 2023, 2024, 2025, 2026, 2027];
  late int _selectedYear = 2022;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _completedOrders = widget.completedOrders;
  }

  //calculate revenue method
  Future<double> calculateTotalRevenue(int year) async {
    double totalRevenue = 0;

    for (OrderDetails order in _completedOrders) {
      if (order.completedAt.year == year) {
        totalRevenue += order.totalPrice;
      }
    }
    return totalRevenue;
  }

// Example of using the aggregated product sales in a UI component
  void displayProductSales() async {
    Map<int, int> soldQuantities =
        await DatabaseHelper().calculateTotalSoldQuantities();

    // Display or use the sold quantities in your application
    soldQuantities.forEach((productId, quantity) {
      //print("Product ID: $productId, Sold Quantity: $quantity");
    });
  }

// Fetch pharmacy name from SharedPreferences
  Future<String> getPharmacyName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('pharmacy_name') ?? 'Default Pharmacy';
  }
  Widget buildMetricCard() {
    return Card(
      elevation: 5,
      margin: const EdgeInsets.all(12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Today's! Metrics",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            FutureBuilder<double>(
              future: DatabaseHelper().getDailyProfit(DateTime.now()),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasData) {
                  return Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          CustomProgressIndicator(
                            title: "Profit",
                            value: "ksh${snapshot.data!.toStringAsFixed(0)}",
                            color: Colors.green,
                            size: 120,
                            strokeWidth: 0,
                            percentage: 0,
                          ),
                          CustomProgressIndicator(
                            title: "Items Sold",
                            value: "${snapshot.data!.toInt()} items",
                            color: Colors.blue,
                            size: 120, // Reduced size for better fit
                            strokeWidth: 0,
                            percentage: 0,
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          CustomProgressIndicator(
                            title: "Completed Orders",
                            value: "${(snapshot.data! / 10).toInt()} orders",
                            color: Colors.red,
                            size: 120, // Reduced size for better fit
                            strokeWidth: 0,
                            percentage: 0,
                          ),
                          CustomProgressIndicator(
                            title: "Expenses",
                            value: "${snapshot.data!.toStringAsFixed(0)}",
                            color: Colors.orange,
                            size: 120, // Reduced size for better fit
                            strokeWidth: 0,
                            percentage: 0,
                          ),
                        ],
                      ),
                    ],
                  );
                } else {
                  return Text('Error fetching data');
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRectangle(
      {required IconData icon, required String label, required String value}) {
    return Flexible(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 10.0),
        decoration: BoxDecoration(
          color:
              Color.fromARGB(255, 189, 187, 187), // Rectangle background color
          borderRadius: BorderRadius.circular(10), // Rounded corners
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon,
                    size: 16, color: Color.fromARGB(255, 50, 18, 80)), // Icon
                const SizedBox(width: 4), // Space between icon and label
                // Combine label and value in a single Text widget separated by \n
                Flexible(
                  // Use Flexible to prevent overflow
                  child: Text(
                    '$label\n$value', // Use \n to separate label and value
                    style: const TextStyle(
                      fontSize:
                          10, // Adjusted font size to keep consistent styling
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopProductItem({
    required String imageUrl,
    required String name,
    required int quantitySold,
    required double revenue,
  }) {
    return ListTile(
      leading: imageUrl.isNotEmpty
          ? Image.network(imageUrl, width: 50, height: 50, fit: BoxFit.cover)
          : const Icon(Icons.image_not_supported),
      title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(
          "Sold: $quantitySold, Revenue: Ksh ${revenue.toStringAsFixed(2)}"),
    );
  }

  Widget buildTopProductsSection() {
    return FutureBuilder<List<Product>>(
      future: DatabaseHelper().getBestSellingProductsDetails(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else if (snapshot.hasData) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  "Top Products",
                  style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                ),
              ),
              ...snapshot.data!
                  .map((product) => _buildTopProductItem(
                        imageUrl: product.image ?? '',
                        name: product.productName,
                        quantitySold: product.quantity,
                        revenue: product.buyingPrice,
                      ))
                  .toList(),
            ],
          );
        } else {
          return const Text("No top products found.");
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
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
          //Notification button
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => NotificationsPage()),
              );
            },
            icon: const Icon(
              Icons.notifications,
              color: Colors.white,
            ),
          ),

          //help button
          IconButton(
            onPressed: () {
              //handle help logic here
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
        child: const NavigationDrawerWidget(),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              buildMetricCard(),

          
              //revenue card
              Card(
                elevation: 5.0,
                child: Padding(
                  padding: const EdgeInsets.all(1.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total \n Revenue',
                            style: TextStyle(
                              fontSize: 16.0,
                              color: Colors.grey,
                            ),
                          ),

                          //Calculation of monthly ammounts
                          FutureBuilder<double>(
                              future: calculateTotalRevenue(_selectedYear),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return Text(
                                    'KSH \n ${snapshot.data?.toStringAsFixed(0)}',
                                    style: const TextStyle(
                                      fontSize: 18.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  );
                                } else if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const Text(
                                    'Error', 
                                    style: TextStyle(
                                      fontSize: 18.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  );
                                } else {
                                  return const Text(
                                    'Error',
                                    style: TextStyle(
                                      fontSize: 18.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  );
                                }
                              }),

                          DropdownButton<int>(
                            items: _years.map((int year) {
                              return DropdownMenuItem<int>(
                                value: year,
                                child: Text(year.toString()),
                              );
                            }).toList(),
                            onChanged: (int? newValue) {
                              //Handle dropdown value change logic
                              if (newValue != null) {
                                setState(() {
                                  _selectedYear = newValue;
                                });
                              }
                            },
                            value: _selectedYear,
                          ),
                        ],
                      ),

                      //Bar chart
                      const SizedBox(
                        height: 200,
                        child: IndividualBar(
                          x: 1,
                          monthlyAmounts: [
                            10000,
                            20000,
                            15000,
                            25000,
                            18000,
                            22000,
                            30500,
                            28000,
                            35000,
                            32000,
                            28000,
                            40000
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
              // After the last SizedBox(height: 10),

              Card(
                elevation: 5.0,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Wrap(
                          spacing: 8.0,
                          runSpacing: 8.0,
                          children: [
                            _buildRectangle(
                              icon: Icons.people,
                              label: "Customers",
                              value: "123",
                            ),
                            _buildRectangle(
                              icon: Icons.shopping_cart,
                              label: "Sales",
                              value: "456",
                            ),
                            _buildRectangle(
                              icon: Icons.money,
                              label: "Profit",
                              value: "789",
                            ),
                            _buildRectangle(
                              icon: Icons.local_shipping,
                              label: "Orders",
                              value: "101",
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 40),
                      const Text(
                        "Top Products",
                        style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      FutureBuilder<List<Product>>(
                        future: DatabaseHelper()
                            .getBestSellingProductsDetails(), // Assuming this method is defined and returns a list of Products
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                                child: CircularProgressIndicator());
                          } else if (snapshot.hasError) {
                            return Text('Error: ${snapshot.error}');
                          } else if (snapshot.hasData) {
                            return Column(
                              children: snapshot.data!
                                  .map((product) => Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 8.0),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: [
                                            Container(
                                              height: 40,
                                              width: 40,
                                              decoration: BoxDecoration(
                                                image: DecorationImage(
                                                  fit: BoxFit.cover,
                                                  image: (product.image !=
                                                              null &&
                                                          product.image!
                                                              .isNotEmpty)
                                                      ? NetworkImage(
                                                          product.image!)
                                                      : const AssetImage(
                                                              "assets/images/placeholder.png")
                                                          as ImageProvider,
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              child: Text(
                                                '${product.productName}\nSold: ${product.quantity}',
                                                style: const TextStyle(
                                                    fontSize: 14),
                                              ),
                                            ),
                                            Text(
                                              'Revenue: Ksh${(product.quantity * product.buyingPrice).toStringAsFixed(2)}',
                                              style:
                                                  const TextStyle(fontSize: 14),
                                            ),
                                          ],
                                        ),
                                      ))
                                  .toList(),
                            );
                          } else {
                            return const Text("No top products found.");
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              //stats card
              Card(
                elevation: 5.0,
                child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            //stats overview
                            const Text(
                              'Stats overview',
                              style: TextStyle(
                                fontSize: 16.0,
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            //filter button
                            IconButton(
                                onPressed: () {
                                  //Add filter functionality here
                                },
                                icon: const Icon(Icons.filter_list))
                          ],
                        ),

                        const SizedBox(height: 16.0),

                        //progress bars

                        const Text(
                          'Tracking 1',
                          style: TextStyle(
                            fontSize: 14.0,
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),

                        LinearProgressIndicator(
                          value: 0.7,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                              Color.fromARGB(255, 255, 234, 0)),
                          backgroundColor: Colors.grey,
                          minHeight: 10.0,
                          borderRadius: BorderRadius.circular(8.0),
                        ),

                        const SizedBox(height: 40.0),

                        const Text(
                          'Tracking 2',
                          style: TextStyle(
                            fontSize: 14.0,
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 4),

                        LinearProgressIndicator(
                          value: 0.4,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                              Color.fromARGB(255, 255, 17, 1)),
                          backgroundColor: Colors.grey,
                          minHeight: 10,
                          borderRadius: BorderRadius.circular(8.0),
                        ),

                        const SizedBox(height: 40.0),

                        const Text(
                          'Tracking 3',
                          style: TextStyle(
                            fontSize: 14.0,
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 4),

                        LinearProgressIndicator(
                          value: 0.7,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                              Color.fromARGB(255, 213, 0, 250)),
                          backgroundColor: Colors.grey,
                          minHeight: 10,
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ],
                    )),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
