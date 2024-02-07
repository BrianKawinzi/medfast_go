import 'package:flutter/material.dart';
import 'package:medfast_go/business/sales.dart';
import 'package:medfast_go/pages/bottom_navigation.dart';
import 'package:medfast_go/pages/home_page.dart';
import 'package:intl/intl.dart';

class saleOrder extends StatelessWidget {
  final List<OrderDetails>? orders;

  const saleOrder({Key? key, this.orders}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    List<OrderDetails> completedOrders = OrderRepository.getCompletedOrders();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 32, 148, 3),
        title: Text('Sales History'),
      ),
      body: ListView.builder(
        itemCount: completedOrders.length,
        itemBuilder: (context, index) {
          OrderDetails order = completedOrders[index];
          // Format the date and time
          String formattedDate =
              DateFormat('dd/MM/yyyy hh:mm a').format(order.completedAt);

          return ExpansionTile(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Order #${order.orderId}"),
                Text(formattedDate,
                    style:
                        TextStyle(fontSize: 14)), // Display formatted date here
              ],
            ),
            subtitle: Text("Total: \Ksh${order.totalPrice.toStringAsFixed(2)}"),
            children: order.products
                .map((product) => ListTile(
                      title: Text(product.productName),
                      subtitle: Text(
                          "Unit Price: \Ksh${product.buyingPrice.toStringAsFixed(2)}"),
                    ))
                .toList(),
          );
        },
      ),
    );
  }
}
