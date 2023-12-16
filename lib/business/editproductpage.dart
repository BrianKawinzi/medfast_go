import 'package:flutter/material.dart';
import 'package:medfast_go/data/DatabaseHelper.dart';
import 'package:medfast_go/models/product.dart';

class EditProductPage extends StatefulWidget {
  final Product product;

  EditProductPage({required this.product});

  @override
  _EditProductPageState createState() => _EditProductPageState();
}

class _EditProductPageState extends State<EditProductPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController priceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initialize the text controllers with the product data
    nameController.text = widget.product.productName ?? '';
    descriptionController.text = widget.product.medicineDescription ?? '';
    priceController.text = widget.product.buyingPrice.toString() ?? '';
  }

  void _updateProduct() async {
    final dbHelper = DatabaseHelper();

    // Get the updated values from the text controllers
    final updatedName = nameController.text;
    final updatedDescription = descriptionController.text;
    final updatedPrice = double.parse(priceController.text);

    // Create an updated Product object
    final updatedProduct = Product(
      id: widget.product.id,
      productName: updatedName,
      medicineDescription: updatedDescription,
      buyingPrice: updatedPrice,
      expiryDate: '',
      manufactureDate: '',
      // Add other fields as needed
    );

    // Update the product in the database
    await dbHelper.updateProduct(updatedProduct);

    // Navigate back to the previous screen
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Product'),
        centerTitle: true,
        backgroundColor: Color.fromRGBO(58, 205, 50, 1),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: 'Product Name'),
            ),
            TextField(
              controller: descriptionController,
              decoration: InputDecoration(labelText: 'Description'),
            ),
            TextField(
              controller: priceController,
              decoration: InputDecoration(labelText: 'Price'),
              keyboardType: TextInputType.number,
            ),
            ElevatedButton(
              onPressed: () {
                _updateProduct();
              },
              child: Text('Save Changes'),
            
            ),
          ],
        ),
      ),
    );
  }
}
