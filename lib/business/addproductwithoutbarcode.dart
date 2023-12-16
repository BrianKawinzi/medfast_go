import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:medfast_go/data/DatabaseHelper.dart';
import 'package:medfast_go/models/product.dart';


class AddProductForm extends StatefulWidget {
  @override
  _AddProductFormState createState() => _AddProductFormState();
}

class _AddProductFormState extends State<AddProductForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _expiryDateController = TextEditingController();
  final TextEditingController _manufactureDateController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  File? _image;

  String _productName = '';
  double _buyingPrice = 0.0;
  String _unit = 'piece';

  DatabaseHelper _databaseHelper = DatabaseHelper(); // Initialize your database helper

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _captureImage() async {
    final XFile? capturedFile = await _picker.pickImage(source: ImageSource.camera);
    if (capturedFile != null) {
      setState(() {
        _image = File(capturedFile.path);
      });
    }
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final List<Product> products = await _databaseHelper.getProducts();
      int maxId = 0;
      for (final product in products) {
        if (product.id > maxId) {
          maxId = product.id;
        }
      }
      final newProductId = maxId + 1; // Generate a unique id

      final newProduct = Product(
        id: newProductId, // Set the unique id
        productName: _productName,
        medicineDescription: '', // Set an appropriate value if needed
        buyingPrice: _buyingPrice,
        image: _image != null ? _image!.path : null,
        expiryDate: _expiryDateController.text,
        manufactureDate: _manufactureDateController.text,
        unit: _unit,
      );

      // Insert the new product into the database
      final result = await _databaseHelper.insertProduct(newProduct);

      if (result != -1) {
        // Product was successfully inserted
        // Clear the form and show a success message if needed
        setState(() {
          _image = null;
          // Clear other form fields
          _formKey.currentState!.reset();
        });

        // Route to the '/product' screen
        Navigator.pushReplacementNamed(context, '/product');
      } else {
        // Error occurred while inserting the product
        // Show an error message if needed
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Error'),
              content: Text('Failed to insert the product into the database.'),
              actions: <Widget>[
                TextButton(
                  child: Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      }
    }
  }

  Future<void> _selectDate(BuildContext context, TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      controller.text = DateFormat('yyyy-MM-dd').format(picked);
    }
  }

  Widget _buildTextField(String label, String errorText, {bool isNumeric = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.green[800]),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.green[800]!, width: 2.0),
          ),
        ),
        keyboardType: isNumeric ? TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
        validator: (value) => value!.isEmpty ? errorText : null,
        onSaved: (value) {
          switch (label) {
            case 'Product Name':
              _productName = value!;
              break;
            case 'Buying Price':
              _buyingPrice = double.tryParse(value!) ?? 0.0;
              break;
          }
        },
      ),
    );
  }

  Widget _buildDropdown() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<String>(
        value: _unit,
        decoration: InputDecoration(
          labelText: 'Unit',
          labelStyle: TextStyle(color: Colors.green[800]),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.green[800]!, width: 2.0),
          ),
        ),
        items: <String>['piece', 'packet', 'bottle', 'sheet', 'tablet', 'set']
            .map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
        onChanged: (String? newValue) => setState(() => _unit = newValue!),
      ),
    );
  }

  Widget _buildDatePicker(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.green[800]),
          suffixIcon: Icon(Icons.calendar_today, color: Colors.green[800]),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.green[800]!, width: 2.0),
          ),
        ),
        readOnly: true,
        onTap: () => _selectDate(context, controller),
        validator: (value) => value!.isEmpty ? 'Please enter $label' : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Product Without Barcode'),
        backgroundColor: Colors.green[800],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: <Widget>[
            Text(
              'Add New Product',
              style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold, color: Colors.green[800]),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 30.0),
            _buildTextField('Product Name', 'Please enter the product name'),
            _buildTextField('Buying Price', 'Please enter a valid buying price', isNumeric: true),
            _buildDropdown(),
            _buildDatePicker(_manufactureDateController, 'Manufacture Date'),
            _buildDatePicker(_expiryDateController, 'Expiry Date'),
            SizedBox(height: 30.0),
            if (_image != null)
              GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return Dialog(
                        child: Container(
                          padding: EdgeInsets.all(16.0),
                          child: Image.file(_image!),
                        ),
                      );
                    },
                  );
                },
                child: Container(
                  margin: EdgeInsets.only(bottom: 15.0),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.green[800]!),
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: Image.file(_image!),
                ),
              ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: _captureImage,
                  style: ElevatedButton.styleFrom(
                    primary: Colors.green[800],
                    padding: EdgeInsets.symmetric(horizontal: 20.0),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                  ),
                  child: Text('Capture Image'),
                ),
                ElevatedButton(
                  onPressed: _pickImage,
                  style: ElevatedButton.styleFrom(
                    primary: Colors.green[800],
                    padding: EdgeInsets.symmetric(horizontal: 20.0),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                  ),
                  child: Text('Select Image'),
                ),
              ],
            ),
            SizedBox(height: 30.0),
            ElevatedButton(
              onPressed: _submitForm,
              style: ElevatedButton.styleFrom(
                primary: Colors.green[700],
                padding: EdgeInsets.symmetric(vertical: 15.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
              child: Text('Submit', style: TextStyle(fontSize: 18.0, color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
