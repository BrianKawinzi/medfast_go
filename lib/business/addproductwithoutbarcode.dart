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
  double _buyingPrice = 0;
  double _sellingPrice = 0;
  String _unit = 'piece';
  int _quantity = 0;

  DatabaseHelper _databaseHelper = DatabaseHelper();

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

          if (_buyingPrice == 0.0 && _sellingPrice == 0.0||_sellingPrice < _buyingPrice) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Invalid Pricing'),
            content: const Text('The selling price must be greater than or equal to the buying price which must not be equal to 0'),
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
      return;
    }

      final List<Product> products = await _databaseHelper.getProducts();
      int maxId = 0;
      for (final product in products) {
        if (product.id > maxId) {
          maxId = product.id;
        }
      }
      final newProductId = maxId + 1;

      final newProduct = Product(
        id: newProductId,
        productName: _productName,
        medicineDescription: '',
        buyingPrice: _buyingPrice,
        sellingPrice: _sellingPrice,
        image: _image != null ? _image!.path : null,
        expiryDate: _expiryDateController.text,
        manufactureDate: _manufactureDateController.text,
        unit: _unit,
        quantity: _quantity, 
      );

      final result = await _databaseHelper.insertProduct(newProduct);

      if (result != -1) {
        setState(() {
          _image = null;
          _formKey.currentState!.reset();
        });
        Navigator.pushReplacementNamed(context, '/product');
      } else {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Error'),
              content: const Text('Failed to insert the product into the database.'),
              actions: <Widget>[
                TextButton(
                  child: const Text('OK'),
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
        initialValue: _getValueForLabel(label),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.green[800]),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.green[800]!, width: 2.0),
          ),
        ),
        keyboardType: isNumeric
            ? const TextInputType.numberWithOptions(decimal: true)
            : TextInputType.text,
        validator: (value) {
        if (value!.isEmpty) {
          return errorText;  
        }
        return null;  
      },
        onChanged: (value) => _updateValueForLabel(label, value), // Update the value on change
      onSaved: (value) => _updateValueForLabel(label, value!),
    ),
  );
}
  String _getValueForLabel(String label) {
  switch (label) {
    case 'Product Name':
      return _productName;
    case 'Buying Price':
      return _buyingPrice.toString();
    case 'Selling Price':
      return _sellingPrice.toString();
    default:
      return '';
  }
}

void _updateValueForLabel(String label, String value) {
  setState(() {
    switch (label) {
      case 'Product Name':
        _productName = value;
        break;
      case 'Buying Price':
        _buyingPrice = double.tryParse(value) ?? 0;
        break;
      case 'Selling Price':
        _sellingPrice = double.tryParse(value) ?? 0;
        break;
    }
  });
}

  Widget _buildDropdown() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          width: MediaQuery.of(context).size.width * 0.4,
          child: Padding(
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
          ),
        ),
        Container(
          width: MediaQuery.of(context).size.width * 0.4,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: TextFormField(
              decoration: InputDecoration(
                labelText: 'Quantity',
                labelStyle: TextStyle(color: Colors.green[800]),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.green[800]!, width: 2.0),
                ),
              ),
              keyboardType: TextInputType.number,
              validator: (value) => value!.isEmpty ? 'Please enter quantity' : null,
              onSaved: (value) {
                _quantity = int.tryParse(value!) ?? 0;
              },
            ),
          ),
        ),
      ],
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
            _buildTextField('Selling Price', 'Please enter a valid selling price', isNumeric: true),
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
                    backgroundColor: Colors.green[800],
                    padding: EdgeInsets.symmetric(horizontal: 20.0),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                  ),
                  child: Text('Capture Image'),
                ),
                ElevatedButton(
                  onPressed: _pickImage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[800],
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
                backgroundColor: Colors.green[700],
                padding: EdgeInsets.symmetric(vertical: 15.0),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
              ),
              child: Text(
                'Submit',
                style: TextStyle(fontSize: 18.0, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}