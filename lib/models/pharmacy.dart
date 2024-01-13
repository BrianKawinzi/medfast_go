class Pharmacy {
  String pharmacyName;
  String email;
  String phoneNumber;
  double latitude;
  double longitude;

  Pharmacy({
    required this.pharmacyName,
    required this.email,
    required this.phoneNumber,
    required this.latitude,
    required this.longitude,
  });

  Map<String, dynamic> toJson() {
    return {
      'PharmacyName': pharmacyName,
      'Email': email,
      'PhoneNumber': phoneNumber,
      'Latitude': latitude,
      'Longitude': longitude,
    };
  }
}
