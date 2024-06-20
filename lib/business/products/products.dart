import 'dart:io';
import 'package:barcode_scan2/platform_wrapper.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:medfast_go/business/editproductpage.dart';
import 'package:medfast_go/business/products/import_product.dart';
import 'package:medfast_go/business/products/qr_scanner.dart';
import 'package:medfast_go/controllers/products_controller.dart';
import 'package:medfast_go/data/DatabaseHelper.dart';
import 'package:medfast_go/models/product.dart';
import 'package:medfast_go/pages/bottom_navigation.dart';
import 'package:medfast_go/services/network_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class Products extends StatefulWidget {
  const Products({super.key, required String productName});

  @override
  _ProductsState createState() => _ProductsState();
}

class _ProductsState extends State<Products> {
  final TextEditingController searchController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();
  final TextEditingController skuController = TextEditingController();
  final TextEditingController barcodeController = TextEditingController();
  final TextEditingController sellingPriceController = TextEditingController();
  final TextEditingController medicineNameController = TextEditingController();
  final TextEditingController medicineDescriptionController =
      TextEditingController();
  final TextEditingController dosageFormController = TextEditingController();
  final TextEditingController strengthController = TextEditingController();
  final TextEditingController manufacturerController = TextEditingController();
  final TextEditingController categoryController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController manufactureDateController =
      TextEditingController();
  final TextEditingController expiryDateController = TextEditingController();
  final ProductsController productsController = Get.find();
  final NetworkController networkController = Get.find();

  List<Product> products = [];
  String hintText = ''; // To store the hint text

  Future<void> _filterProducts(String query) async {
    // final dbHelper = DatabaseHelper();
    // final allProducts = await dbHelper.getProducts();

    // setState(() {
    //   if (query.isEmpty) {
    //     products = allProducts;
    //   } else {
    //     products = allProducts.where((product) {
    //       final productName = product.productName;
    //       return productName.toLowerCase().contains(query.toLowerCase());
    //     }).toList();
    //   }
    // });
  }

  void _navigateToEditProduct(Product product) {
    Navigator.of(context).push(_createRoute(product));
  }

