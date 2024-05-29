import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:medfast_go/business/editproductpage.dart';
import 'package:medfast_go/models/M_PesaDetailsEntryPage.dart';
import 'package:medfast_go/models/M_PesaPayment.dart';
import 'package:medfast_go/models/OrderDetails.dart';
import 'package:medfast_go/models/customers.dart';
import 'package:medfast_go/models/product.dart';
import 'package:flutter/services.dart';
import 'package:medfast_go/pages/bottom_navigation.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:provider/provider.dart';
import 'package:medfast_go/data/DatabaseHelper.dart';
import 'package:collection/collection.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';




class CartProvider with ChangeNotifier {
  final List<Product> _cartItems = [];
  final Map<int, int> _productQuantities = {};

  List<Product> get cartItems => _cartItems;
  Map<int, int> get productQuantities => _productQuantities;


  void add(Product product) {
    int currentQuantity = _productQuantities[product.id] ?? 0;
    if (currentQuantity < product.quantity) {
      _cartItems.add(product);
      _productQuantities.update(product.id, (value) => value + 1,
          ifAbsent: () => 1);
      notifyListeners();
    }
  }


  void remove(Product product, {bool removeAll = false}) {
    if (removeAll) {
      _cartItems.removeWhere((p) => p.id == product.id);
      _productQuantities.remove(product.id);
    } else {
      int? currentQuantity = _productQuantities[product.id];
      if (currentQuantity != null && currentQuantity > 0) {
        _productQuantities.update(product.id, (value) {
          value -= 1;
          if (value <= 0) {
            // If after decrementing the quantity is 0 or less, also remove from cart items
            _cartItems.removeWhere((p) => p.id == product.id);
          }
          return value;
        });
      }
    }
    notifyListeners();
  }

    void updateProductQuantities() async {
      final dbHelper = DatabaseHelper();  

      for (var product in _cartItems) {
        int soldQuantity = _productQuantities[product.id] ?? 0;
        int newQuantity = product.quantity - soldQuantity;

        await dbHelper.updateProductQuantity(product.id, newQuantity);
      }

      resetCart();
    }


    void resetCart() {
    _cartItems.clear();
    _productQuantities.clear();
    notifyListeners();
  }

  int getCartQuantity(Product product) {
    ProductNotifier().notifyListeners();
    return _productQuantities[product.id] ?? 0;
  }
}
class ProductNotifier with ChangeNotifier {
  final List<Product> _products = [];
  List<Product> get products => _products;
  List<Product> cartItems = [];

  void addProduct(Product product) {
    _products.add(product);
    notifyListeners();
  }
}

class Sales extends StatefulWidget {
  final List<Product> initialProducts;

  Sales({Key? key, required this.initialProducts}) : super(key: key);

  @override
  _SalesState createState() => _SalesState();
}

class _SalesState extends State<Sales> {
  final TextEditingController searchController = TextEditingController();
  List<Product> products = [];
  List<Product> allProducts =
      []; // To store all products fetched from the database
  String hintText = 'Search';

  get totalPrice => null; // Placeholder text for search
  
  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  Future<void> _fetchProducts() async {
    final dbHelper = DatabaseHelper();
    final fetchedProducts = await dbHelper.getProducts();
    if (mounted) {
      setState(() {
        products = fetchedProducts;
       
        
      
      });
    }
  }

