import 'package:flutter/material.dart';
import 'package:medfast_go/business/addproductwithoutbarcode.dart';
import 'package:medfast_go/pages/home_page.dart';


class Products extends StatefulWidget {
  @override
  _ProductsState createState() => _ProductsState();
}

class _ProductsState extends State<Products> {
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

  List<Map<String, dynamic>> products = [];

  void _showProductForm(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  // Add an item with barcode
                  // You can implement this logic here
                },
                style: ElevatedButton.styleFrom(
                  primary: Colors.blue,
                  textStyle: const TextStyle(fontSize: 20),
                  minimumSize: Size(150, 150), // Square button
                ),
                child: const Text('with Barcode'),
              ),
              SizedBox(width: 20), // Add spacing between buttons
              ElevatedButton(
                onPressed: () {
                  // Navigate to the '/productwithoutbarcode' route
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddProductApp(), 
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  primary: Colors.black,
                  textStyle: const TextStyle(fontSize: 20),
                  minimumSize: Size(150, 150), // Square button
                ),
                child: const Text('No Barcode'),
              ),
            ],
          ),
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
          return Card(
            margin: const EdgeInsets.all(8.0),
            child: ListTile(
              title: Text(product['medicineName'] ?? ''),
              subtitle: Text('Description: ${product['medicineDescription'] ?? ''}, Price: ${product['price'] ?? ''}'),
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
        title: const Text('Products'),
        centerTitle: true,
        backgroundColor: const Color.fromRGBO(58, 205, 50, 1),
        leading: GestureDetector(
          onTap: () {
            Navigator.of(context).pushReplacement(MaterialPageRoute(
              builder: (context) => const HomePage(),
            ));
          },
          child: const Icon(Icons.arrow_back),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              // Menu action
            },
          ),
        ],
      ),
      body: _buildProductList(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showProductForm(context);
        },
        backgroundColor: const Color.fromRGBO(58, 205, 50, 1),
        child: const Icon(Icons.add),
      ),
    );
  }
}