  Route _createRoute(Product product) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) =>
          EditProductPage(product: product),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.ease;

        var tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        var offsetAnimation = animation.drive(tween);

        return SlideTransition(
          position: offsetAnimation,
          child: child,
        );
      },
    );
  }

  Widget _buildProductList({required Product product}) {
    var imageFile = File(product.image ?? '');
    return Dismissible(
      key: Key(product.id.toString()),
      onDismissed: (direction) {
        _confirmDeleteProduct(product);
      },
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        child: const Icon(
          Icons.delete,
          color: Colors.white,
          size: 36,
        ),
      ),
      child: Card(
        margin: const EdgeInsets.all(8.0),
        child: ListTile(
          title: Text(product.productName),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Expiry Date: ${product.expiryDate}"),
              Text('Description: ${product.medicineDescription}'),
              Text('Price: ${product.sellingPrice}'),
            ],
          ),
          leading: SizedBox(
              width: 100,
              child: networkController.connectionStatus.value == 0
                  ? Image.file(
                      imageFile,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(Icons.error);
                      },
                    )
                  : Image.network(product.image!)),
          onTap: () => _navigateToEditProduct(product),
        ),
      ),
    );
  }

  void _confirmDeleteProduct(Product product) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: const Text('Are you sure you want to delete this product?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();

                _showProductList(); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                await productsController.deleteProduct(
                    product: product, context: context);
                Navigator.of(context).pop(); // Close the dialog
                // Call a method to simulate the swipe action
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void _showProductList() {
    // Simulate the swipe action or any other action needed
    // You can add the logic to update the state or perform any other action
    // For example, you can use Navigator.push to navigate to the same page again
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const Products(
          productName: '',
        ),
      ),
    );
  }

  int _calculateTotalQuantity() {
    int totalQuantity = 0;
    for (var product in products) {
      totalQuantity += product.quantity;
    }
    return totalQuantity;
  }

  double _calculateTotalWorth() {
    double totalWorth = 0;
    for (var product in products) {
      totalWorth += product.quantity * product.sellingPrice;
    }
    return totalWorth;
  }

  @override
  Widget build(BuildContext context) {
    int totalQuantity = _calculateTotalQuantity();
    double totalWorth = _calculateTotalWorth();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Products'),
        centerTitle: true,
        backgroundColor: const Color.fromRGBO(58, 205, 50, 1),
        leading: GestureDetector(
          onTap: () => Navigator.of(context).pushReplacement(MaterialPageRoute(
              builder: (context) => const BottomNavigation())),
          child: const Icon(Icons.arrow_back),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              // Implement menu action
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            height: 48,
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 2,
                  blurRadius: 3,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: searchController,
                    onChanged: (query) => _filterProducts(query),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Search Products',
                      labelStyle: TextStyle(color: Colors.green),
                      prefixIcon: Icon(Icons.search),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.qr_code_scanner),
                  onPressed: () async {
                    try {
                      final status = await Permission.camera.request();
                      if (status.isGranted) {
                        try {
                          var result = await BarcodeScanner.scan();
                          String barcode = result.rawContent;
                          Product product = await productsController
                              .fetchProductByBarcode(barcode: barcode);
                          if (product != '') {
                            _navigateToEditProduct(product);
                          }
                        } catch (e) {
                          print(e);
                        }
                      } else {
                        throw PlatformException(
                            code: 'PERMISSION_DENIED',
                            message: 'Camera permission is required.');
                      }
                    } catch (e) {
                      print(e);
                    }
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<List<Product>>(
              stream: productsController.fetchProducts(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: SizedBox(
                      width: 40,
                      height: 40,
                      child: CircularProgressIndicator(),
                    ),
                  );
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                      child: Text(
                          'No products available click the button below to add one.'));
                } else {
                  List<Product> products = snapshot.data!;
                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      return _buildProductList(product: products[index]);
                    },
                  );
                }
              },
            ),
          ),
          // Expanded(child: _buildProductList()),
          if (products.isNotEmpty)
            Container(
              width: double.infinity,
              height: 40, // Approx. 1 cm high
              color: Colors.green[100],
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Total Quantity: $totalQuantity'),
                  Text('Stock value: Ksh${totalWorth.toStringAsFixed(2)}'),
                ],
              ),
            ),
        ],
      ),
      floatingActionButton: Padding(
        padding:
            const EdgeInsets.only(bottom: 30.9), // 0.5 cm in logical pixels
        child: FloatingActionButton(
          onPressed: () {
            _showPopupMenu(context);
          },
          backgroundColor: const Color.fromRGBO(58, 205, 50, 1),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  void _showPopupMenu(BuildContext context) {
    final RenderBox button = context.findRenderObject() as RenderBox;
    final RelativeRect position = RelativeRect.fromLTRB(
      0,
      button.size.height,
      button.size.width / 2,
      0,
    );

    showMenu(
      context: context,
      position: position,
      items: [
        PopupMenuItem(
          child: ListTile(
            leading: const Icon(Icons.camera),
            title: const Text('Add single product'),
            onTap: () {
              Navigator.pop(context);
              _showProductForm(context);
            },
          ),
        ),
        PopupMenuItem(
          child: ListTile(
            leading: const Icon(Icons.picture_as_pdf),
            title: const Text('Import from excel'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                  context,
                  (MaterialPageRoute(
                    builder: (context) => const ProductImport(),
                  )));
            },
          ),
        ),
      ],
    );
  }

  void _showProductForm(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Container(
          color: const Color.fromRGBO(126, 127, 179, 0.39),
          child: Padding(
            padding: const EdgeInsets.all(30.0),
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing:
                  10, // Adjust this value as needed for spacing between buttons
              children: [
                Material(
                  borderRadius: BorderRadius.circular(45),
                  elevation: 6,
                  child: InkWell(
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                          context,
                          (MaterialPageRoute(
                            builder: (context) => const BarcodeScanners(),
                          )));
                    },
                    child: Ink(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Colors.deepPurple, Colors.purpleAccent],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(45),
                      ),
                      padding: const EdgeInsets.all(30), // Reduced padding
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Image.asset(
                            'lib/assets/barcode_icon.png',
                            width: 80, // Reduced size
                            height: 80,
                          ),
                          const Text('Barcode',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                shadows: [
                                  Shadow(
                                    blurRadius: 2.0,
                                    color: Colors.black26,
                                    offset: Offset(1.0, 1.0),
                                  ),
                                ],
                              ))
                        ],
                      ),
                    ),
                  ),
                ),
                Material(
                  borderRadius: BorderRadius.circular(45),
                  elevation: 6,
                  child: InkWell(
                    onTap: () {
                      Navigator.of(context).pushNamed('/productwithoutbarcode');
                    },
                    child: Ink(
                      decoration: BoxDecoration(
                        color: const Color.fromRGBO(58, 205, 50, 1),
                        borderRadius: BorderRadius.circular(45),
                      ),
                      padding: const EdgeInsets.all(30), // Reduced padding
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Image.asset(
                            'lib/assets/no_barcode_icon.png',
                            width: 80, // Reduced size
                            height: 80,
                          ),
                          const Text('No Barcode',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                shadows: [
                                  Shadow(
                                    blurRadius: 2.0,
                                    color: Colors.black26,
                                    offset: Offset(1.0, 1.0),
                                  ),
                                ],
                              ))
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
