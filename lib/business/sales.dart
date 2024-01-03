import 'package:flutter/material.dart';
import 'package:medfast_go/models/product.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:medfast_go/models/product.dart';

class ProductNotifier with ChangeNotifier {
  List<Product> _products = [];

  List<Product> get products => _products;

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
  String hintText = 'Search'; // Placeholder text for search

  // Create a GlobalKey for the QR Code scanner
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  Barcode? result;
  QRViewController? controller;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  // Load products from the database
  Future<void> _loadProducts() async {
    setState(() {
      products = widget.initialProducts;
    });
  }

  // Filter products based on search query
  void _filterProducts(String query) {
    setState(() {
      if (query.isEmpty) {
        products = [];
        hintText = 'Search'; // Set placeholder text when there's no query
      } else {
        products = widget.initialProducts.where((product) {
          final productName = product.productName;
          return productName.toLowerCase().contains(query.toLowerCase());
        }).toList();
        hintText = ''; // Clear placeholder text when there's a query
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sales'),
        centerTitle: true,
        backgroundColor: const Color.fromRGBO(58, 205, 50, 1),
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: TextField(
                controller: searchController,
                onChanged: _filterProducts,
                decoration: InputDecoration(
                  hintText: hintText,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  prefixIcon: const Icon(Icons.search, color: Colors.black, size: 30, semanticLabel: 'Search Icon'),
                  suffixIcon: GestureDetector(
                    onTap: () {
                      // Open barcode scanner here
                      _openBarcodeScanner();
                    },
                    child: const Icon(Icons.qr_code_scanner, color: Colors.black, size: 30, semanticLabel: 'QR Code Scanner'),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20.0),
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: ElevatedButton(
              onPressed: () {
                // Add your action here when the button is clicked
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
                style: TextStyle(fontSize: 25, color: Colors.black, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Function to open the barcode scanner
  Future<void> _openBarcodeScanner() async {
    try {
      final status = await Permission.camera.request();
      if (status.isGranted) {
        Navigator.push(
          context,
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
        throw PlatformException(code: 'PERMISSION_DENIED', message: 'Camera permission is required.');
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
}
