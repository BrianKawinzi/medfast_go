import 'package:flutter/material.dart';
import 'package:medfast_go/pages/home_page.dart';

class PharmacyProfile extends StatefulWidget {
  const PharmacyProfile({Key? key}) : super(key: key);

  @override
  PharmacyProfileState createState() => PharmacyProfileState();
}

class PharmacyProfileState extends State<PharmacyProfile> {
  final TextEditingController pharmacyNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController countyController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String selectedCounty = "";
  final ImagePicker _imagePicker =
      ImagePicker(); // Create an instance of ImagePicker
  File? selectedImage;

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
    // Add all the Kenyan counties here
  ];

  String? validatePhoneNumber(String value) {
    if (value.isEmpty) {
      return 'Phone number is required';
    } else if (!RegExp(r'^[0-9]{10}$').hasMatch(value)) {
      return 'Invalid phone number format';
    }
    return null;
  }

  // Function to handle the save action
  void _handleSave() async {
    // Get an instance of SharedPreferences
    final prefs = await SharedPreferences.getInstance();

    // Save user details
    await prefs.setString('pharmacyName', pharmacyNameController.text);
    await prefs.setString('county', selectedCounty);
    await prefs.setString('email', emailController.text);
    await prefs.setString('phone', phoneController.text);

    if (selectedImage != null) {
      await prefs.setString('profilePicture', selectedImage!.path);
    }
  }

  @override
  void initState() {
    super.initState();

    SharedPreferences.getInstance().then((prefs) {
      setState(() {
        pharmacyNameController.text = prefs.getString('pharmacyName') ?? '';
        selectedCounty = prefs.getString('county') ?? '';
        countyController.text = selectedCounty; // Set the initial value
        emailController.text = prefs.getString('email') ?? '';
        phoneController.text = prefs.getString('phone') ?? '';

        // Load the profile picture path or use any other suitable method
        final imagePath = prefs.getString('profilePicture');
        if (imagePath != null) {
          setState(() {
            selectedImage = File(imagePath);
          });
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(58, 205, 50, 1),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                const Text(
                  'Pharmacy Profile',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                TextButton(
                  onPressed: _handleSave, // Call the save function
                  child: const Text(
                    'SAVE',
                    style: TextStyle(
                      color: Colors.white, // Customize text color
                      fontWeight: FontWeight.bold, // Customize text style
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 5), // Add spacing
            const Text(
              'PHARMACY INFO',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        centerTitle: true,
        toolbarHeight: 80.0,
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
                        if (kDebugMode) {
                          print('Selected Image: ${image.path}');
                        }
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
                        border: Border.all(
                          color: Colors.white,
                          width: 5.0,
                        ),
                        color: Colors.grey,
                      ),
                      child: selectedImage != null
                          ? CircleAvatar(
                              radius: 45.0,
                              backgroundImage: FileImage(selectedImage!),
                            )
                          : Container(),
                    ),
                  ),
                  GestureDetector(
                    onTap: () async {
                      final XFile? image = await _imagePicker.pickImage(
                          source: ImageSource.gallery);
                      if (image != null) {
                        if (kDebugMode) {
                          print('Selected Image: ${image.path}');
                        }
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
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.edit,
                          color: Colors.green,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20.0), // Add spacing
              // Add Form with fields for Pharmacy Name, County, Email, and Phone
              Form(
                child: Column(
                  children: <Widget>[
                    //Pharmacy Textfield
                    _buildTextField(
                      controller: pharmacyNameController,
                      label: 'Pharmacy Name',
                    ),

                    const SizedBox(height: 10),

                    //county textfield
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

                    //email textfield
                    _buildTextField(
                      controller: emailController,
                      label: 'Email*',
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Enter a valid email address';
                        } else if (!RegExp(
                                r'^[\w-]+(\.[\w-]+)*@[\w-]+(\.[\w-]+)+$')
                            .hasMatch(value)) {
                          return 'Enter a valid email address';
                        }
                        return null; // Return null if the input is valid
                      },
                    ),
                    const SizedBox(height: 10),

                    //phone textfield
                    _buildTextField(
                      controller: phoneController,
                      label: 'Phone*',
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Phone number is required';
                        } else if (!RegExp(r'^\+\d{1,4}\s?\d+$')
                            .hasMatch(value)) {
                          return 'Invalid phone number format';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
        border: OutlineInputBorder(
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.error,
          ),
        ),
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
}