  Future<void> _filterProducts(String query) async {
    final dbHelper = DatabaseHelper();
    final allProducts = await dbHelper.getProducts();

    setState(() {
      if (query.isEmpty) {
        products = allProducts;
      } else {
        products = allProducts.where((product) {
          final productName = product.productName;
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

  Widget _buildProductList() {
    int operationalQuantity = 0;
  if (products.isEmpty) {
    return const Center(
      child: Text(
        "No added items for a sale",
        style: TextStyle(fontSize: 18.0),
      ),
    );
  } else {
      return RefreshIndicator(
        onRefresh: _fetchProducts,
        
        child: ListView.builder(
          itemCount: products.length,
          itemBuilder: (context, index) {
            var product = products[index];
            operationalQuantity = product.quantity;
            var imageFile = File(product.image ?? '');
            //updated
            return Card(
              key: Key(product.id.toString()),
              // child: Card(
                margin: const EdgeInsets.all(8.0),
                child: ListTile(
                  title: Text(product.productName),
                  subtitle: Align(
                    alignment: Alignment.topLeft,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Expiry Date: ${product.expiryDate}"),
                        Text('Price: ${product.sellingPrice}'),
                        // Add stock quantity information here
                        Text(
                          operationalQuantity == 0
                              ? "Out of Stock"
                              : "${operationalQuantity - Provider.of<CartProvider>(context, listen: true).getCartQuantity(product)} units",
                          style: TextStyle(
                            fontSize: 12.0,
                            color: operationalQuantity == 0
                                ? Colors.red
                                : (operationalQuantity <= 10
                                    ? Colors.red
                                    : Colors.green),
                          ),
                        )
                      ],
                    ),
                  ),
                  leading: SizedBox(
                    width: 100,
                    child: imageFile.existsSync()
                        ? Image.file(
                            imageFile,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(Icons.error);
                            },
                          )
                        : const Placeholder(),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Add button
                      CircleAvatar(
                        radius: 18,
                        backgroundColor:
                            product.quantity > 0 ? Colors.green : Colors.grey,
                        child: IconButton(
                          icon: const Icon(Icons.add,
                              color: Colors.white, size: 20),
                          onPressed: product.quantity > 0
                              ? () {
                                  setState(() {
                                    ProductNotifier().addProduct(product);
                                    _addToCart(product);
                                  });
                                }
                              : null,
                        ),
                      ),
                      // This SizedBox provides some spacing between the add button and the quantity text
                      const SizedBox(width: 8),
                      // Displaying the quantity in the cart for this product
                      Text(
                        '${Provider.of<CartProvider>(context, listen: true).getCartQuantity(product) == 0 ? "" : Provider.of<CartProvider>(context, listen: true).getCartQuantity(product)}',
                        style: const TextStyle(fontSize: 18.0),
                      ),

                      
                   
                      // This SizedBox provides some spacing between the quantity text and the subtract button
                      const SizedBox(width: 8),
                      // Subtract button
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: Colors.red,
                        child: IconButton(
                          icon: const Icon(
                            Icons.remove,
                            color: Colors.white,
                            size: 20,
                          ),
                          onPressed: () {
                            setState(() {
                              if (_isProductInCart(product)) {
                                ProductNotifier().addProduct(product);
                                // Assuming this method removes the product from the cart and updates the quantity
                                Provider.of<CartProvider>(context,
                                        listen: false)
                                    .remove(product);
                                    

                              } else {
                                // Display an error message if the product is not in the cart
                                _showErrorMessage("Item not in cart");
                              }
                            });
                          },
                        ),
                      ),
                    ],
    
                  ),
                 // onTap: () => _navigateToEditProduct(product),
                ),
              //),
            );
          },
        ),
      );
    }
  }

  @override

  // Create a GlobalKey for the QR Code scanner
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  Barcode? result;
  QRViewController? controller;

  // Load products from the database
  Future<void> _loadProducts() async {
    setState(() {
      products = widget.initialProducts;
    });
  }

 
  int get cartItemCount => Provider.of<CartProvider>(context).cartItems.length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                  builder: (context) =>
                      const BottomNavigation()), // Adjust with your HomePage widget
              (Route<dynamic> route) => false,
            );
          },
        ),
        title: const Text('Sales'),
        centerTitle: true,
        backgroundColor: const Color.fromRGBO(58, 205, 50, 1),
        actions: [
          Padding(
            padding: const EdgeInsets.all(5.0),
            child: Container(
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 20, 197, 4),
                border: Border.all(color: Colors.black),
                borderRadius: BorderRadius.circular(5),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircleAvatar(
                        backgroundColor:
                            Colors.white, // White circle background
                        // To ensure the icon is visually centered in the CircleAvatar, it might be good to adjust padding if necessary
                        child: IconButton(
                          padding: EdgeInsets
                              .zero, // Reduces any default padding to help with centering
                          icon: const Icon(Icons.shopping_cart,
                              size:
                                  24, // Adjust size to fit well within the CircleAvatar
                              color: Colors.black), // Icon with black lines
                          onPressed: () {
                            if (Provider.of<CartProvider>(context,
                                    listen: false)
                                .cartItems
                                .isEmpty) {
                              // Show an error message
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  content: const Text(
                                      'The cart is empty!!\nAdd items and try again.'),
                                  actions: <Widget>[
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context)
                                            .pop(); // Close the dialog
                                      },
                                      child: const Text('OK'),
                                    ),
                                  ],
                                ),
                              );
                            } else {
                              // Existing logic to navigate to the OrderConfirmationScreen
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (BuildContext context) =>
                                      OrderConfirmationScreen(
                                          cartItems: Provider.of<CartProvider>(
                                                  context,
                                                  listen: false)
                                              .cartItems),
                                ),
                              );
                            }
                          },
                        ),
                      ),
                      const SizedBox(
                          width:
                              8), // Add some spacing between the icon and text
                      Text(
                        '${cartItemCount} items',
                        style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Center(
        child: Container(
          width: double.infinity, // Set the width to maximum
          decoration: BoxDecoration(
            image: DecorationImage(
              image: const AssetImage(
                  'lib/assets/pharmacy-store.png'), // Replace with the actual path to your background image
              fit: BoxFit.cover,
              colorFilter: ColorFilter.mode(
                const Color.fromARGB(255, 255, 255, 255)
                    .withOpacity(0.1), // 10% transparency
                BlendMode.dstATop,
              ),
            ),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: TextField(
                  controller: searchController,
                  onChanged: _filterProducts,
                  decoration: InputDecoration(
                    hintText: hintText,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18.1),
                      borderSide: const BorderSide(
                        color: Color.fromARGB(255, 18, 185, 24),
                        width: 6.0,
                      ),
                    ),
                    prefixIcon: const Icon(Icons.search,
                        color: Colors.black,
                        weight: 18,
                        size: 35,
                        semanticLabel: 'Search Icon'),
                    suffixIcon: Padding(
                      padding: const EdgeInsets.only(
                          right:
                              10.0), // Adjusted to leave space between barcode and border
                      child: GestureDetector(
                        onTap: () {
                          // Open barcode scanner here
                          _openBarcodeScanner();
                        },
                        child: Image.asset(
                          'lib/assets/bar-code.png', // Replace with the actual path to your custom barcode image
                          width: 30,
                          height: 30,
                        ),
                      ),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.fromLTRB(
                        20.5, 0, 4.0, 0), // Adjust right padding here
                  ),
                ),
              ),
              Expanded(child: _buildProductList()),
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(
                      bottom: 0.25 * 150 / 2.54), // Adjusted bottom padding
                  child: ElevatedButton(
                    onPressed: () {
                      if (Provider.of<CartProvider>(context, listen: false)
                          .cartItems
                          .isEmpty) {
                        // Show an error message
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Error'),
                            content: const Text(
                                'The cart is empty!!\nAdd items and try again.'),
                            actions: <Widget>[
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context)
                                      .pop(); // Close the dialog
                                },
                                child: const Text('OK'),
                              ),
                            ],
                          ),
                        );
                      } else {
                        // Existing logic to navigate to the OrderConfirmationScreen
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (BuildContext context) =>
                                OrderConfirmationScreen(
                                    cartItems: Provider.of<CartProvider>(
                                            context,
                                            listen: false)
                                        .cartItems),
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromRGBO(114, 194, 117, 1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      side: const BorderSide(color: Colors.black, width: 2.0),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 60, vertical: 10),
                    ),
                    child: const Text(
                      'Confirm',
                      style: TextStyle(
                          fontSize: 25,
                          color: Colors.black,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Function to open the barcode scanner
  Future<void> _openBarcodeScanner() async {
    try {
      final status = await Permission.camera.request();
      if (status.isGranted) {
        Navigator.push(
          context as BuildContext,
          MaterialPageRoute(
            builder: (BuildContext context) {
              return Scaffold(
                appBar: AppBar(title: const Text('Barcode Scanner')),
                body: QRView(
                  key: qrKey,
                  onQRViewCreated: _onQRViewCreated,
                ),
              );
            },
          ),
        );
      } else {
        throw PlatformException(
            code: 'PERMISSION_DENIED',
            message: 'Camera permission is required.');
      }
    } catch (e) {
      print(e);
    }
  }

  // Function to handle the QR code scan result
  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      setState(() {
        result = scanData;
        // Handle the scanned barcode here
      });
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  bool _isProductInCart(Product product) {
    return Provider.of<CartProvider>(context, listen: false)
        .cartItems
        .contains(product);
  }


  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context as BuildContext).showSnackBar(const SnackBar(
      content: Text('Item is not added to the cart!'),
      duration: Duration(seconds: 2),
    ));
  }

  void _addToCart(Product product) {
  
    Provider.of<CartProvider>(context, listen: false).add(product);
    
  }
}

