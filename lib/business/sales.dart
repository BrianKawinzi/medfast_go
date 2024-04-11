import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:medfast_go/business/editproductpage.dart';
import 'package:medfast_go/main.dart';
import 'package:medfast_go/models/OrderDetails.dart';
import 'package:medfast_go/models/product.dart';
import 'package:flutter/services.dart';
import 'package:medfast_go/pages/bottom_navigation.dart';
import 'package:medfast_go/pages/home_screen.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:medfast_go/models/product.dart';
import 'package:medfast_go/data/DatabaseHelper.dart';

//import 'package:sms/sms.dart';


class CartProvider with ChangeNotifier {
  final List<Product> _cartItems = [];
  Map<int, int> _productQuantities = {};

  List<Product> get cartItems => _cartItems;
  Map<int, int> get productQuantities => _productQuantities;
  void add(Product product) {
    _cartItems.add(product);
    _productQuantities.update(product.id, (value) => value + 1,
        ifAbsent: () => 1);
    notifyListeners();
  }

  void remove(Product product) {
    // Assuming _cartItems is a list of Product objects
    final int index = _cartItems.indexWhere((p) => p.id == product.id);
    if (index != -1) {
      _cartItems.removeAt(index);
      // Assuming _productQuantities is a map with product.id as key and quantity as value
      if (_productQuantities.containsKey(product.id)) {
        final int currentQuantity = _productQuantities[product.id]!;
        if (currentQuantity > 1) {
          _productQuantities.update(product.id, (value) => value - 1);
        } else {
          _productQuantities.remove(product.id);
        }
      }
      notifyListeners();
    }
  }

