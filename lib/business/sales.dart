import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:medfast_go/business/editproductpage.dart';
import 'package:medfast_go/models/product.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:medfast_go/models/product.dart';
import 'package:medfast_go/data/DatabaseHelper.dart';

List<Product> cartItems = [];

class ProductNotifier with ChangeNotifier {
  List<Product> _products = [];
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
  String hintText = 'Search'; // Placeholder text for search
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
          final productName = product.productName;
          return productName.toLowerCase().contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  void _navigateToEditProduct(Product product) {
    Navigator.of(context as BuildContext).push(_createRoute(product));
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
      return ListView.builder(
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
                      Text('Description: ${product.medicineDescription}'),
                      Text('Price: ${product.buyingPrice}'),
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
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: Colors.green,
                      child: Align(
                        alignment: Alignment.center,
                        child: IconButton(
                          icon: Icon(
                            Icons.add,
                            color: Colors.white,
                            size: 20,
                            // You can adjust the size of the add icon here
                          ),
                          onPressed: () {
                            setState(() {
                              cartItemCount++;
                              // Add the product to the cart
                              _addToCart(product);
                            });
                          },
                        ),
                      ),
                    ),
                    SizedBox(width: 8), // Adjust the spacing between buttons
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: Colors.red,
                      child: Align(
                        alignment: Alignment.center,
                        child: IconButton(
                          icon: Icon(
                            Icons.remove,
                            color: Colors.white,
                            size: 20,
                            // You can adjust the size of the minus icon here
                          ),
                          onPressed: () {
                            if (_isProductInCart(product)) {
                              setState(() {
                                cartItemCount--;
                                // Remove the product from the cart
                                _removeFromCart(product);
                              });
                            } else {
                              // Display an error message to the user
                              _showErrorMessage("Item not in cart");
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                onTap: () => _navigateToEditProduct(product),
              ),
            ),
          );
        },
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

  int cartItemCount = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sales'),
        centerTitle: true,
        backgroundColor: const Color.fromRGBO(58, 205, 50, 1),
        actions: [
          // Cart button with icon and item count
          Padding(
            padding: const EdgeInsets.all(5.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.black),
                borderRadius: BorderRadius.circular(5),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.shopping_cart,
                          color: Colors.black,
                        ),
                        onPressed: () {
                          // Add your logic for navigating to the cart or showing a cart dialog
                        },
                      ),
                      // Display the number of items in the cart
                      Text(
                        '$cartItemCount items',
                        style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 20),
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
                'lib/assets/pharmacy-store.png', // Replace with the actual path to your background image
              ),
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
                    suffixIcon: GestureDetector(
                      onTap: () {
                        // Open barcode scanner here
                        _openBarcodeScanner();
                      },
                      child: Image.asset(
                        'lib/assets/bar-code.png', // Replace with the actual path to your custom barcode image
                        width: 20,
                        height: 20,
                      ),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 20.5),
                  ),
                ),
              ),
              Expanded(child: _buildProductList()),
Align(
  alignment: Alignment.bottomCenter,
  child: Padding(
    padding: EdgeInsets.only(bottom: 0.25 * 150 / 2.54), // Adjusted bottom padding
    child: ElevatedButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) =>
                OrderConfirmationScreen(cartItems: cartItems),
          ),
        );
      },
      style: ElevatedButton.styleFrom(
        primary: const Color.fromRGBO(114, 194, 117, 1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        side: const BorderSide(color: Colors.black, width: 2.0),
        padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 10),
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
    return cartItems.contains(product);
  }

  void _removeFromCart(Product product) {
    cartItems.remove(product);
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context as BuildContext).showSnackBar(SnackBar(
      content: Text('Item is not added to the cart!'),
      duration: Duration(seconds: 2),
    ));
  }

  void _addToCart(Product product) {
    if (!_isProductInCart(product)) {
      cartItems.add(product);
    }
  }
}


class OrderConfirmationScreen extends StatefulWidget {
  final List<Product> cartItems;

