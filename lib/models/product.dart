class Product {
  String? barcode;
  final int id;
  String? userId;
  String productName;
  String medicineDescription;
  double buyingPrice;
  String? image;
  String expiryDate;
  double sellingPrice = 0;
  double profit;
  int quantity;
  int soldQuantity;
  final String manufactureDate;
  final String? unit;

  Product(
      {required this.id,
      required this.productName,
      required this.medicineDescription,
      required this.buyingPrice,
      required this.quantity,
      required this.sellingPrice,
      this.image,
      this.soldQuantity = 0,
      this.profit = 0,
      required this.expiryDate,
      required this.manufactureDate,
      this.unit,
      this.barcode,
      this.userId});

  // Named constructor to create a Product object from a map
  Product.fromMap(Map<String, dynamic> map)
      : id = map['id'],
        productName = map['productName'],
        medicineDescription = map['medicineDescription'],
        buyingPrice = map['buyingPrice'].toDouble(),
        sellingPrice = map['sellingPrice']?.toDouble() ?? 0.0,
        quantity = map['quantity']?.toInt() ?? 0,
        image = map['image'],
        expiryDate = map['expiryDate'],
        manufactureDate = map['manufactureDate'],
        unit = map['unit'],
        soldQuantity = map['soldQuantity']?.toInt() ?? 0,
        profit = map['sellingPrice']?.toDouble() ?? 0.0,
        barcode = map['barcode'],
        userId = map['user_id'];

  // Method to convert a Product object to a map
  Map<String, dynamic> toMap({bool excludeId = false}) {
    return {
      'id': id,
      'productName': productName,
      'medicineDescription': medicineDescription,
      'buyingPrice': buyingPrice,
      'image': image,
      'sellingPrice': sellingPrice,
      'quantity': quantity,
      'expiryDate': expiryDate,
      'manufactureDate': manufactureDate,
      'unit': unit,
      'soldQuantity': soldQuantity,
      'profit': profit,
      'barcode': barcode,
      'user_id': userId
    };
  }
}
