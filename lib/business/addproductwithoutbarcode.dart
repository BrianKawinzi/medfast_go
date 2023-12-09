import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:medfast_go/pages/home_page.dart';

// Define a Product class to represent products
class Product {
  final String productName;
  final double buyingPrice;
  final double sellingPrice;
  final int quantity;
  final String unit;
  final String manufactureDate;
  final String expiryDate;
  final File? image;

  Product({
    required this.productName,
    required this.buyingPrice,
    required this.sellingPrice,
    required this.quantity,
    required this.unit,
    required this.manufactureDate,
    required this.expiryDate,
    this.image,
  });
}

// Create a global list to store products
List<Product> productsList = [];

void main() => runApp(AddProductApp());

class AddProductApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Add Product',
      theme: ThemeData(
        // Your theme settings here
      ),
      home: AddProductForm(),
    );
  }
}

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
  double _sellingPrice = 0.0;
  int _quantity = 0;
  String _unit = 'piece';

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      // Create a new Product object
      final newProduct = Product(
        productName: _productName,
        buyingPrice: _buyingPrice,
        sellingPrice: _sellingPrice,
        quantity: _quantity,
        unit: _unit,
        manufactureDate: _manufactureDateController.text,
        expiryDate: _expiryDateController.text,
        image: _image,
      );

      // Add the new product to the global list
      productsList.add(newProduct);

      // Clear the form
      setState(() {
        _image = null;
      });

      // You can also navigate back to the home page or do any other necessary actions
      // Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => HomePage()));
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Product Without Barcode'),
        backgroundColor: Colors.green[800],
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => HomePage(),
          ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Text(
                  'Add New Product',
                  style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold, color: Colors.green[800]),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 30.0),
                _buildTextField('Product Name', 'Please enter the product name'),
                _buildTextField('Buying Price', 'Please enter a valid buying price', isNumeric: true),
                _buildTextField('Selling Price', 'Please enter a valid selling price', isNumeric: true),
                _buildTextField('Quantity', 'Please enter a valid quantity', isNumeric: true),
                _buildDropdown(),
                _buildDatePicker(_manufactureDateController, 'Manufacture Date'),
                _buildDatePicker(_expiryDateController, 'Expiry Date'),
                SizedBox(height: 30.0),
                
                if (_image != null)
                  Container(
                    margin: EdgeInsets.only(bottom: 15.0),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.green[800]!),
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: Image.file(File(_image!.path)),
                  ),
                OutlinedButton(
                  onPressed: _pickImage,
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.green[800]!),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                  ),
                  child: Text('Capture Product Image', style: TextStyle(color: Colors.green[800])),
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
        ),
      ),
    );
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
            case 'Selling Price':
              _sellingPrice = double.tryParse(value!) ?? 0.0;
              break;
            case 'Quantity':
              _quantity = int.tryParse(value!) ?? 0;
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
        onSaved: (value) => _unit = value!,
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
}
