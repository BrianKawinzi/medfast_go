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
          throw {
            'error': validationErrors
          }; // Handle the case where validationErrors is a String
        } else if (validationErrors is List) {
          throw {
            'error': validationErrors.join('\n')
          }; // Handle the case where validationErrors is a List
        } else {
          print(
              'Failed to register pharmacy. Status code: ${response.statusCode}');
          print('Response body: ${response.body}');
        }
      }
    } catch (error) {
      print('Error registering pharmacy: $error');

      final errorMessage = error is Map<String, dynamic>
          ? error.values.join('\n')
          : error is String
              ? error
              : 'Unexpected error occurred';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
        ),
      );

      rethrow;
    }
  }
}
