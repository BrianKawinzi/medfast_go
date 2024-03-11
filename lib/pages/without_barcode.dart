// import 'dart:io';

// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:medfast_go/business/products.dart';
// import 'package:medfast_go/data/DatabaseHelper.dart';
// import 'package:medfast_go/models/product.dart';
// import 'package:medfast_go/pages/components/calendar_tf.dart';
// import 'package:medfast_go/pages/components/my_button.dart';
// import 'package:medfast_go/pages/components/normal_tf.dart';


// class WithoutBar extends StatefulWidget {
//   const WithoutBar({super.key});

  

//   @override
//   State<WithoutBar> createState() => _WithoutBarState();
// }

// class _WithoutBarState extends State<WithoutBar> {

//   //controllers
//   final _formKey = GlobalKey<FormState>();
//   final nameController = TextEditingController();
//   final bpController = TextEditingController();
//   final spController = TextEditingController();
//   final quantityController = TextEditingController();
//   final unitController = TextEditingController();
//   final mdController = TextEditingController();
//   final edController = TextEditingController();

//   //other variables
//   final ImagePicker _picker = ImagePicker();
//   File? _image;

//   final DatabaseHelper _databaseHelper = DatabaseHelper();

//   //capture method
//   Future<void> _captureImage() async {
//     final XFile? capturedFile = await _picker.pickImage(source: ImageSource.camera);
//     if (capturedFile != null) {
//       setState(() {
//         _image = File(capturedFile.path);
//       });
//     }
//   }

//   //pick image method
//   Future<void> _pickImage() async {
//     final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
//     if (pickedFile != null) {
//       setState(() {
//         _image = File(pickedFile.path);
//       });
//     }
//   }

//   //select date method
//   Future<void> _selectDate(TextEditingController controller) async {
//     final DateTime? picked = await showDatePicker(
//       context: context, 
//       initialDate: DateTime.now(), 
//       firstDate: DateTime(2000), 
//       lastDate: DateTime(3000),
//     );

//     if (picked != null) {
//       controller.text = picked.toString();
//     }
//   }

//   //submit method
//   void submit() async {
//     if(_formKey.currentState!.validate()) {
//       _formKey.currentState!.save();

//       //converting data types
//       double buyingPrice = double.tryParse(bpController.text) ?? 0.0;
//       double sellingPrice = double.tryParse(spController.text) ?? 0.0;
//       int quantity = int.tryParse(quantityController.text) ?? 0;

//       final List<Product> products = await _databaseHelper.getProducts();
//       int maxId = 0;
//       for (final product in products) {
//         if (product.id > maxId) {
//           maxId = product.id;
//         }
//       }

//       final newProductId = maxId + 1;

//       final newProduct = Product(
//         id: newProductId, 
//         productName: nameController.text, 
//         medicineDescription: '', 
//         buyingPrice: buyingPrice, 
//         sellingPrice: sellingPrice, 
//         quantity: quantity, 
//         expiryDate: edController.text, 
//         manufactureDate: mdController.text,
//         unit: unitController.text
//       );

//       final result = await _databaseHelper.insertProduct(newProduct); 

//       if (result != -1) {
//         setState(() {
//           _image = null;
//           _formKey.currentState!.reset();
//         });
        
//         Navigator.of(context).pushReplacement(MaterialPageRoute(
//           builder: (context) => const Products(productName: ''),
//         ));
//       } else {
//         showDialog(
//           context: context,
//           builder: (BuildContext context) {
//             return AlertDialog(
//               title: Text('Error'),
//               content: Text('Failed to insert the product into the database.'),
//               actions: <Widget>[
//                 TextButton(
//                   child: Text('OK'),
//                   onPressed: () {
//                     Navigator.of(context).pop();
//                   },
//                 ),
//               ],
//             );
//           },
//         );
//       }
//     }
//   }
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.grey[300],
//       appBar: AppBar(
//         backgroundColor: const Color.fromARGB(255, 16, 253, 44),
//         elevation: 10.0,
//         title: const Text('Add Product'),
//         centerTitle: true,
//         leading: GestureDetector(
//           onTap: () {
//             Navigator.of(context).pushReplacement(MaterialPageRoute(
//               builder: (context) => const Products(productName: ''),
//             ));
//           },
//           child: const Icon(Icons.arrow_back_ios_rounded),
//         ),
//       ),
//       body: SafeArea(
//         child: Center(
//           child: SingleChildScrollView(
//             child: Column(
//               children: [

//                 //name textfield
//                 normalTF(
//                   controller: nameController, 
//                   hintText: 'Product Name', 
//                   obscureText: false
//                 ),
//                 const SizedBox(height: 10),

//                 //buying tf
//                 normalTF(
//                   controller: bpController, 
//                   hintText: 'Buying Price', 
//                   obscureText: false
//                 ),
//                 const SizedBox(height: 10),

//                 //selling tf
//                 normalTF(
//                   controller: spController, 
//                   hintText: 'Selling Price', 
//                   obscureText: false
//                 ),
//                 const SizedBox(height: 10),

//                 //quantity
//                 normalTF(
//                   controller: quantityController, 
//                   hintText: 'Quantity', 
//                   obscureText: false
//                 ),
//                 const SizedBox(height: 10),

//                 //unit
//                 normalTF(
//                   controller: unitController, 
//                   hintText: 'Unit', 
//                   obscureText: false,
//                 ),
//                 const SizedBox(height: 10),

//                 //manufacture date
//                 CalendarTF(
//                   controller: mdController, 
//                   hintText: 'Manufacture Date', 
//                   obscureText: false,
//                   suffixIcon: InkWell(
//                     onTap: () => _selectDate(mdController),
//                     child: const Icon(Icons.calendar_today),
//                   ),
//                 ),
//                 const SizedBox(height: 10),

//                 //expiry date
//                 CalendarTF(
//                   controller: edController, 
//                   hintText: 'Expiry Date', 
//                   obscureText: false,
//                   suffixIcon: InkWell(
//                     onTap: () => _selectDate(edController),
//                     child: const Icon(Icons.calendar_today),
//                   ),
//                 ),
//                 const SizedBox(height: 10),


//                 //select and capture image option
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                   children: [
//                     ElevatedButton(
//                       onPressed: _captureImage, 
//                       style: ElevatedButton.styleFrom(
//                         primary: Colors.green,
//                       ),
//                       child: const Text('Capture Image')
//                     ),

//                     ElevatedButton(
//                       onPressed: _pickImage,
//                       style: ElevatedButton.styleFrom(
//                         primary: Colors.green,
//                       ),
//                       child: const Text('Select Image')
//                     ),
//                   ],
//                 ),


//                 const SizedBox(height: 20),


//                 MyButton(
//                   onTap: submit, 
//                   buttonText: 'Submit'
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }