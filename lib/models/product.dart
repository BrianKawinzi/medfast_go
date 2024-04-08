class Product {
  final int id;
  String productName;
  String medicineDescription;
  double buyingPrice;
  String? image;
  String expiryDate;
  final String manufactureDate;
  final String? unit; // Unit field

  Product({
    required this.id,
    required this.productName,
    required this.medicineDescription,
    required this.buyingPrice,
    this.image,
    required this.expiryDate,
    required this.manufactureDate,
    this.unit, required double sellingPrice, required int quantity,
  });

  // Named constructor to create a Product object from a map
  Product.fromMap(Map<String, dynamic> map)
      : id = map['id'],
        productName = map['productName'],
        medicineDescription = map['medicineDescription'],
        buyingPrice = map['buyingPrice'].toDouble(),
        image = map['image'],
        expiryDate = map['expiryDate'],
        manufactureDate = map['manufactureDate'],
        unit = map['unit'];

  get sellingPrice => null;

  // Method to convert a Product object to a map
  Map<String, dynamic> toMap({bool excludeId = false}) {
    return {
      'id': id,
      'productName': productName,
      'medicineDescription': medicineDescription,
      'buyingPrice': buyingPrice,
      'image': image,
      'expiryDate': expiryDate,
      'manufactureDate': manufactureDate,
      'unit': unit,
    };
  }
}