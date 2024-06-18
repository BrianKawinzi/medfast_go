import 'dart:io';
import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:medfast_go/business/sales.dart';
import 'package:medfast_go/data/DatabaseHelper.dart';
import 'package:medfast_go/models/OrderDetails.dart';
import 'package:medfast_go/models/product.dart';
import 'package:medfast_go/pages/profile.dart';
import 'package:medfast_go/pages/widgets/navigation_drawer.dart';
import 'package:medfast_go/pages/widgets/revenue_card.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Import shared_preferences
import 'package:medfast_go/pages/notification.dart';
import 'dart:math' as math;
import 'package:medfast_go/pages/faq.dart';
import 'package:fl_chart/fl_chart.dart' as fl;

class HomeScreen extends StatefulWidget {
  final List<OrderDetails> completedOrders;

  const HomeScreen({super.key, required this.completedOrders});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late List<OrderDetails> _completedOrders;
  final List<String> _months = [
    '',
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec'
  ];
  bool hasNotification = true;

  late final int _selectedYear = DateTime.now().year;
  late int _selectedMonthIndex = DateTime.now().month - 1;
  late String _selectedMonth = _months[_selectedMonthIndex + 1];

  double? _totalRevenueForGraph;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  late Future<List<double>> _monthlySalesFuture;

  @override
  void initState() {
    super.initState();
    _completedOrders = widget.completedOrders;
    fetchAndUpdateCompletedOrders(); // Fetch completed orders on init
    _monthlySalesFuture = DatabaseHelper().getMonthlySalesAmounts(_selectedYear);
    _monthlySalesFuture.then((sales) {
      setState(() {
        _totalRevenueForGraph = sales[_selectedMonthIndex];
      });
    });
  }

  // Method to update monthly sales and total revenue when month changes
  void _onMonthChanged(int monthIndex) async {
    setState(() {
      _selectedMonthIndex = monthIndex;
      _selectedMonth = _months[monthIndex + 1];
    });

    List<double> sales = await DatabaseHelper().getMonthlySalesAmounts(_selectedYear);
    setState(() {
      _totalRevenueForGraph = sales[monthIndex];
    });
  }

  // Calculate revenue method
  Future<double> calculateTotalRevenue(int year, [int? selectedMonthIndex]) async {
    double totalRevenue = 0;

    for (OrderDetails order in _completedOrders) {
      if (order.completedAt.year == year && order.completedAt.month == selectedMonthIndex) {
        totalRevenue += order.totalPrice;
      }
    }
    return totalRevenue;
  }

  static Future<int> countCustomers() async {
    return await DatabaseHelper().getCustomers().then((customers) => customers.length);
  }

  void displayProductSales() async {
    Map<int, int> soldQuantities = await DatabaseHelper().calculateTotalSoldQuantities();
    soldQuantities.forEach((productId, quantity) {});
  }

