import 'dart:io';
import 'package:flutter/material.dart';
import 'package:medfast_go/business/editproductpage.dart';
import 'package:medfast_go/data/DatabaseHelper.dart';
import 'package:medfast_go/pages/home_page.dart';
import 'package:medfast_go/models/product.dart';

class Products extends StatefulWidget {
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
  final TextEditingController medicineDescriptionController = TextEditingController();
  final TextEditingController dosageFormController = TextEditingController();
  final TextEditingController strengthController = TextEditingController();
  final TextEditingController manufacturerController = TextEditingController();
  final TextEditingController categoryController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController manufactureDateController = TextEditingController();
  final TextEditingController expiryDateController = TextEditingController();

  List<Product> products = [];
  String hintText = ''; // To store the hint text

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  Future<void> _fetchProducts() async {
    final dbHelper = DatabaseHelper();
    final fetchedProducts = await dbHelper.getProducts();
    setState(() {
      products = fetchedProducts;
    });
  }

  Future<void> _filterProducts(String query) async {
    final dbHelper = DatabaseHelper();
    final allProducts = await dbHelper.getProducts();

    setState(() {
      if (query.isEmpty) {
        products = allProducts;
      } else {
        products = allProducts.where((product) {
          final productName = product.productName ?? '';
          return productName.toLowerCase().contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  void _navigateToEditProduct(Product product) {
    Navigator.of(context).push(_createRoute(product));
  }

  Route _createRoute(Product product) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => EditProductPage(product: product),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.ease;

        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        var offsetAnimation = animation.drive(tween);

        return SlideTransition(
          position: offsetAnimation,
          child: child,
        );
      },
    );
  }

  Widget _buildProductList() {
    if (products.isEmpty) {
      return Center(
        child: Text(
          "No products added yet. Click the + button to add your first product.",
          style: TextStyle(fontSize: 18.0),
        ),
      );
    } else {
      return ListView.builder(
        itemCount: products.length,
        itemBuilder: (context, index) {
          var product = products[index];
          var imageFile = File(product.image ?? '');
          return Card(
            margin: const EdgeInsets.all(8.0),
            child: ListTile(
              title: Text(product.productName ?? ''),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Expiry Date: ${product.expiryDate ?? ''}"),
                  Text('Description: ${product.medicineDescription ?? ''}'),
                  Text('Price: ${product.buyingPrice ?? ''}'),
                ],
              ),
              leading: SizedBox(
                width: 100,
                child: imageFile.existsSync()
                    ? Image.file(
                        imageFile,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(Icons.error);
                        },
                      )
                    : Placeholder(),
              ),
              onTap: () => _navigateToEditProduct(product),
            ),
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Products'),
        centerTitle: true,
        backgroundColor: Color.fromRGBO(58, 205, 50, 1),
        leading: GestureDetector(
          onTap: () {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => HomePage(),
              ),
            );
          },
          child: Icon(Icons.arrow_back),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.menu),
            onPressed: () {
              // Menu action
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            height: 48,
            margin: EdgeInsets.all(16),
            padding: EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 2,
                  blurRadius: 3,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: searchController,
                    onChanged: (query) => _filterProducts(query),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      labelText: 'Search Products',
                      labelStyle: TextStyle(color: Colors.green),
                      prefixIcon: Icon(Icons.search),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.qr_code_scanner),
                  onPressed: () {
                    print("Retrieving product by barcode...");
                  },
                ),
              ],
            ),
          ),
          Expanded(child: _buildProductList()),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showProductForm(context);
        },
        backgroundColor: Color.fromRGBO(58, 205, 50, 1),
        child: Icon(Icons.add),
      ),
    );
  }

  void _showProductForm(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Container(
          color: Color.fromRGBO(126, 127, 179, 0.39),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Wrap(
              alignment: WrapAlignment.center,
              children: [
                Material(
                  borderRadius: BorderRadius.circular(45),
                  elevation: 6,
                  child: InkWell(
                    onTap: () {
                      print("Retrieving product by barcode...");
                    },
                    child: Ink(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.deepPurple, Colors.purpleAccent],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(45),
                      ),
                      padding: const EdgeInsets.all(40),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Image.asset(
                            'lib/assets/barcode_icon.png',
                            width: 100,
                            height: 100,
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
                const SizedBox(width: 20),
                Material(
                  borderRadius: BorderRadius.circular(45),
                  elevation: 6,
                  child: InkWell(
                    onTap: () {
                      Navigator.of(context).pushNamed('/productwithoutbarcode');
                    },
                    child: Ink(
                      decoration: BoxDecoration(
                        color: Color.fromRGBO(58, 205, 50, 1),
                        borderRadius: BorderRadius.circular(45),
                      ),
                      padding: const EdgeInsets.all(40),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Image.asset(
                            'lib/assets/no_barcode_icon.png',
                            width: 100,
                            height: 100,
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