  OrderConfirmationScreen({Key? key, required this.cartItems})
      : super(key: key);

  @override
  _OrderConfirmationScreenState createState() => _OrderConfirmationScreenState();
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
      productQuantity[product.productName] = (productQuantity[product.productName] ?? 0) + 1;
      
      // Check if sellingPrice is not null before assigning
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
      widget.cartItems.removeWhere((product) => product.productName == productName);
      aggregateProductData(); // Re-aggregate data after removal
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

  double totalPrice = getTotalPrice();


    return Scaffold(
      appBar: AppBar(
        title: Text('Order #${Random().nextInt(1000)}'), // Random order number
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),   actions: [
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
            opacity: 0.2,  // 20% transparency
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
      border: Border.all(color: Colors.black, width: 2), // Black border
      borderRadius: BorderRadius.circular(5), // Optional: if you want rounded corners
    ),
    padding: EdgeInsets.all(8),
    child: Column(
      mainAxisSize: MainAxisSize.min, // To fit the size to content
      mainAxisAlignment: MainAxisAlignment.center, // Center vertically
      crossAxisAlignment: CrossAxisAlignment.center, // Center horizontally
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
      borderRadius: BorderRadius.circular(5), // Rounded corners for the container
    ),
    padding: EdgeInsets.all(2), // Padding to create a border effect around the button
    child: ElevatedButton(
      style: ElevatedButton.styleFrom(
        primary: Colors.green,
        elevation: 10, // Elevation for the button
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15), // Making the button a bit larger
      ),
      onPressed: () {
        ;// Add your action for the sale button
      },
      child: Row(
        mainAxisSize: MainAxisSize.min, // To fit the row size to its children
        children: [
          Icon(Icons.shopping_bag, color: Colors.yellow), // Sale icon (bag) in yellow
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
  bottom: 10 + 60, // Adjust this value as needed to position above the total price container
  child: Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.end, // Keeps the column aligned to the right
    children: [
      Container(
        padding: EdgeInsets.symmetric(horizontal: 8), // Add horizontal padding
        child: Center( // Centers the text horizontally in the container
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
                primary: Colors.white, // White background color for the button
                onPrimary: Colors.black, // Text color (if you have text)
              ),
              onPressed: () {
                // Add your action for the first button
              },
              child: Image.asset('lib/assets/bar-code.png', width: 30, height: 30), // Small image icon
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                primary: Colors.white, // White background color for the button
                onPrimary: Colors.black, // Text color (if you have text)
              ),
              onPressed: () {
                // Add your action for the second button
              },
              child: Image.asset('lib/assets/bar-code.png', width: 30, height: 30), // Small image icon
            ),
          ],
        ),
      ),
    ],
  ),
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
                          Expanded(child: Text('Item Name', textAlign: TextAlign.center)),
                          Expanded(child: Text('Quantity', textAlign: TextAlign.center)),
                          Expanded(child: Text('Price', textAlign: TextAlign.center)),
                          Expanded(child: Text('Total', textAlign: TextAlign.center)),
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
                        padding: EdgeInsets.symmetric(vertical: 2.0, horizontal: 8.0), // Reduced vertical padding
                        decoration: BoxDecoration(
                        border: Border.all(color: Colors.black, width: 3.0), // Increased border thickness
                        borderRadius: BorderRadius.circular(4.0),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Expanded(child: Text(productName, textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold))),
                              Expanded(child: Text('$quantity', textAlign: TextAlign.center)),
                              Expanded(child: Text('$price', textAlign: TextAlign.center)),
                              Expanded(child: Text('$total', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold))),
                              IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _removeItemFromCart(productName),
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

  MiniScreen({Key? key, required this.onClose}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 300, // Set your desired width
        height: 200, // Set your desired height
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Mini Screen Content"),
            ElevatedButton(
              onPressed: onClose,
              child: Text("Close"),
            ),
          ],
        ),
      ),
    );
  }
}