class OrderRepository {
static final DatabaseHelper _dbhelper = DatabaseHelper();

static Future<void> addCompletedOrder(OrderDetails order) async {
    await _dbhelper.insertCompletedOrder(order);
  }
  // Retrieves all completed orders
  static Future<List<OrderDetails>> getCompletedOrders() async {
    return await _dbhelper.getCompletedOrders();
  }

   static Future<int> countCompletedOrders() async {
    List<OrderDetails> completedOrders = await _dbhelper.getCompletedOrders();
    return completedOrders.length;  
  }

  static Future<double> getTotalSales() async {
    List<OrderDetails> orders = await _dbhelper.getCompletedOrders();
    double total = orders.fold(0, (sum, order) => sum + order.totalPrice);
    return total;
  }

   static Future<double> getTotalProfit() async {
    List<OrderDetails> orders = await _dbhelper.getCompletedOrders();
    double totalProfit = orders.fold(0, (sum, order) => sum + order.profit);
    return totalProfit;
  }

  static Future<List<Product>> getBestSellingProducts() async {
    return await _dbhelper.getTopSellingProducts();
  }
//customers count
  static Future<int> countCustomers() async {
    List<Customer> customers = await _dbhelper.getCustomers();
    return customers.length;  
  }
}

class OrderConfirmationScreen extends StatefulWidget {
  final List<Product> cartItems;
  

