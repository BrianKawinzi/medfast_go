class Product {
  final int id;
  String productName;
  String medicineDescription;
  double buyingPrice;
  String? image;
  String expiryDate;
  double sellingPrice = 0;
  int quantity;
  final String manufactureDate;
  final String? unit; 

  Product({
    required this.id,
    required this.productName,
    required this.medicineDescription,
    required this.buyingPrice,
    required this.quantity,
    required this.sellingPrice,
    this.image,
    required this.expiryDate,
    required this.manufactureDate,
    this.unit,
  });

  // Named constructor to create a Product object from a map
  Product.fromMap(Map<String, dynamic> map)
      : id = map['id'],
        productName = map['productName'],
        medicineDescription = map['medicineDescription'],
        buyingPrice = map['buyingPrice'].toDouble(),
        sellingPrice = map['sellingPrice']?.toDouble() ?? 0.0,

        quantity = map['quantity']?.toInt() ??0,
        image = map['image'],
        expiryDate = map['expiryDate'],
        manufactureDate = map['manufactureDate'],
        unit = map['unit'];



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
    };
  }
}