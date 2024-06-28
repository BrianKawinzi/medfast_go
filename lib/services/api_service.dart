import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'https://medrxapi.azurewebsites.net';

  Future<void> registerPharmacy(BuildContext context, pharmacy) async {
    final url = Uri.parse('$baseUrl/api/pharmacies?'
        'PharmacyName=${pharmacy.pharmacyName}&'
        'County=${pharmacy.county}&'
        'PhoneNumber=${pharmacy.phoneNumber}&'
        'Latitude=${pharmacy.latitude}&'
        'Longitude=${pharmacy.longitude}');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        final int pharmacyId = responseData['pharmacyId'];

        Navigator.pushNamed(context, '/signUp',
            arguments: {'pharmacyId': pharmacyId});
      } else {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        final dynamic validationErrors = responseData['validationErrors'] ?? {};

        if (validationErrors is Map<String, dynamic>) {
          throw Map<String, String>.from(validationErrors.map(
            (key, value) => MapEntry(key, value.toString()),
          ));
        } else if (validationErrors is String) {
          // Handle the case where validationErrors is a String
          print('Error registering pharmacy: $validationErrors');
          final snackBar = SnackBar(
            content:
                Text(validationErrors, style: TextStyle(color: Colors.white)),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          );

          ScaffoldMessenger.of(context).showSnackBar(snackBar);
          // throw the error after displaying the SnackBar
          throw {'error': validationErrors};
        } else if (validationErrors is List) {
          throw {
            'error': validationErrors.join('\n')
          }; // Handle the case where validationErrors is a List
        } else {
          print(
              'Failed to register pharmacy. Status code: ${response.statusCode}');
          print('Response body: ${response.body}');
          throw validationErrors; // Throw the exact errors received from the server
        }
      }
    } catch (error) {
      if (error is FormatException) {
        // Handle FormatException separately
        print('Caught FormatException: $error');
        final errorMessage =
            'A pharmacy with the same name and phone number already exists';
        final snackBar = SnackBar(
          content: Text(errorMessage, style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        );

        ScaffoldMessenger.of(context).showSnackBar(snackBar);
        // throw the error after displaying the SnackBar
        throw {'error': errorMessage};
      } else {
        print('Caught other error: $error');
        final snackBar = SnackBar(
          content: Text('$error', style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        );

        ScaffoldMessenger.of(context).showSnackBar(snackBar);
        // rethrow the error after displaying the SnackBar
        rethrow;
      }
    }
  }
}
