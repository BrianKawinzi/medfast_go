import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'https://medrxapi.azurewebsites.net'; 

  Future<void> registerPharmacy(BuildContext context, pharmacy) async {
    final url = Uri.parse(
    '$baseUrl/api/pharmacies?'
     'PharmacyName=${pharmacy.pharmacyName}&'
      'Region=${pharmacy.region}&'
      'City=${pharmacy.city}&'
      'SubCity=${pharmacy.subCity}&'
      'Landmark=${pharmacy.landmark}&'
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
         print('Pharmacy registered successfully');
        final Map<String, dynamic> responseData = jsonDecode(response.body);
      final int pharmacyId = responseData['pharmacyId']; // Adjust the key based on your API response.

      print('Pharmacy registered successfully with ID: $pharmacyId');
     
     // Navigate to the signUpPage and pass the pharmacyId as an argument
         Navigator.pushNamed(context, '/signUp', arguments: {'pharmacyId': pharmacyId});
        

      } else {
        // Handle API error (e.g., display an error message)
        print('Failed to register pharmacy. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (error) {
      // Handle network or other errors
      print('Error registering pharmacy: $error');
    }
  }
}
