import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:medfast_go/models/pharmacy.dart';
import 'package:medfast_go/services/api_service.dart';

class RegisterPharmacyScreen extends StatefulWidget {
  @override
  _RegisterPharmacyScreenState createState() => _RegisterPharmacyScreenState();
}

class _RegisterPharmacyScreenState extends State<RegisterPharmacyScreen> {
  final _formKey = GlobalKey<FormState>();
  final _apiService = ApiService();

  String pharmacyName = '';
  String region = '';
  String city = '';
  String subCity = '';
  String landmark = '';
  String phoneNumber = '';

  // Variable to store location
  Position? pharmacyLocation;

  //loading state
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    // Fetch initial location when the screen loads
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled, notify the user.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Location services are disabled.'),
        ),
      );
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, notify the user.
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Location permissions are denied'),
          ),
        );
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Location permissions are permanently denied, we cannot request permissions.'),
        ),
      );
      return;
    }

    // When permissions are granted or already granted, get the current location.
    try {
      Position currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
      );

      setState(() {
        pharmacyLocation = currentPosition;
      });
    } catch (error) {
      print('Error obtaining location: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error obtaining location: $error'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: Text(
          'Register Pharmacy',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
          padding: EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Pharmacy Name',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the pharmacy name';
                    }
                    return null;
                  },
                  onSaved: (value) => pharmacyName = value ?? '',
                ),
                SizedBox(height: 10),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Region',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  onSaved: (value) => region = value ?? '',
                ),
                SizedBox(height: 10),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'City',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the city';
                    }
                    return null;
                  },
                  onSaved: (value) => city = value ?? '',
                ),
                SizedBox(height: 10),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'SubCity',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  onSaved: (value) => subCity = value ?? '',
                ),
                SizedBox(height: 10),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Landmark',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  onSaved: (value) => landmark = value ?? '',
                ),
                SizedBox(height: 10),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Phone Number',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the phone number';
                    }
                    return null;
                  },
                  onSaved: (value) => phoneNumber = value ?? '',
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
      
                      final pharmacy = Pharmacy(
                        pharmacyName: pharmacyName,
                        region: region,
                        city: city,
                        subCity: subCity,
                        landmark: landmark,
                        phoneNumber: phoneNumber,
                        latitude: pharmacyLocation?.latitude ?? 0.0,
                        longitude: pharmacyLocation?.longitude ?? 0.0,
                      );


                      //set loading state
                      setState(() {
                        isLoading = true;
                      });
      
                      // Register the pharmacy using the API service
                     try {
                      await _apiService.registerPharmacy(context, pharmacy);
                     } finally {

                      //Reset loading state
                      setState(() {
                        isLoading = false;
                      });
                     }
                    }
                  },
                  child: Text(
                    'Register',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.0,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    primary: Colors.green, // Change button color to green
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                if (pharmacyLocation != null)
                  Text(
                    'Location: Lat:${pharmacyLocation!.latitude}, Lon:${pharmacyLocation!.longitude}',
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              ],
            ),
          ),
        ),
        if (isLoading)
          Container(
            color: Colors.black54,
            child: Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