  const OrderConfirmationScreen({Key? key, required this.cartItems})
      : super(key: key);

  @override
  _OrderConfirmationScreenState createState() =>
      _OrderConfirmationScreenState();
}

class _OrderConfirmationScreenState extends State<OrderConfirmationScreen> {
  late Map<String, int> productQuantity;
  late Map<String, double> productPrice;
  Map<String, double> productDiscounts = {}; 
  Map<String, double> totalDiscounts = {};
  late double sumOfTotalDiscounts;

  
  
  @override
  void initState() {
    super.initState();
    aggregateProductData();
  }

  void aggregateProductData() { 
    productQuantity = {};
    productPrice = {};
    productDiscounts = {};
    totalDiscounts = {};
    for (var product in widget.cartItems) {
      productQuantity[product.productName] =
          (productQuantity[product.productName] ?? 0) + 1;
      if (product.buyingPrice != null) {
          int quantity = productQuantity[product.productName] ?? 0;
          double discount = productDiscounts[product.productName] ?? 0.0;
          double totalDiscountForProduct = discount * quantity;
        productPrice[product.productName] = product.sellingPrice;
        productDiscounts[product.productName] = 0.0; 

      } else {
        productPrice[product.productName] = 0.0; 
      }
    }
    // ignore: invalid_use_of_protected_member
    updateTotalDiscounts();
    CartProvider().notifyListeners();
    updateTotalDiscounts();
  }
   
   void updateTotalDiscounts() {
    sumOfTotalDiscounts =0;
    for (var productName in productQuantity.keys) {
      int quantity = productQuantity[productName] ?? 0;
      double discount = productDiscounts[productName] ?? 0.0; 
      double price = productPrice[productName] ?? 0.0;

      // Calculate total discount for this product
      double totalDiscount = quantity * discount;
      totalDiscounts[productName] = totalDiscount;
      sumOfTotalDiscounts +=totalDiscount;
    }
  }


  //  Import collection package

void _removeItemFromCart(String productName) {
    Product? product =
        widget.cartItems.firstWhereOrNull((p) => p.productName == productName);

    if (product != null) {
      setState(() {
        widget.cartItems.removeWhere((p) => p.productName == productName);
        Provider.of<CartProvider>(context, listen: false)
            .remove(product, removeAll: true);
        aggregateProductData(); // Make sure this handles emptying completely if needed
      });
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Product not found!")));
    }
  }


