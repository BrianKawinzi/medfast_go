// class Expense {
//   String name;
//   String details;
//   DateTime date;
//   double cost;

//   Expense({
//     required this.name,
//     required this.details,
//     required this.date,
//     required this.cost,
//   });
// }

class Expense {
  final int? id; // Make it nullable
  final String expenseName;
  final String expenseDetails;
  final double cost;
  final String date;

  Expense({
    this.id,
    required this.expenseName,
    required this.expenseDetails,
    required this.cost,
    required this.date,
  });

  // Named constructor to create an Expense object from a map
  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      id: map['id'],
      expenseName: map['expenseName'],
      expenseDetails: map['expenseDetails'],
      cost: map['cost'].toDouble(),
      date: map['date'],
    );
  }

  // Method to convert an Expense object to a map
  Map<String, dynamic> toMap({bool excludeId = false}) {
    if (excludeId) {
      return {
        'expenseName': expenseName,
        'expenseDetails': expenseDetails,
        'cost': cost,
        'date': date,
      };
    } else {
      return {
        'id': id,
        'expenseName': expenseName,
        'expenseDetails': expenseDetails,
        'cost': cost,
        'date': date,
      };
    }
  }
}
