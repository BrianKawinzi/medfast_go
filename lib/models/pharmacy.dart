class Pharmacy {
  String pharmacyName;
  String region;
  String city;
  String subCity;
  String landmark;
  String phoneNumber;
  double latitude;
  double longitude;

  Pharmacy({
    required this.pharmacyName,
    required this.region,
    required this.city,
    required this.subCity,
    required this.landmark,
    required this.phoneNumber,
    required this.latitude,
    required this.longitude,
  });

  Map<String, dynamic> toJson() {
    return {
      'PharmacyName': pharmacyName,
      'Region': region,
      'City': city,
      'SubCity': subCity,
      'Landmark': landmark,
      'PhoneNumber': phoneNumber,
      'Latitude': latitude,
      'Longitude': longitude,
    };
  }
}