 Future<void> _showDiscountDialog(String productName) async {
    TextEditingController discountController = TextEditingController();
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Enter Discount for $productName'),
          content: TextField(
            controller: discountController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(hintText: 'Enter discount'),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                setState(() {
                  double? discount = double.tryParse(discountController.text);
                  productDiscounts[productName] = discount ?? 0.0;

                  // Recalculate total discounts after setting a new value
                  updateTotalDiscounts();
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  bool isMiniScreenVisible = false; // Flag to track if MiniScreen is visible

  void _showMiniScreen() {
    setState(() {
      isMiniScreenVisible = true;
    });
  }

  void _closeMiniScreen() {
    setState(() {
      isMiniScreenVisible = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    double getTotalPrice() {
      double totalPrice = 0.0;
      for (var product in widget.cartItems) {
        double price = productPrice[product.productName] ?? 0.0;
        totalPrice += price;
        
      }
      totalPrice -=sumOfTotalDiscounts;
      
      return totalPrice;
      
    }


    double totalPrice = getTotalPrice();
    totalPrice = totalPrice;

    return Scaffold(
      appBar: AppBar(
        title: Text('Order ${OrderManager().orderId}'),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Add your search functionality here gere
            },
          ),
        ],
        toolbarTextStyle: const TextTheme(
          titleLarge: TextStyle(color: Colors.black),
        ).bodyMedium,
        titleTextStyle: const TextTheme(
          titleLarge: TextStyle(color: Colors.black),
        ).titleLarge,
      ),
      body: Stack(
        alignment: Alignment.center,
        children: [
          Opacity(
            opacity: 0.2, // 20% transparency
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: 200.0,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('lib/assets/pharmacy-store.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          Positioned(
            right: 10,
            bottom: 10,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.green,
                border:
                    Border.all(color: Colors.black, width: 2), 
                borderRadius: BorderRadius.circular(
                    5), 
              ),
              padding: const EdgeInsets.all(8),
              child: Column(
                mainAxisSize: MainAxisSize.min, 
                mainAxisAlignment:
                    MainAxisAlignment.center, 
                crossAxisAlignment:
                    CrossAxisAlignment.center, 
                children: [
                  const Text(
                    'Total',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 16, 
                    ),
                  ),
                  Text(
                    'Ksh. ${totalPrice.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 16, 
                    ),
                  ),
                ],
              ),
            ),
          ),
         Positioned(
            left: 10,
            bottom: 10 + 1 * 38.1,
            child: Container(
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 190, 184, 184),
                borderRadius: BorderRadius.circular(5),
              ),
              padding: const EdgeInsets.all(2),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: totalPrice > 0 ? Colors.green : Color.fromARGB(255, 208, 204, 204),
                  elevation: 10,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                ),
                onPressed: totalPrice > 0 ? () {
                  _showMiniScreen();
                } : null,
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.shopping_bag, color: Colors.yellow),
                    SizedBox(width: 8),
                    Text(
                      'Sale',
                      style: TextStyle(
                        color: Color.fromARGB(255, 215, 210, 210),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          Positioned(
            right: 10,
            bottom: 10 +
                60,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment
                  .end, 
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 4), 
                  child: const Center(
                    child: Text(
                      'Add to order',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black, width: 2),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  padding: const EdgeInsets.all(8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.black,
                          backgroundColor:
                              Colors.white,
                        ),
                        onPressed: () {
                        
                        },
                        child: Image.asset('lib/assets/no-barcode.png',
                            width: 30, height: 30), 
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          foregroundColor: const Color.fromARGB(255, 117, 114, 114),
                          backgroundColor:
                              Colors.white, 
                        ),
                        onPressed: () {
                          
                        },
                        child: Image.asset('lib/assets/barcode.png',
                            width: 30, height: 30), 
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (isMiniScreenVisible)
            MiniScreen(
              totalPrice: totalPrice,
              onClose: _closeMiniScreen,
            ),
        Align(
            alignment: Alignment.topCenter,
            child: Container(
              margin: EdgeInsets.only(bottom: 30), 
              height: MediaQuery.of(context).size.height * 0.7,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    
                    if (widget.cartItems.isNotEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Expanded(child: Text('Item Name', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
                            Expanded(child: Text('Quantity', textAlign: TextAlign.center)),
                            Expanded(child: Text('Price', textAlign: TextAlign.center)),
                            Expanded(child: Text('Total', textAlign: TextAlign.center)),
                            IconButton(icon: Icon(Icons.delete), onPressed: null),
                          ],
                        ),
                      ),
                    
                    ...productQuantity.entries.map((entry) {
                      String productName = entry.key;
                      int quantity = entry.value;
                      double price = productPrice[productName] ?? 0.0;
                      double total = quantity * price;
                      double discount = productDiscounts[productName] ?? 0.0;


                      TextEditingController discountController = TextEditingController(); 

                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 8.0),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black, width: 3.0), 
                          borderRadius: BorderRadius.circular(4.0),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Expanded(child: Text(productName, textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
                                Expanded(child: Text('$quantity', textAlign: TextAlign.center)),
                                Expanded(child: Text('$price', textAlign: TextAlign.center)),
                                Expanded(child: Text('$total', textAlign: TextAlign.center)),
                                IconButton(
                                  icon: Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => _removeItemFromCart(productName),
                                ),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      'Expiry Date: ${widget.cartItems.firstWhere((product) => product.productName == productName).expiryDate}',
                                      style: const TextStyle(color: Colors.red),
                                    ),
                                  ),
                                  Expanded(
                                child: TextButton(
                                  style: TextButton.styleFrom(
                                    foregroundColor: Colors.green,
                                    backgroundColor: Colors.transparent,
                                    padding: EdgeInsets.zero,
                                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  onPressed: () => _showDiscountDialog(productName),
                                  child: Text(
                                    totalDiscounts[productName] != null && totalDiscounts[productName]! > 0
                                      ? 'Discount: Ksh ${totalDiscounts[productName]!.toStringAsFixed(2)}'
                                      : 'Offer discount',
                                    style: const TextStyle(
                                      color: Colors.green,
                                      // decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ),
                              ),

                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
class MiniScreen extends StatelessWidget {
  final VoidCallback onClose;
  final double totalPrice;

  Future<void> navigateToPaymentScreen(BuildContext context) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? tillNumber = prefs.getString('tillNumber');
  String? storeNumber = prefs.getString('storeNumber');

  if (tillNumber == null || storeNumber == null) {
    // Navigate to the details entry page
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PaymentCredentialsForm()),
    );
  } else {
    // Navigate to the M-Pesa payment screen
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MobilePayment()),
    );
  }
}


  MiniScreen({Key? key, required this.onClose, required this.totalPrice})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        margin: const EdgeInsets.only(bottom: 0.2 * 38.1), 
        width: 600,
        height: 180, 
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 10, 171, 192),
          border: Border.all(color: Colors.black, width: 2),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text("Pay using", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
            ),
            Row( 
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildPaymentButton("Cash", 'lib/assets/cash.png', () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (BuildContext context) => CashPayment(totalPrice: totalPrice, sumOfTotalDiscounts: 0,),
                    ),
                  );
                }),
                _buildPaymentButton(
                "M-Pesa",
                "lib/assets/MobilePay.jfif",
                () {
                  navigateToPaymentScreen(context);
                },
              )

              ],
            ),
            const Divider(color: Colors.black, thickness: 2, indent: 50, endIndent: 50), 
            _buildCancelButton(context), 
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentButton(String text, String imagePath, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 170,
        height: 50,
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 224, 220, 220),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              imagePath,
              width: 20,
              height: 20,
            ),
            const SizedBox(width: 8),
            Text(
              text,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCancelButton(BuildContext context) {
    return GestureDetector(
      onTap: onClose,
      child: Container(
        width: 170,
        height: 50,
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 224, 220, 220),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Center(
          child: Text(
            "Cancel",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.red,
            ),
          ),
        ),
      ),
    );
  }
}


