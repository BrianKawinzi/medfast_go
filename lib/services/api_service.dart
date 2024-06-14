import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:medfast_go/models/pharmacy.dart';
import 'package:medfast_go/pages/sign_up.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = 'https://medrxapi.azurewebsites.net';
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Future<void> registerPharmacy(BuildContext context, pharmacy) async {
  //   final url = Uri.parse('$baseUrl/api/pharmacies?'
  //       'PharmacyName=${pharmacy.pharmacyName}&'
  //       'County=${pharmacy.county}&'
  //       'PhoneNumber=${pharmacy.phoneNumber}&'
  //       'Latitude=${pharmacy.latitude}&'
  //       'Longitude=${pharmacy.longitude}');

  //   try {
  //     final response = await http.post(
  //       url,
  //       headers: {
  //         'Content-Type': 'application/json',
  //       },
  //     );

  //     if (response.statusCode == 200) {
  //       final Map<String, dynamic> responseData = jsonDecode(response.body);
  //       final int pharmacyId = responseData['pharmacyId'];

  //       Navigator.pushNamed(context, '/signUp',
  //           arguments: {'pharmacyId': pharmacyId});
  //     } else {
  //       final Map<String, dynamic> responseData = jsonDecode(response.body);
  //       final dynamic validationErrors = responseData['validationErrors'] ?? {};

  //       if (validationErrors is Map<String, dynamic>) {
  //         throw Map<String, String>.from(validationErrors.map(
  //           (key, value) => MapEntry(key, value.toString()),
  //         ));
  //       } else if (validationErrors is String) {
  //         // Handle the case where validationErrors is a String
  //         print('Error registering pharmacy: $validationErrors');
  //         final snackBar = SnackBar(
  //           content:
  //               Text(validationErrors, style: TextStyle(color: Colors.white)),
  //           backgroundColor: Colors.red,
  //           behavior: SnackBarBehavior.floating,
  //         );

  //         ScaffoldMessenger.of(context).showSnackBar(snackBar);
  //         // throw the error after displaying the SnackBar
  //         throw {'error': validationErrors};
  //       } else if (validationErrors is List) {
  //         throw {
  //           'error': validationErrors.join('\n')
  //         }; // Handle the case where validationErrors is a List
  //       } else {
  //         print(
  //             'Failed to register pharmacy. Status code: ${response.statusCode}');
  //         print('Response body: ${response.body}');
  //         throw validationErrors; // Throw the exact errors received from the server
  //       }
  //     }
  //   } catch (error) {
  //     if (error is FormatException) {
  //       // Handle FormatException separately
  //       print('Caught FormatException: $error');
  //       final errorMessage =
  //           'A pharmacy with the same name and phone number already exists';
  //       final snackBar = SnackBar(
  //         content: Text(errorMessage, style: TextStyle(color: Colors.white)),
  //         backgroundColor: Colors.red,
  //         behavior: SnackBarBehavior.floating,
  //       );

  //       ScaffoldMessenger.of(context).showSnackBar(snackBar);
  //       // throw the error after displaying the SnackBar
  //       throw {'error': errorMessage};
  //     } else {
  //       print('Caught other error: $error');
  //       final snackBar = SnackBar(
  //         content: Text('$error', style: TextStyle(color: Colors.white)),
  //         backgroundColor: Colors.red,
  //         behavior: SnackBarBehavior.floating,
  //       );

  //       ScaffoldMessenger.of(context).showSnackBar(snackBar);
  //       // rethrow the error after displaying the SnackBar
  //       rethrow;
  //     }
  //   }
  // }

  Future<void> registerPharmacy(BuildContext context, Pharmacy pharmacy) async {
    try {
      DocumentReference docRef = await _firestore.collection('pharmacies').add({
        'pharmacyName': pharmacy.pharmacyName,
        'county': pharmacy.county,
        'phoneNumber': pharmacy.phoneNumber,
        'latitude': pharmacy.latitude,
        'longitude': pharmacy.longitude,
      });
      String pharmacyId = docRef.id;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SignUpPage(pharmacyId: pharmacyId),
        ),
      );
    } catch (e) {
      print('Error registering pharmacy: $e');
      rethrow;
    }
  }

  Future<void> registerUser(String email, String password, String username,
      String phoneNumber, String pharmacyId) async {
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = userCredential.user;
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).set({
          'username': username,
          'phoneNumber': phoneNumber,
          'pharmacyId': pharmacyId,
        });
      }
    } catch (e) {
      print('Error registering user: $e');
      rethrow;
    }
  }

  Future<void> signInUser(
      BuildContext context, String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = userCredential.user;
      if (user != null) {
        String? token = await user.getIdToken();
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('jwt_token', token!);
        await prefs.setString('user_email', user.email ?? '');

        // Fetch additional user details
        final userData =
            await _firestore.collection('users').doc(user.uid).get();
        final pharmacyName = userData.data()?['pharmacyId'];
        await prefs.setString('pharmacy_name', pharmacyName);

        Navigator.of(context).pushReplacementNamed('/bottom');
      }
    } catch (e) {
      print('Error signing in user: $e');
      rethrow;
    }
  }
}
