import 'package:flutter/material.dart';
import 'package:medfast_go/data/DatabaseHelper.dart';
import 'package:medfast_go/models/product.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class EditProductPage extends StatefulWidget {
  final Product product;

  const EditProductPage({Key? key, required this.product}) : super(key: key);

  @override
  EditProductPageState createState() => EditProductPageState();
}

class EditProductPageState extends State<EditProductPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController buyingPriceController = TextEditingController();
  final TextEditingController sellingPriceController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();
  final TextEditingController expiryDateController = TextEditingController();

  File? _image;

  @override
  void initState() {
    super.initState();
    // Initialize the text controllers with the product data
    nameController.text = widget.product.productName;
    descriptionController.text = widget.product.medicineDescription;
    buyingPriceController.text = widget.product.buyingPrice.toString();
    sellingPriceController.text = widget.product.sellingPrice.toString();
    quantityController.text = widget.product.quantity.toString();
    expiryDateController.text = widget.product.expiryDate;
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.getImage(source: source);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  void _updateProduct() async {
    final dbHelper = DatabaseHelper();

    // Get the updated values from the text controllers
    final updatedName = nameController.text;
    final updatedDescription = descriptionController.text;
    final updatedBuyingPrice = double.parse(buyingPriceController.text);
    final updatedSellingPrice = double.parse(sellingPriceController.text);
    final updatedQuantity = int.parse(quantityController.text);
    final updatedExpiryDate = expiryDateController.text;

    // Create an updated Product object
    final updatedProduct = Product(
      id: widget.product.id,
      productName: updatedName,
      medicineDescription: updatedDescription,
      buyingPrice: updatedBuyingPrice,
      sellingPrice: updatedSellingPrice,
      quantity: updatedQuantity,
      expiryDate: updatedExpiryDate,
      manufactureDate: '',
      image: _image?.path, // Update the image path
      // Add other fields as needed
    );

    // Update the product in the database
    await dbHelper.updateProduct(updatedProduct);

    // Update the current widget with the new product data
    setState(() {
      widget.product.productName = updatedName;
      widget.product.medicineDescription = updatedDescription;
      widget.product.buyingPrice = updatedBuyingPrice;
      widget.product.sellingPrice = updatedSellingPrice;
      widget.product.quantity = updatedQuantity;
      widget.product.expiryDate = updatedExpiryDate;
      widget.product.image = _image?.path;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Product'),
        centerTitle: true,
        backgroundColor: const Color.fromRGBO(58, 205, 50, 1),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Display the current image
            _image != null
                ? Image.file(
                    _image!,
                    height: 100,
                    width: 100,
                    fit: BoxFit.cover,
                  )
                : const SizedBox.shrink(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () => _pickImage(ImageSource.gallery),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        Colors.green, // Set the button color to green
                  ),
                  child: const Text('Pick Image'),
                ),
                ElevatedButton(
                  onPressed: () => _pickImage(ImageSource.camera),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        Colors.green, // Set the button color to green
                  ),
                  child: const Text('Capture Image'),
                ),
              ],
            ),
            const SizedBox(
                height: 16), // Add padding between image and text fields
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Product Name',
                border: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.green, width: 2.0),
                ),
                contentPadding:
                    EdgeInsets.all(12.0), // Adjust padding as needed
              ),
            ),
            const SizedBox(height: 16), // Add padding between text fields
            TextField(
              controller: expiryDateController,
              decoration: const InputDecoration(
                labelText: 'Expiry Date',
                border: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.green, width: 2.0),
                ),
                contentPadding:
                    EdgeInsets.all(12.0), // Adjust padding as needed
              ),
            ),
            const SizedBox(height: 16), // Add padding between text fields
            TextField(
              controller: descriptionController,
              maxLines: 3, // Allow multiple lines
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.green, width: 2.0),
                ),
                contentPadding:
                    EdgeInsets.all(12.0), // Adjust padding as needed
              ),
            ),
            const SizedBox(height: 16), // Add padding between text fields
            TextField(
              controller: buyingPriceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Buying Price',
                border: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.green, width: 2.0),
                ),
                contentPadding:
                    EdgeInsets.all(12.0), // Adjust padding as needed
              ),
            ),
            const SizedBox(height: 16), // Add padding between text fields
            TextField(
              controller: sellingPriceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Selling Price',
                border: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.green, width: 2.0),
                ),
                contentPadding:
                    EdgeInsets.all(12.0), // Adjust padding as needed
              ),
            ),
            const SizedBox(height: 16), // Add padding between text fields
            TextField(
              controller: quantityController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Quantity',
                border: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.green, width: 2.0),
                ),
                contentPadding:
                    EdgeInsets.all(12.0), // Adjust padding as needed
              ),
            ),
            const SizedBox(height: 16), // Add padding between text fields
            ElevatedButton(
              onPressed: () {
                _updateProduct();
              },
              child: const Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }
}
