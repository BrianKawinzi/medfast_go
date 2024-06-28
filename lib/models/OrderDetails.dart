import 'dart:convert';
import 'package:medfast_go/models/product.dart'; // Ensure this import points to the correct location of Product class

class OrderDetails {
  final String orderId;
  final double totalPrice;
  final List<Product> products;
  final DateTime completedAt;
  final double profit;

  OrderDetails({
    required this.orderId,
    required this.totalPrice,
    required this.products,
    required this.completedAt,
    required this.profit,
  });

  Map<String, dynamic> toMap() {
    return {
      'orderId': orderId,
      'totalPrice': totalPrice,
      'products':
          json.encode(products.map((product) => product.toMap()).toList()),
      'completedAt': completedAt.toIso8601String(),
      'profit': profit,
    };
  }

  static OrderDetails fromMap(Map<String, dynamic> map) {
    return OrderDetails(
      orderId: map['orderId'],
      totalPrice: map['totalPrice'],
      products: List<Product>.from(json
          .decode(map['products'])
          .map((productMap) => Product.fromMap(productMap))),
      completedAt: DateTime.parse(map['completedAt']),
      profit: double.tryParse(map['profit'].toString()) ??
          0.0, // Safely parse profit to double
    );
  }
}