  int getCartQuantity(Product product) {
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
  // void initState() {
  //   super.initState();
  //   _fetchProductsFromDatabase(); // Fetch products when the widget initializes
  // }

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
          var imageFile = File(product.image ?? '');
          return Dismissible(
            key: Key(product.id.toString()),
            child: Card(
              margin: const EdgeInsets.all(8.0),
              child: ListTile(
                title: Text(product.productName),
                subtitle: Align(
                  alignment: Alignment.topLeft,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Expiry Date: ${product.expiryDate}"),
                      Text('Price: ${product.buyingPrice}'),
                      // Add stock quantity information here
                      Text(
                        "${product.quantity} units",
                        style: TextStyle(
                          color: product.quantity > 10 ? Colors.green : Colors.red,
                        ),
                      ),
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
      backgroundColor: Colors.green,
      child: IconButton(
        icon: const Icon(
          Icons.add,
          color: Colors.white,
          size: 20,
        ),
        onPressed: () {
          setState(() {
            ProductNotifier().addProduct(product);
            // Assuming this method adds the product to the cart and updates the quantity
            _addToCart(product);
          });
        },
      ),
    ),
    // This SizedBox provides some spacing between the add button and the quantity text
    SizedBox(width: 8),
    // Displaying the quantity in the cart for this product
    Text(
                        '${Provider.of<CartProvider>(context, listen: true).getCartQuantity(product) == 0 ? "" : Provider.of<CartProvider>(context, listen: true).getCartQuantity(product)}',
                        style: TextStyle(fontSize: 18.0),
    ),
    // This SizedBox provides some spacing between the quantity text and the subtract button
    SizedBox(width: 8),
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
               onTap: () => _navigateToEditProduct(product),
                ),
              ),
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
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                  builder: (context) =>
                      BottomNavigation()), // Adjust with your HomePage widget
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
                color: Color.fromARGB(255, 20, 197, 4),
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
                          icon: Icon(Icons.shopping_cart,
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
                                  title: Text('Error'),
                                  content: Text(
                                      'The cart is empty!!\nAdd items and try again.'),
                                  actions: <Widget>[
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context)
                                            .pop(); // Close the dialog
                                      },
                                      child: Text('OK'),
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
                      SizedBox(
                          width:
                              8), // Add some spacing between the icon and text
                      Text(
                        '$cartItemCount items',
                        style: TextStyle(
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
              image: AssetImage(
                  'lib/assets/pharmacy-store.png'), // Replace with the actual path to your background image
              fit: BoxFit.cover,
              colorFilter: ColorFilter.mode(
                Color.fromARGB(255, 255, 255, 255)
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
                      borderSide: BorderSide(
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
                      padding: EdgeInsets.only(
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
                    contentPadding: EdgeInsets.fromLTRB(
                        20.5, 0, 4.0, 0), // Adjust right padding here
                  ),
                ),
              ),
              Expanded(child: _buildProductList()),
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: EdgeInsets.only(
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
                            title: Text('Error'),
                            content: Text(
                                'The cart is empty!!\nAdd items and try again.'),
                            actions: <Widget>[
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context)
                                      .pop(); // Close the dialog
                                },
                                child: Text('OK'),
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

  void _removeFromCart(Product product) {
    Provider.of<CartProvider>(context, listen: false).cartItems.remove(product);
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context as BuildContext).showSnackBar(SnackBar(
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

  @override
  void initState() {
    super.initState();
    aggregateProductData();
  }

  void aggregateProductData() {
    productQuantity = {};
    productPrice = {};
    for (var product in widget.cartItems) {
      productQuantity[product.productName] =
          (productQuantity[product.productName] ?? 0) + 1;

      // Check if sellingPrice is not null before assigning
      // ignore: unnecessary_null_comparison
      if (product.buyingPrice != null) {
        productPrice[product.productName] = product.buyingPrice;
      } else {
        // Handle the case when sellingPrice is null, for example, set to 0.0 or some default value
        productPrice[product.productName] = 0.0; // or some default value
      }
    }
  }

  void _removeItemFromCart(String productName) {
    setState(() {
      widget.cartItems
          .removeWhere((product) => product.productName == productName);
      aggregateProductData(); // Re-aggregate data after removal
    });
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
        if (productPrice[product.productName] == null) {
          print("Price for ${product.productName} is null");
        }
        if (productQuantity[product.productName] == null) {
          print("Quantity for ${product.productName} is null");
        }

        double price = productPrice[product.productName] ?? 0.0;
        int quantity = productQuantity[product.productName] ?? 0;
        totalPrice += price * quantity;
      }
      return totalPrice;
    }

    double calculateTotalPrice() {
      double totalPrice = 0.0;
      // Logic to calculate total price
      for (var product in widget.cartItems) {
        if (productPrice[product.productName] == null) {
          print("Price for ${product.productName} is null");
        }
        if (productQuantity[product.productName] == null) {
          print("Quantity for ${product.productName} is null");
        }

        double price = productPrice[product.productName] ?? 0.0;
        int quantity = productQuantity[product.productName] ?? 0;
        totalPrice += price * quantity;
      }
      return totalPrice;
    }

    double totalPrice = getTotalPrice();

    return Scaffold(
      appBar: AppBar(
        title: Text('Order ${OrderManager().orderId}'), // Random order number
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              // Add your search functionality here
            },
          ),
        ],
        toolbarTextStyle: const TextTheme(
          headline6: TextStyle(color: Colors.black),
        ).bodyText2,
        titleTextStyle: const TextTheme(
          headline6: TextStyle(color: Colors.black),
        ).headline6,
      ),
      body: Stack(
        alignment: Alignment.center,
        children: [
          Opacity(
            opacity: 0.2, // 20% transparency
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: 200.0,
              decoration: BoxDecoration(
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
                    Border.all(color: Colors.black, width: 2), // Black border
                borderRadius: BorderRadius.circular(
                    5), // Optional: if you want rounded corners
              ),
              padding: EdgeInsets.all(8),
              child: Column(
                mainAxisSize: MainAxisSize.min, // To fit the size to content
                mainAxisAlignment:
                    MainAxisAlignment.center, // Center vertically
                crossAxisAlignment:
                    CrossAxisAlignment.center, // Center horizontally
                children: [
                  Text(
                    'Total',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 16, // Adjust the font size as needed
                    ),
                  ),
                  Text(
                    'Ksh. ${totalPrice.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 16, // Adjust the font size as needed
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: 10,
            bottom: 10 + 1 * 38.1, // 1 cm above the bottom
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black, // Black background for the container
                borderRadius: BorderRadius.circular(
                    5), // Rounded corners for the container
              ),
              padding: EdgeInsets.all(
                  2), // Padding to create a border effect around the button
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  elevation: 10, // Elevation for the button
                  padding: EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 15), // Making the button a bit larger
                ),
                onPressed: () {
                  _showMiniScreen(); // Show the MiniScreen
                },
                child: Row(
                  mainAxisSize:
                      MainAxisSize.min, // To fit the row size to its children
                  children: [
                    Icon(Icons.shopping_bag,
                        color: Colors.yellow), // Sale icon (bag) in yellow
                    SizedBox(width: 8), // Space between icon and text
                    Text(
                      'Sale',
                      style: TextStyle(
                        color: Colors.black, // Black text color
                        fontWeight: FontWeight.bold, // Bold text
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
                60, // Adjust this value as needed to position above the total price container
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment
                  .end, // Keeps the column aligned to the right
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: 4), // Add horizontal padding
                  child: Center(
                    // Centers the text horizontally in the container
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
                  padding: EdgeInsets.all(8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.black,
                          backgroundColor:
                              Colors.white, // Text color (if you have text)
                        ),
                        onPressed: () {
                          // Add your action for the first button
                        },
                        child: Image.asset('lib/assets/no-barcode.png',
                            width: 30, height: 30), // Small image icon
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.black,
                          backgroundColor:
                              Colors.white, // Text color (if you have text)
                        ),
                        onPressed: () {
                          // Add your action for the second button
                        },
                        child: Image.asset('lib/assets/barcode.png',
                            width: 30, height: 30), // Small image icon
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
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Display the titles if the cart is not empty
                  if (widget.cartItems.isNotEmpty)
                    Container(
                      padding: EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Expanded(
                              child: Text('Item Name',
                                  textAlign: TextAlign.center)),
                          Expanded(
                              child: Text('Quantity',
                                  textAlign: TextAlign.center)),
                          Expanded(
                              child:
                                  Text('Price', textAlign: TextAlign.center)),
                          Expanded(
                              child:
                                  Text('Total', textAlign: TextAlign.center)),
                        ],
                      ),
                    ),
                  // Display each aggregated item's attributes
                  ...productQuantity.entries.map((entry) {
                    String productName = entry.key;
                    int quantity = entry.value;
                    double price = productPrice[productName] ?? 0.0;
                    double total = quantity * price;

                    return Container(
                      margin: EdgeInsets.symmetric(vertical: 2.0),
                      padding: EdgeInsets.symmetric(
                          vertical: 2.0,
                          horizontal: 8.0), // Reduced vertical padding
                      decoration: BoxDecoration(
                        border: Border.all(
                            color: Colors.black,
                            width: 3.0), // Increased border thickness
                        borderRadius: BorderRadius.circular(4.0),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Expanded(
                                  child: Text(productName,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold))),
                              Expanded(
                                  child: Text('$quantity',
                                      textAlign: TextAlign.center)),
                              Expanded(
                                  child: Text('$price',
                                      textAlign: TextAlign.center)),
                              Expanded(
                                  child: Text('$total',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold))),
                              IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
                                onPressed: () =>
                                    _removeItemFromCart(productName),
                              ),
                            ],
                          ),
                          Padding(
                            padding: EdgeInsets.only(top: 8.0),
                            child: Text(
                              'Expiry Date: ${widget.cartItems.firstWhere((product) => product.productName == productName).expiryDate}',
                              style: TextStyle(color: Colors.red),
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
        ],
      ),
    );
  }
}

class MiniScreen extends StatelessWidget {
  final VoidCallback onClose;

  MiniScreen({Key? key, required this.onClose, required this.totalPrice})
      : super(key: key);

  final double totalPrice;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        margin: EdgeInsets.only(bottom: 3.5 * 38.1),
        width: 600,
        height: 200,
        decoration: BoxDecoration(
          color: Color.fromARGB(255, 10, 171, 192),
          border: Border.all(color: Colors.black, width: 2),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildPaymentButton("Cash", 'lib/assets/cash.png', () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (BuildContext context) =>
                      CashPayment(totalPrice: totalPrice),
                ),
              );
            }),
            _buildPaymentButton("M-Pesa", 'lib/assets/MobilePay.jfif', () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MobilePayment(),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentButton(
      String text, String imagePath, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 170,
        height: 60,
        decoration: BoxDecoration(
          color: Color.fromARGB(255, 224, 220, 220),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              imagePath,
              width: 30,
              height: 30,
            ),
            SizedBox(width: 8),
            Text(
              text,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FullScreenPage extends StatelessWidget {
  final String title;
  final Widget child;

  FullScreenPage({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.white, // Set appbar background color to white
        iconTheme: IconThemeData(color: Colors.black), // Set back button color
      ),
      body: child,
    );
  }
}

class CashPayment extends StatefulWidget {
  @override
  final double totalPrice;
  String orderNumber = OrderManager().orderId;

  CashPayment({Key? key, required this.totalPrice}) : super(key: key);

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

      // // Create an OrderDetails instance
      // OrderDetails orderDetails = OrderDetails(
      //   totalPrice: totalPrice,
      //   products: products,
      //   completedAt: DateTime.now(),
      // );
      //create an order details instance
      OrderDetails orderDetails = OrderDetails(
        orderId: Random().nextInt(1000).toString(),
        totalPrice: totalPrice,
        products: products,
        completedAt: DateTime.now(),
      );

      // Add the completed order to the repository
      OrderRepository.addCompletedOrder(orderDetails);

      // Show confirmation dialog
      showDialog(
        context: context,
        barrierDismissible: false, // Dialog will not close on tap outside
        builder: (BuildContext context) {
          // Automatically close the dialog after 5 seconds
          Future.delayed(Duration(seconds: 5), () {
            Navigator.of(context).pop(true); // Close the dialog
          });
          return AlertDialog(
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
        title: Text("Cash Payment"),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
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
              margin: EdgeInsets.only(top: 0.0 * 38.1, bottom: 0.0 * 38.1),
              padding: EdgeInsets.all(16.0),
              width: 600,
              height: 550, // Increased height to accommodate new field
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.black, width: 2),
                image: DecorationImage(
                  image: AssetImage("lib/assets/PaymentIcon.png"),
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
                  Center(
                    child: Text(
                      "Cash Payment",
                      style: TextStyle(
                        color: Color.fromARGB(255, 4, 114, 187),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Text(
                        "Enter Ksh:",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(width: 30),
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
                              borderSide: BorderSide(
                                  color: Colors.black,
                                  width: 2.0), // Black border with 2.0 width
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                  color: Colors.black,
                                  width:
                                      2.0), // Same black border for the enabled state
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
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

                  SizedBox(height: 30), // Space between fields
                  Row(
                    children: [
                      Text(
                        "Customer Phone:",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(width: 30),
                      Expanded(
                        child: TextFormField(
                          controller: customerPhoneController,
                          decoration: InputDecoration(
                            hintText: "Phone Number",
                            fillColor: Colors.white,
                            filled: true,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Colors.black),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Spacer(),

                  SizedBox(height: 50), // Space for clarity
                  // Cash Paid
// Cash Paid
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text("Cash Paid: "),
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
                              style: TextStyle(
                                  // Other styles as needed
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20), // Adjust the height for spacing

// Balance
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text("Balance: "),
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
                              "${getBalance().toStringAsFixed(2)}",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                // Other styles as needed
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 30), // Adjust the height for spacing

                  SizedBox(height: 30),
                  SizedBox(height: 30),
                  Spacer(),

                  // Complete and Send Receipt Button
                  Center(
                    child: ElevatedButton(
                      onPressed: completeAndSendReceipt,
                      child: Text("Complete and Send Receipt"),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.green,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(color: Colors.black),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 0), // 2 cm space (assuming 1 cm = 10 pixels)
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MobilePayment extends StatefulWidget {
  @override
  _MobilePaymentState createState() => _MobilePaymentState();
}

class _MobilePaymentState extends State<MobilePayment> {
  TextEditingController cashGivenController = TextEditingController();
  TextEditingController customerPhoneController = TextEditingController();
  double cashPaid = 0.0;
  double totalPrice =
      0.0; // You should set this based on your total price logic

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Mobile Payment"),
        backgroundColor: const Color.fromRGBO(58, 205, 50, 1),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
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
              margin: EdgeInsets.only(top: 0.0 * 38.1, bottom: 0.0 * 38.1),
              padding: EdgeInsets.all(16.0),
              width: 600,
              height: 550, // Increased height to accommodate new field
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.black, width: 2),
                image: DecorationImage(
                  image: AssetImage("lib/assets/PaymentIcon.png"),
                  fit: BoxFit
                      .cover, // This is to ensure the image covers the whole container
                  colorFilter: ColorFilter.mode(
                    Colors.white.withOpacity(0.2), // 20% opacity
                    BlendMode
                        .dstATop, // This blend mode allows the image to show through the color filter
                  ),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 10),
                  Center(
                    child: Text(
                      "M-Pesa Payment",
                      style: TextStyle(
                        color: Color.fromARGB(58, 205, 50, 1),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.center, // Center the row contents
                    children: [
                      Container(
                        width: 200, // Adjust this width as needed
                        child: TextFormField(
                          controller: TextEditingController(
                              text:
                                  "Ksh. ${totalPrice.toString()}"), // Display "Ksh." followed by total price
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 32, // Make text bold
                          ), // Center align the text
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          decoration: InputDecoration(
                            hintText: "Total Price",
                            fillColor: Colors.green,
                            filled: true,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          readOnly:
                              true, // Make the field read-only since it's for display purposes
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 30), // Space between fields
                  Row(
                    children: [
                      Text(
                        "M-Pesa Code:",
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      SizedBox(width: 30),
                      Expanded(
                        child: TextFormField(
                          controller: customerPhoneController,
                          decoration: InputDecoration(
                            hintText: "Enter M-Pesa Code",
                            fillColor: Colors.white,
                            filled: true,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Colors.black),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Spacer(),
                  SizedBox(height: 10), // Space for clarity

                  // PaymentInfoDisplay(), // Before payment
                  PaymentInfoDisplay(
                      customerName: "John doe",
                      amountPaid: "Ksh. 500"), // After payment
                  Spacer(),

                  SizedBox(height: 50), // Space for clarity
                  // Cash Paid
// Cash Paid
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "Cash Paid: ",
                        style: TextStyle(
                          fontWeight: FontWeight.bold, // Make label text bold
                          fontSize:
                              16, // You can adjust the font size as needed
                        ),
                      ),
                      Expanded(
                        child: Stack(
                          alignment: Alignment.bottomCenter,
                          children: [
                            Positioned(
                              bottom: 0,
                              left: 0,
                              right: 0,
                              child: Container(
                                height: 2, // Increase the thickness of the line
                                color: Colors.black,
                              ),
                            ),
                            Text(
                              "$cashPaid",
                              style: TextStyle(
                                fontWeight:
                                    FontWeight.bold, // Make value text bold
                                fontSize:
                                    16, // You can adjust the font size as needed
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 20), // Adjust the height for spacing

// Balance
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "Balance: ",
                        style: TextStyle(
                          fontWeight: FontWeight.bold, // Make label text bold
                          fontSize:
                              16, // You can adjust the font size as needed
                        ),
                      ),
                      Expanded(
                        child: Stack(
                          alignment: Alignment.bottomCenter,
                          children: [
                            Positioned(
                              bottom: 0,
                              left: 0,
                              right: 0,
                              child: Container(
                                height: 2, // Increase the thickness of the line
                                color: Colors.black,
                              ),
                            ),
                            Text(
                              "${cashPaid - totalPrice}",
                              style: TextStyle(
                                fontWeight:
                                    FontWeight.bold, // Make value text bold
                                fontSize:
                                    16, // You can adjust the font size as needed
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  // SizedBox(height: 0), // Adjust the height for spacing

                  //SizedBox(height: 20),
                  SizedBox(height: 5),
                  Spacer(),

                  // Complete and Send Receipt Button
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        // Add your receipt sending logic here
                      },
                      child: Text("Complete and Send Receipt"),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.green,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(color: Colors.black),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 0), // 2 cm space (assuming 1 cm = 10 pixels)
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PaymentInfoDisplay extends StatelessWidget {
  final String customerName; // Placeholder for customer name
  final String amountPaid; // Placeholder for amount paid

  PaymentInfoDisplay({this.customerName = "-", this.amountPaid = "-"});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200, // Different width and height for an oval
      height: 120,
      alignment: Alignment.center, // Center the text inside the container
      decoration: BoxDecoration(
        color: Colors.transparent,
        // color: const Color.fromARGB(255, 200, 179, 179),
        borderRadius: BorderRadius.all(Radius.circular(60)), // Rounded corners
        border: Border.all(color: Colors.black, width: 2),
      ),
      child: Text(
        " $customerName, \n\n  $amountPaid",
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }
}

// class OrderDetails {
//   final String orderId = CashPayment(
//     totalPrice: 0,
//   ).orderNumber;
//   final double totalPrice;
//   final List<Product> products;
//   DateTime completedAt; // Add this line

//   OrderDetails({
//     required this.totalPrice,
//     required this.products,
//     required this.completedAt, // Initialize this in the constructor
//   });
// }

class ProductOrder {
  final Product product;
  final int quantity;
  // Assuming you have a quantity field
  List<Product> _products = [];
  List<Product> get products => _products;
  List<Product> cartItems = [];
  ProductOrder({required this.product, required this.quantity});
}

// Singleton class to manage the order number
// class OrderManager {
//   static final OrderManager _instance = OrderManager._internal();
//   late final int orderId;

//   factory OrderManager() {
//     return _instance;
//   }

//   OrderManager._internal() {
//     // Generate a random order number when the singleton is first created
//     orderId = Random().nextInt(1000);
//   }
// }

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

      // Check conditions before generating a new order number

      // Generate the timestamp part of the order ID
      orderId = orderNumber;
    }
    counter += 1;
  }
}
