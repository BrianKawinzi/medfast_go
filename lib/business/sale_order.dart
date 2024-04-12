import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:medfast_go/business/sales.dart';
import 'package:medfast_go/models/OrderDetails.dart';
import 'package:medfast_go/pages/home_screen.dart';


class SaleOrder extends StatelessWidget {
  final List<OrderDetails>? orders;

  const SaleOrder({Key? key, this.orders}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green, // Simplified the color
        title: const Text('Sales History'),
      ),
      body: FutureBuilder<List<OrderDetails>>(
        future:
            OrderRepository.getCompletedOrders(), // Fetch the completed orders
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Show loading indicator while waiting for data
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            // Show error message if there's an error loading the data
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (snapshot.hasData) {
            // Build the list view if data is available
            List<OrderDetails> completedOrders = snapshot.data ?? [];
            return ListView.builder(
              itemCount: completedOrders.length,
              itemBuilder: (context, index) {
                OrderDetails order = completedOrders[index];
                String formattedDate =
                    DateFormat('dd/MM/yyyy hh:mm a').format(order.completedAt);

                return ExpansionTile(
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Order #${order.orderId}"),
                      Text(formattedDate, style: const TextStyle(fontSize: 12)),
                    ],
                  ),
                  subtitle:
                      Text("Total: Ksh${order.totalPrice.toStringAsFixed(2)}"),
                  children: order.products
                      .map((product) => ListTile(
                            title: Text(product.productName),
                            subtitle: Text(
                                "Unit Price: Ksh${product.buyingPrice.toStringAsFixed(2)}"),
                          ))
                      .toList(),
                );
              },
            );
          } else if (snapshot.hasData) {
            List<OrderDetails> completedOrders = snapshot.data ?? [];
            return HomeScreen(completedOrders: completedOrders);
          }else {
            // Show message when there's no data
            return const Center(child: Text("No sales history found."));
          }
        },
      ),
    );
  }
}
