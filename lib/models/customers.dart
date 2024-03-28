class Customer {
  int id; // This will be the primary key in the database
  String name;
  String contactNo;
  String emailAddress;
  String date;

  Customer({
    this.id = 0,
    required this.name,
    required this.contactNo,
    required this.emailAddress,
    required this.date,
  });

  // Convert a Customer object into a Map object
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'contactNo': contactNo,
      'emailAddress': emailAddress,
      'date': date,
    };
  }

  // Convert a Map object into a Customer object
  factory Customer.fromMap(Map<String, dynamic> map) {
    return Customer(
      id: map['id'],
      name: map['name'],
      contactNo: map['contactNo'],
      emailAddress: map['emailAddress'],
      date: map['date'],
    );
  }
}
