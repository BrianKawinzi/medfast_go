import 'dart:convert';
import 'package:medfast_go/models/product.dart'; // Make sure this is the correct path

class OrderDetails {
  final String orderId;
  final double totalPrice;
  final List<Product> products;
  final DateTime completedAt;

  OrderDetails({
    required this.orderId,
    required this.totalPrice,
    required this.products,
    required this.completedAt,
  });

  // Convert OrderDetails to Map
  Map<String, dynamic> toMap() {
    return {
      'orderId': orderId,
      'totalPrice': totalPrice,
      // Convert list of products to a JSON string
      'products':
          json.encode(products.map((product) => product.toMap()).toList()),
      'completedAt':
          completedAt.toIso8601String(), // Store date as ISO8601 string
    };
  }

  // Convert Map to OrderDetails
  static OrderDetails fromMap(Map<String, dynamic> map) {
    return OrderDetails(
      orderId: map['orderId'],
      totalPrice: map['totalPrice'],
      // Convert JSON string back to list of Products
      products: List<Product>.from(json
          .decode(map['products'])
          .map((productMap) => Product.fromMap(productMap))),
      completedAt: DateTime.parse(map['completedAt']),
    );
  }
}