class CashPayment extends StatefulWidget {
  @override
  final double totalPrice;
  final double sumOfTotalDiscounts; 
  String orderNumber = OrderManager().orderId;

  CashPayment({Key? key, required this.totalPrice, required this.sumOfTotalDiscounts}) : super(key: key);

  @override
  _CashPaymentState createState() => _CashPaymentState();
}

class _CashPaymentState extends State<CashPayment> {
  TextEditingController cashGivenController = TextEditingController();
  TextEditingController customerPhoneController = TextEditingController();
  double cashPaid = 0.0;
  //double totalPrice = 0.0; // You should set this based on your total price logic
  double getBalance() {
    return cashPaid - widget.totalPrice;
  }

  Future<void> completeAndSendReceipt() async {
    if (getBalance() >= 0) {
      // Construct the order details
      // ignore: unused_local_variable
      final String orderId = OrderManager().orderId;
      final double totalPrice = widget.totalPrice;
      final List<Product> products =
          Provider.of<CartProvider>(context, listen: false).cartItems;
      final double orderprofit = totalPrice -
          products
              .map((product) => product.buyingPrice ?? 0.0)
              .reduce((value, element) => value + element)-widget.sumOfTotalDiscounts;
      OrderDetails orderDetails = OrderDetails(
        orderId: orderId,
        totalPrice: totalPrice,
        products: products,
        completedAt: DateTime.now(),
        profit: orderprofit,
      );

     
      // Before adding the completed order, update the product quantities
      Provider.of<CartProvider>(context, listen: false).updateProductQuantities();

      // Add the completed order to the repository
      OrderRepository.addCompletedOrder(orderDetails);

      // Show confirmation dialog 
      showDialog(
        context: context,
        barrierDismissible: false, // Dialog will not close on tap outside
        builder: (BuildContext context) {
          // Automatically close the dialog after 5 seconds
          Future.delayed(const Duration(seconds: 1), () {
            Navigator.of(context).pop(true); // Close the dialog
          });
          return const AlertDialog(
            title: Icon(Icons.check_circle, color: Colors.green, size: 60),
            content: Text("Order completed successfully",
                textAlign: TextAlign.center),
          );
        },
      ).then((_) {
        // Clear the cart items and navigate back to the Sales screen
        setState(() {
          //cartItems.clear();
          Provider.of<CartProvider>(context, listen: false).cartItems.clear();
          OrderManager().orderId = '#';
          OrderManager().counter = 1;
        });
        // Clear any existing navigation stack and navigate to the Sales screen
        Provider.of<CartProvider>(context, listen: false).resetCart();
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => Sales(initialProducts: [])),
          (Route<dynamic> route) =>
              false, // This will remove all the routes below the Sales screen
        );
      });

