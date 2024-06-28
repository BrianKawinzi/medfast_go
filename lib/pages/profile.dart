import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:medfast_go/pages/bottom_navigation.dart';

class PharmacyProfile extends StatefulWidget {
  const PharmacyProfile({Key? key}) : super(key: key);

  @override
  PharmacyProfileState createState() => PharmacyProfileState();
}

class PharmacyProfileState extends State<PharmacyProfile> {
  final TextEditingController pharmacyNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController countyController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final ImagePicker _imagePicker = ImagePicker();
  File? selectedImage;
  String selectedCounty = "";

  final List<String> kenyanCounties = [
    'Mombasa',
    'Kwale',
    'Kilifi',
    'Tana River',
    'Lamu',
    'Taita-Taveta',
    'Garissa',
    'Wajir',
    'Mandera',
    'Marsabit',
    'Isiolo',
    'Meru',
    'Tharaka-Nithi',
    'Embu',
    'Kitui',
    'Machakos',
    'Makueni',
    'Nyandarua',
    'Nyeri',
    'Kirinyaga',
    'Muranga',
    'Kiambu',
    'Turkana',
    'West Pokot',
    'Samburu',
    'Trans-Nzoia',
    'Uasin Gishu',
    'Elgeyo-Marakwet',
    'Nandi',
    'Baringo',
    'Laikipia',
    'Nakuru',
    'Narok',
    'Kajiado',
    'Kericho',
    'Bomet',
    'Kakamega',
    'Vihiga',
    'Bungoma',
    'Busia',
    'Siaya',
    'Kisumu',
    'Homa Bay',
    'Migori',
    'Kisii',
    'Nyamira',
    'Nairobi',
  ];

  @override
  void initState() {
    super.initState();
    _loadPharmacyDetails();
  }

  Future<void> _loadPharmacyDetails() async {
    final prefs = await SharedPreferences.getInstance();
    final pharmacyName = prefs.getString('pharmacy_name');
    final county = prefs.getString('county');
    final email = prefs.getString('user_email');

    setState(() {
      pharmacyNameController.text = pharmacyName ?? '';
      selectedCounty = county ?? '';
      countyController.text = selectedCounty;
      emailController.text = email ?? '';
    });

    final imagePath = prefs.getString('profilePicture');
    if (imagePath != null) {
      setState(() {
        selectedImage = File(imagePath);
      });
    }
  }

  void _handleSave() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('pharmacyName', pharmacyNameController.text);
    await prefs.setString('county', selectedCounty);
    await prefs.setString('email', emailController.text);

    if (selectedImage != null) {
      await prefs.setString('profilePicture', selectedImage!.path);
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType? keyboardType,
    void Function()? onTap,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      keyboardType: keyboardType,
      onTap: onTap,
      validator: validator,
    );
  }

  Widget _buildCountySelectionDialog() {
    return AlertDialog(
      title: const Text('Select County'),
      content: SingleChildScrollView(
        child: Column(
          children: kenyanCounties.map((county) {
            return ListTile(
              title: Text(county),
              onTap: () {
                Navigator.of(context).pop(county);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(58, 205, 50, 1),
        title: const Text(
          'Pharmacy Profile',
          style: TextStyle(
              fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        toolbarHeight: 80.0,
        leading: GestureDetector(
          onTap: () {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const BottomNavigation()),
            );
          },
          child: const Icon(Icons.arrow_back),
        ),
        actions: [
          TextButton(
            onPressed: _handleSave,
            child: const Text(
              'SAVE',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.always,
          child: Column(
            children: <Widget>[
              const SizedBox(height: 3),
              // Profile picture
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  GestureDetector(
                    onTap: () async {
                      final XFile? image = await _imagePicker.pickImage(
                          source: ImageSource.gallery);
                      if (image != null) {
                        setState(() {
                          selectedImage = File(image.path);
                        });
                      }
                    },
                    child: Container(
                      margin: const EdgeInsets.all(5),
                      width: 100.0,
                      height: 100.0,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 5.0),
                        color: Colors.grey,
                      ),
                      child: selectedImage != null
                          ? CircleAvatar(
                              radius: 45.0,
                              backgroundImage: FileImage(selectedImage!))
                          : const CircleAvatar(
                              radius: 45.0, backgroundColor: Colors.grey),
                    ),
                  ),
                  GestureDetector(
                    onTap: () async {
                      final XFile? image = await _imagePicker.pickImage(
                          source: ImageSource.gallery);
                      if (image != null) {
                        setState(() {
                          selectedImage = File(image.path);
                        });
                      }
                    },
                    child: Container(
                      margin: const EdgeInsets.only(right: 8, bottom: 8),
                      width: 30.0,
                      height: 30.0,
                      decoration: const BoxDecoration(
                          shape: BoxShape.circle, color: Colors.white),
                      child: const Icon(Icons.edit, color: Colors.green),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20.0),
              _buildTextField(
                  controller: pharmacyNameController, label: 'Pharmacy Name'),
              const SizedBox(height: 10),
              _buildTextField(
                controller: countyController,
                label: 'County*',
                onTap: () async {
                  final String? selected = await showDialog(
                    context: context,
                    builder: (context) => _buildCountySelectionDialog(),
                  );
                  if (selected != null) {
                    setState(() {
                      selectedCounty = selected;
                      countyController.text = selectedCounty;
                    });
                  }
                },
              ),
              const SizedBox(height: 10),
              _buildTextField(
                controller: emailController,
                label: 'Email*',
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Email is required';
                  } else if (!RegExp(
                          r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$')
                      .hasMatch(value)) {
                    return 'Invalid email format';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