  void fetchAndUpdateCompletedOrders() async {
    List<OrderDetails> todayCompletedOrders = await DatabaseHelper().getTodayCompletedOrders(DateTime.now());
    setState(() {
      _completedOrders = todayCompletedOrders;
    });
  }

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
            const Text(
              "Today's Metrics",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            FutureBuilder<double>(
              future: DatabaseHelper().getDailyProfit(DateTime.now()),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasData) {
                  double profit = snapshot.data!;
                  int itemsSold = profit.toInt();
                  int completedOrders = profit ~/ 10;
                  double expenses = profit;

                  return Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildCircularProgressWithLabel(
                            value: profit / 20000,
                            color: Colors.green,
                            label: "Ksh $profit",
                            title: "Profit",
                          ),
                          FutureBuilder<int>(
                            future: DatabaseHelper().getDailyTotalItemsSold(DateTime.now()),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return const Center(child: CircularProgressIndicator());
                              } else if (snapshot.hasData) {
                                int itemsSold = snapshot.data!;
                                return Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      children: [
                                        _buildCircularProgressWithLabel(
                                          value: itemsSold / 2000,
                                          color: Colors.blue,
                                          label: "$itemsSold items",
                                          title: "Items Sold",
                                        ),
                                      ],
                                    ),
                                  ],
                                );
                              } else {
                                return const Text('Error fetching data');
                              }
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          FutureBuilder<List<OrderDetails>>(
                            future: DatabaseHelper().getTodayCompletedOrders(DateTime.now()),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return const CircularProgressIndicator();
                              } else if (snapshot.hasError) {
                                return Text("Error: ${snapshot.error}");
                              } else if (snapshot.hasData) {
                                int completedOrders = snapshot.data!.length;
                                return _buildCircularProgressWithLabel(
                                  value: completedOrders / 1000,
                                  color: Colors.red,
                                  label: "$completedOrders orders",
                                  title: "Completed Orders",
                                );
                              } else {
                                return const Text("No data available");
                              }
                            },
                          ),
                          FutureBuilder<double>(
                            future: DatabaseHelper().getDailyExpenses(DateTime.now()),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return const CircularProgressIndicator();
                              } else if (snapshot.hasError) {
                                return Text('Error: ${snapshot.error}');
                              } else {
                                double expenses = snapshot.data!;
                                return _buildCircularProgressWithLabel(
                                  value: expenses / 20000,
                                  color: Colors.orange,
                                  label: "Ksh ${expenses.toStringAsFixed(2)}",
                                  title: "Expenses",
                                );
                              }
                            },
                          ),
                        ],
                      ),
                    ],
                  );
                } else {
                  return const Text('Error fetching data');
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCircularProgressWithLabel({
    required double value,
    required Color color,
    required String label,
    required String title,
  }) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 120,
              height: 120,
              child: CircularProgressIndicator(
                value: value,
                valueColor: AlwaysStoppedAnimation<Color>(color),
                backgroundColor: Colors.grey[300],
                strokeWidth: 8,
              ),
            ),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[600],
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: TextStyle(
            color: Colors.grey[600],
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildRectangle({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      height: 80, // Set a fixed height
      padding: const EdgeInsets.symmetric(
          vertical: 4.0, horizontal: 8.0), // Adjusted padding
      margin: const EdgeInsets.only(right: 8.0),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color.fromARGB(255, 7, 204, 59),
            Color.fromARGB(255, 191, 190, 193)
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color.fromARGB(255, 77, 161, 58).withOpacity(0.5),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, size: 18, color: const Color.fromARGB(255, 81, 77, 77)),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              '$label\n$value',
              style: const TextStyle(
                color: Color.fromARGB(255, 30, 5, 47),
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopProductItem({
    required String imageUrl,
    required String name,
    required int quantitySold,
    required double revenue,
  }) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Container(
            height: 60,
            width: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              image: imageUrl.isNotEmpty
                  ? DecorationImage(
                      image: NetworkImage(imageUrl),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child:
                imageUrl.isEmpty ? const Icon(Icons.image_not_supported) : null,
          ),
          const SizedBox(height: 5),
          Text(
            name,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
          Text(
            "Sold: $quantitySold",
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          Text(
            "Revenue: Ksh ${revenue.toStringAsFixed(2)}",
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget buildTopProductsSection() {
    return FutureBuilder<List<Product>>(
      future: OrderRepository.getBestSellingProducts(), // Make sure this is correctly fetching data
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error.toString()}');
        } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: snapshot.data!.map((product) {
              ImageProvider imageProvider;
              if (product.image != null && product.image!.isNotEmpty) {
                if (product.image!.startsWith('http') || product.image!.startsWith('https')) {
                  // Handle network images
                  imageProvider = NetworkImage(product.image!);
                } else {
                  // Handle local file images
                  imageProvider = FileImage(File(product.image!));
                }
              } else {
                // Default image if none is provided
                imageProvider = const AssetImage("lib/assets/noimage.png");
              }

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 8.0),
                child: Row(
                  children: [
                    Container(
                      height: 60,
                      width: 60,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        image: DecorationImage(
                          fit: BoxFit.cover,
                          image: imageProvider,
                        ),
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product.productName,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            product.medicineDescription ?? "No description available",
                            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Price:', style: TextStyle(fontSize: 14, color: Colors.grey[800])),
                        Text('Ksh${product.sellingPrice.toStringAsFixed(2)}',
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(width: 15),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Revenue:', style: TextStyle(fontSize: 14, color: Colors.grey[800])),
                        Text(
                            'Ksh${(product.soldQuantity * product.sellingPrice).toStringAsFixed(2)}',
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.green[700])),
                      ],
                    ),
                  ],
                ),
              );
            }).toList(),
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
          // Notification button
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const NotificationsPage()),
              );
            },
            icon: Stack(
              children: [
                const Icon(
                  Icons.notifications,
                  color: Colors.white,
                ),
                if (hasNotification) // Show red dot if there's a notification
                  Positioned(
                    left: 13,
                    bottom: 14,
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
          ),
          // Help button
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
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PharmacyProfile()),
              );
            },
            icon: const Icon(
              Icons.person,
              color: Colors.white,
            ),
          ),
        ],
      ),
      drawer: Drawer(
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            return SizedBox(
              width: constraints.maxWidth * 0.9,
              child: const NavigationDrawerWidget(),
            );
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              buildMetricCard(),
              // Revenue card
              Card(
                elevation: 5.0,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('$_selectedMonth Revenue',
                              style: const TextStyle(
                                  fontSize: 16.0, color: Colors.grey)),
                          Text(
                            _totalRevenueForGraph != null
                                ? 'KSH ${_totalRevenueForGraph!.toStringAsFixed(0)}'
                                : 'Loading...',
                            style: const TextStyle(
                                fontSize: 18.0, fontWeight: FontWeight.bold),
                          ),
                          DropdownButton<String>(
                            value: _selectedMonth,
                            icon: const Icon(Icons.arrow_drop_down),
                            elevation: 16,
                            style: const TextStyle(
                                color: Color.fromARGB(255, 13, 13, 13)),
                            underline: Container(
                              height: 2,
                              color: Colors.deepPurpleAccent,
                            ),
                            onChanged: (String? newValue) {
                              if (newValue != null) {
                                int newMonthIndex = _months.indexOf(newValue) - 1;
                                _onMonthChanged(newMonthIndex);
                              }
                            },
                            items: _months
                                .map<DropdownMenuItem<String>>((String month) {
                              return DropdownMenuItem<String>(
                                value: month,
                                child: Text(month),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 200,
                        child: FutureBuilder<List<double>>(
                          future: _monthlySalesFuture,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return const Center(child: CircularProgressIndicator());
                            } else if (snapshot.hasError) {
                              return Text('Error: ${snapshot.error}');
                            } else if (snapshot.hasData) {
                              return IndividualBar(
                                selectedMonthIndex: _selectedMonthIndex,
                                monthlyAmounts: snapshot.data!,
                              );
                            } else {
                              return const Text('No data available');
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // The rest of your widgets...
              Card(
                elevation: 5.0,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: GridView.count(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount: 2,
                          mainAxisSpacing: 8.0,
                          crossAxisSpacing: 8.0,
                          children: [
                            // Customers
                            FutureBuilder<int>(
                              future: OrderRepository.countCustomers(),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState == ConnectionState.waiting) {
                                  return _buildRectangle(
                                    icon: Icons.people,
                                    label: "Customers",
                                    value: "Loading...",
                                  );
                                } else if (snapshot.hasData) {
                                  return _buildRectangle(
                                    icon: Icons.people,
                                    label: "Customers",
                                    value: "${snapshot.data}",
                                  );
                                } else if (snapshot.hasError) {
                                  return _buildRectangle(
                                    icon: Icons.people,
                                    label: "Customers",
                                    value: "Error",
                                  );
                                } else {
                                  return _buildRectangle(
                                    icon: Icons.people,
                                    label: "Customers",
                                    value: "No data",
                                  );
                                }
                              },
                            ),
                            // Sales
                            FutureBuilder<double>(
                              future: OrderRepository.getTotalSales(),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState == ConnectionState.done) {
                                  if (snapshot.hasData) {
                                    return _buildRectangle(
                                      icon: Icons.shopping_cart,
                                      label: "Sales",
                                      value: "Ksh ${snapshot.data!.toStringAsFixed(2)}",
                                    );
                                  } else if (snapshot.hasError) {
                                    return _buildRectangle(
                                      icon: Icons.shopping_cart,
                                      label: "Sales",
                                      value: "Error",
                                    );
                                  }
                                }
                                return _buildRectangle(
                                  icon: Icons.shopping_cart,
                                  label: "Sales",
                                  value: "Loading...",
                                );
                              },
                            ),
                            // Profit
                            FutureBuilder<double>(
                              future: OrderRepository.getTotalProfit(),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState == ConnectionState.waiting) {
                                  return _buildRectangle(
                                    icon: Icons.money,
                                    label: "Profit",
                                    value: "Loading...",
                                  );
                                } else if (snapshot.hasData) {
                                  return _buildRectangle(
                                    icon: Icons.money,
                                    label: "Profit",
                                    value: "Ksh ${snapshot.data!.toStringAsFixed(2)}",
                                  );
                                } else if (snapshot.hasError) {
                                  return _buildRectangle(
                                    icon: Icons.money,
                                    label: "Profit",
                                    value: "Error",
                                  );
                                } else {
                                  return _buildRectangle(
                                    icon: Icons.money,
                                    label: "Profit",
                                    value: "No data",
                                  );
                                }
                              },
                            ),
                            // Total Orders
                            FutureBuilder<int>(
                              future: OrderRepository.countCompletedOrders(),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState == ConnectionState.done) {
                                  if (snapshot.hasData) {
                                    return _buildRectangle(
                                      icon: Icons.local_shipping,
                                      label: "Total Orders",
                                      value: "${snapshot.data}",
                                    );
                                  } else if (snapshot.hasError) {
                                    return _buildRectangle(
                                      icon: Icons.local_shipping,
                                      label: "Orders",
                                      value: "Error",
                                    );
                                  }
                                }
                                return _buildRectangle(
                                  icon: Icons.local_shipping,
                                  label: "Orders",
                                  value: "Loading...",
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        "Top Products",
                        style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      buildTopProductsSection(),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              // Stats card
              Card(
                elevation: 5.0,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Actual Top Stats',
                        style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16.0),
                      FutureBuilder<List<Product>>(
                        future: OrderRepository.getBestSellingProducts(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const CircularProgressIndicator();
                          } else if (snapshot.hasError) {
                            return Text('Error: ${snapshot.error.toString()}');
                          } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                            int maxQuantity = snapshot.data!.map((p) => p.soldQuantity).reduce(math.max);
                            return Column(
                              children: snapshot.data!.map((product) {
                                double fraction = maxQuantity != 0 ? product.soldQuantity / maxQuantity : 0.0;
                                return GestureDetector(
                                  onTap: () => showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: Text(product.productName),
                                        content: SingleChildScrollView(
                                          child: ListBody(
                                            children: <Widget>[
                                              Text('Price: Ksh${product.sellingPrice.toStringAsFixed(2)}'),
                                              Text('Quantity Sold: ${product.soldQuantity}'),
                                              Text('Total Revenue: Ksh${(product.soldQuantity * product.sellingPrice).toStringAsFixed(2)}'),
                                              // Text('Profit: Ksh${(product.profit.toStringAsFixed(2))}'),
                                            ],
                                          ),
                                        ),
                                        actions: <Widget>[
                                          TextButton(
                                            child: const Text('Close'),
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        product.productName,
                                        style: const TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold),
                                      ),
                                      LinearProgressIndicator(
                                        value: fraction,
                                        backgroundColor: Colors.grey[300],
                                        valueColor: AlwaysStoppedAnimation<Color>(
                                          product == snapshot.data!.first
                                              ? Colors.blue
                                              : product == snapshot.data![1]
                                                  ? Colors.green
                                                  : Colors.red,
                                        ),
                                        minHeight: 10,
                                      ),
                                      const SizedBox(height: 20),
                                    ],
                                  ),
                                );
                              }).toList(),
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
            ],
          ),
        ),
      ),
    );
  }
}