      //await OrderManager().completeOrder();
    } else {
      // Handle insufficient balance...
    }
  }

  void navigateToSalesScreen() {
    // Clear any existing navigation stack and navigate to the Sales screen
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (context) => Sales(initialProducts: []),
      ),
      (Route<dynamic> route) =>
          true, // Remove all routes below the Sales screen
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Cash Payment"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 0.0 * 38.1, bottom: 0.0 * 38.1),
              padding: const EdgeInsets.all(16.0),
              width: 600,
              height: 550, // Increased height to accommodate new field
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.black, width: 2),
                image: DecorationImage(
                  image: const AssetImage("lib/assets/PaymentIcon.png"),
                  fit: BoxFit
                      .cover, // This is to ensure the image covers the whole container
                  colorFilter: ColorFilter.mode(
                    Colors.white.withOpacity(0.2), // 80% opacity
                    BlendMode
                        .dstATop, // This blend mode allows the image to show through the color filter
                  ),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Center(
                    child: Text(
                      "Cash Payment",
                      style: TextStyle(
                        color: Color.fromARGB(255, 4, 114, 187),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Text(
                        "Enter Ksh:",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(width: 30),
                      Container(
                        width: 200, // Adjust this width as needed
                        child: TextFormField(
                          controller: cashGivenController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          decoration: InputDecoration(
                            hintText: "Cash Given",
                            fillColor: const Color.fromARGB(
                                255, 255, 255, 255), // White background
                            filled: true,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(
                                  color: Colors.black,
                                  width: 2.0), // Black border with 2.0 width
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(
                                  color: Colors.black,
                                  width:
                                      2.0), // Same black border for the enabled state
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(
                                  color: Colors.black,
                                  width:
                                      2.0), // Same black border for the focused state
                            ),
                          ),
                          onChanged: (value) {
                            setState(() {
                              cashPaid = double.tryParse(value) ?? 0.0;
                            });
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 30), // Space between fields
                  Row(
                    children: [
                      const Text(
                        "Customer Phone:",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(width: 30),
                      Expanded(
                        child: TextFormField(
                          controller: customerPhoneController,
                          decoration: InputDecoration(
                            hintText: "Phone Number",
                            fillColor: Colors.white,
                            filled: true,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: Colors.black),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),

                  const SizedBox(height: 50), // Space for clarity
                  // Cash Paid

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text("Cash Paid: "),
                      Expanded(
                        child: Stack(
                          alignment: Alignment.bottomCenter,
                          children: [
                            Positioned(
                              bottom: 0,
                              left: 0,
                              right: 0,
                              child: Container(
                                height: 1,
                                color: Colors.black,
                              ),
                            ),
                            Text(
                              "$cashPaid",
                              style: const TextStyle(
                                  // Other styles as needed
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20), // Adjust the height for spacing

// Balance
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text("Balance: "),
                      Expanded(
                        child: Stack(
                          alignment: Alignment.bottomCenter,
                          children: [
                            Positioned(
                              bottom: 0,
                              left: 0,
                              right: 0,
                              child: Container(
                                height: 1,
                                color: Colors.black,
                              ),
                            ),
                            Text(
                              getBalance().toStringAsFixed(2),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                // Other styles as needed
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30), // Adjust the height for spacing

                  const SizedBox(height: 30),
                  const SizedBox(height: 30),
                  const Spacer(),

                  // Complete and Send Receipt Button
                  Center(
                    child: ElevatedButton(
                      onPressed: completeAndSendReceipt,
                      child: const Text("Complete and Send Receipt"),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.green,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: const BorderSide(color: Colors.black),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 0), // 2 cm space (assuming 1 cm = 10 pixels)
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class ProductOrder {
  final Product product;
  final int quantity;
  // Assuming you have a quantity field
  List<Product> _products = [];
  List<Product> get products => _products;
  List<Product> cartItems = [];
  ProductOrder({required this.product, required this.quantity});
}



class OrderManager {
  late String orderId = '#';
  int counter = 1;
  late final String orderNumber;

  // Constructor
  OrderManager() {
    //orderId = '#'; // Initial value for order ID
    if (orderId == '#' && counter >= 1) {
      String timestamp = DateTime.now().toUtc().toString();
      timestamp =
          timestamp.replaceAll(RegExp(r'[^0-9]'), ''); // Extract digits only
      timestamp = timestamp.substring(0, 14); // Take only the first 14 digits
      orderNumber = '#medrx-$timestamp';

  
      orderId = orderNumber;
    }
    counter += 1;
  }
}

class SalesHistoryClass {
  final String productName;
  int quantitySold;
  int currentStock;
  double unitPrice;
  double profit;

  SalesHistoryClass({
    required this.productName,
    required this.quantitySold,
    required this.currentStock,
    required this.unitPrice,
    required this.profit,
  });

  double get totalPrice => unitPrice * quantitySold;

  void updateSalesHistory(int soldQuantity) {
    quantitySold = soldQuantity; // Assign the value of soldQuantity to quantitySold
    currentStock -= soldQuantity;
  }
}

class SalesHistoryManager {
  List<SalesHistoryClass> salesHistory = [];
  final DatabaseHelper dbHelper = DatabaseHelper();

  Future<void> initializeSalesHistory() async {
    List<Product> products = await dbHelper.getProducts();
    for (var product in products) {
      var existingHistoryIndex = salesHistory.indexWhere(
          (history) => history.productName == product.productName);

      if (existingHistoryIndex == -1) {
        salesHistory.add(SalesHistoryClass(
          productName: product.productName,
          quantitySold: 0,
          currentStock: product.quantity,
          unitPrice: product.buyingPrice,
          profit: 0,
        ));
      }
    }
  }

  void updateHistoryForCompletedOrder(List<Product> orderedProducts) {
    for (var orderedProduct in orderedProducts) {
      var historyIndex = salesHistory.indexWhere(
          (h) => h.productName == orderedProduct.productName);

      if (historyIndex != -1) {
        salesHistory[historyIndex].updateSalesHistory(orderedProduct.soldQuantity); // Use soldQuantity
      } else {
        salesHistory.add(SalesHistoryClass(
          productName: orderedProduct.productName,
          quantitySold: orderedProduct.soldQuantity, // Use soldQuantity
          currentStock: orderedProduct.quantity - orderedProduct.soldQuantity,
          unitPrice: orderedProduct.buyingPrice,
          profit: orderedProduct.buyingPrice - orderedProduct.sellingPrice,
        ));
      }
    }
  }

  void updateSalesHistoryFromTopSellingProducts(List<Product> topSellingProducts) {
    for (var product in topSellingProducts) {
      var historyIndex = salesHistory.indexWhere(
          (h) => h.productName == product.productName);

      if (historyIndex != -1) {
        salesHistory[historyIndex].updateSalesHistory(product.soldQuantity); // Use soldQuantity
      } else {
        salesHistory.add(SalesHistoryClass(
          productName: product.productName,
          quantitySold: product.soldQuantity, // Use soldQuantity
          currentStock: product.quantity - product.soldQuantity,
          unitPrice: product.buyingPrice,
          profit: product.buyingPrice - product.sellingPrice,
        ));
      }
    }
  }
}
