class Pharmacy {
  String pharmacyName;
  String county;
  String phoneNumber;
  double latitude;
  double longitude;

  Pharmacy({
    required this.pharmacyName,
    required this.county,
    required this.phoneNumber,
    required this.latitude,
    required this.longitude,
  });

  Map<String, dynamic> toJson() {
    return {
      'PharmacyName': pharmacyName,
      'County': county,
      'PhoneNumber': phoneNumber,
      'Latitude': latitude,
      'Longitude': longitude,
    };
  }
}