class IndividualBar extends StatelessWidget {
  final int selectedMonthIndex;
  final List<double> monthlyAmounts;

  const IndividualBar({
    Key? key,
    required this.selectedMonthIndex,
    required this.monthlyAmounts,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return fl.BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceEvenly,
        maxY: monthlyAmounts.reduce((a, b) => a > b ? a : b),
        barGroups: List.generate(12, (index) {
          final isSelected = index == selectedMonthIndex;
          final color = isSelected ? Colors.green : Colors.grey;
          final value = isSelected
              ? monthlyAmounts[index]
              : (monthlyAmounts[index] != 0
                  ? monthlyAmounts[index]
                  : Random().nextDouble() * 10 + 1); // Ensure some visibility

          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: value,
                color: color,
                width: 20,
                borderRadius: BorderRadius.zero,
              ),
            ],
          );
        }),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
           topTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (double value, TitleMeta meta) {
                const style = TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                );
                Widget text;
                switch (value.toInt()) {
                  case 0:
                    text = const Text('Jan', style: style);
                    break;
                  case 1:
                    text = const Text('Feb', style: style);
                    break;
                  case 2:
                    text = const Text('Mar', style: style);
                    break;
                  case 3:
                    text = const Text('Apr', style: style);
                    break;
                  case 4:
                    text = const Text('May', style: style);
                    break;
                  case 5:
                    text = const Text('Jun', style: style);
                    break;
                  case 6:
                    text = const Text('Jul', style: style);
                    break;
                  case 7:
                    text = const Text('Aug', style: style);
                    break;
                  case 8:
                    text = const Text('Sep', style: style);
                    break;
                  case 9:
                    text = const Text('Oct', style: style);
                    break;
                  case 10:
                    text = const Text('Nov', style: style);
                    break;
                  case 11:
                    text = const Text('Dec', style: style);
                    break;
                  default:
                    text = const Text('', style: style);
                    break;
                }
                return SideTitleWidget(
                  axisSide: meta.axisSide,
                  space: 8.0, // space between bar and title
                  child: text,
                );
              },
            ),
          ),
        ),
        gridData: FlGridData(show: false),
        borderData: FlBorderData(
          show: true,
          border: Border(
            bottom: BorderSide(
              color: Colors.black,
              width: 1,
            ),
          ),
        ),
      ),
    );
  }
}
