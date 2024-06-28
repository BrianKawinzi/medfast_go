class Customer {
  int? id; // This will be the primary key in the database
  String name;
  String contactNo;
  String emailAddress;
  String date;

  Customer({
    this.id,
    required this.name,
    required this.contactNo,
    required this.emailAddress,
    required this.date,
  });

 Map<String, dynamic> toMap() {
    var map = {
      'name': name,
      'contactNo': contactNo,
      'emailAddress': emailAddress,
      'date': date,
    };
    
    if (id != null) {
      map['id'] = id as String; 
    }
    
    return map;
  }


  // Convert a Map object into a Customer object
  factory Customer.fromMap(Map<String, dynamic> map) {
    return Customer(
      id: map['id'] as int?,
      name: map['name'] as String,
      contactNo: map['contactNo'] as String,
      emailAddress: map['emailAddress'] as String,
      date: map['date'] as String,
    );
  }
}
