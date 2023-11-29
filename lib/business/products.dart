import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
      // Get the total usable height excluding the app bar and status bar
      final double totalHeight = MediaQuery.of(context).size.height;
      final double statusBarHeight = MediaQuery.of(context).padding.top;
      final double appBarHeight = AppBar().preferredSize.height;
      final double maxSheetHeight = totalHeight - statusBarHeight - appBarHeight;
      final double height = MediaQuery.of(context).size.height*0.86;
      return ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: height, // Set the maximum height of the sheet
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _customInputField(medicineNameController, 'Medicine Name', 'Enter Medicine Name'),
                _customInputField(medicineDescriptionController, 'Medicine Description', 'Enter Medicine Description'),
                _customInputField(dosageFormController, 'Dosage Form', 'Enter Dosage Form'),
                _customInputField(strengthController, 'Strength', 'Enter Strength'),
                _customInputField(manufacturerController, 'Manufacturer', 'Enter Manufacturer'),
                _customInputField(categoryController, 'Category', 'Enter Category'),
                _customInputField(priceController, 'Price', 'Enter Price'),
                _datePickerField(manufactureDateController, 'Manufacture Date'),
                _datePickerField(expiryDateController, 'Expiry Date'),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20.0),
                  child: ElevatedButton(
                    onPressed: () {
                      _saveProduct();
                    },
                    style: ElevatedButton.styleFrom(
                      primary: const Color.fromRGBO(58, 205, 50, 1),
                      textStyle: const TextStyle(fontSize: 20),
                    ),
                    child: const Text('Save Product'),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

  void _saveProduct() {
    setState(() {
      products.add({
        'medicineName': medicineNameController.text,
        'medicineDescription': medicineDescriptionController.text,
        'dosageForm': dosageFormController.text,
        'strength': strengthController.text,
        'manufacturer': manufacturerController.text,
        'category': categoryController.text,
        'price': priceController.text,
        'manufactureDate': manufactureDateController.text,
        'expiryDate': expiryDateController.text,
      });

      // Clear the text fields after saving
      medicineNameController.clear();
      medicineDescriptionController.clear();
      dosageFormController.clear();
      strengthController.clear();
      manufacturerController.clear();
      categoryController.clear();
      priceController.clear();
      manufactureDateController.clear();
      expiryDateController.clear();
    });

    Navigator.pop(context); // Close the bottom sheet
  }

  Widget _customInputField(TextEditingController controller, String header, String hintText,
      [TextInputType keyboardType = TextInputType.text]) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          header,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20.0,
          ),
        ),
        const SizedBox(height: 8.0),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hintText,
            border: const OutlineInputBorder(),
            filled: true,
          ),
        ),
      ],
    );
  }

  Widget _datePickerField(TextEditingController controller, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20.0,
          ),
        ),
        const SizedBox(height: 8.0),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: label,
            border: const OutlineInputBorder(),
            filled: true,
          ),
          onTap: () async {
            DateTime? pickedDate = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(2000),
              lastDate: DateTime(2025),
              builder: (BuildContext context, Widget? child) {
                return Theme(
                  data: ThemeData.light().copyWith(
                    colorScheme: const ColorScheme.light().copyWith(
                      primary: const Color.fromRGBO(58, 205, 50, 1),
                    ),
                  ),
                  child: child!,
                );
              },
            );
            if (pickedDate != null) {
              String formattedDate = DateFormat('yyyy-MM-dd').format(pickedDate);
              controller.text = formattedDate;
            }
          },
        ),
      ],
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
              // Add other fields if needed
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
