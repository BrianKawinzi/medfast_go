// import 'dart:math';
// import 'package:flutter/material.dart';
// import 'package:medfast_go/models/expenses.dart'; // Ensure this points to your Expense model

// class Expenses extends StatefulWidget {
//   @override
//   _ExpensesState createState() => _ExpensesState();
// }

// class _ExpensesState extends State<Expenses> {
//   final TextEditingController expenseNameController = TextEditingController();
//   final TextEditingController expenseDetailsController =
//       TextEditingController();
//   final TextEditingController dateController = TextEditingController();
//   final TextEditingController costController = TextEditingController();
//   final FocusNode dateFocusNode = FocusNode();

//   List<Expense> expenses = []; // List to hold expenses

//   double get totalExpenses => expenses.fold(0, (sum, item) => sum + item.cost);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Expenses'),
//         centerTitle: true,
//         backgroundColor: const Color.fromRGBO(58, 205, 50, 1),
//         leading: GestureDetector(
//           onTap: () => Navigator.of(context).pop(),
//           child: const Icon(Icons.arrow_back),
//         ),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.calendar_view_month_sharp),
//             onPressed: () => _showMenuContainer(context),
//           ),
//         ],
//       ),
//       body: expenses.isEmpty
//           ? buildEmptyMessage(context)
//           : buildExpensesList(context),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () => _showExpenseForm(context),
//         backgroundColor: const Color.fromRGBO(58, 205, 50, 1),
//         child: const Icon(Icons.add, size: 36),
//       ),
//     );
//   }

//   Widget buildEmptyMessage(BuildContext context) {
//     return Center(
//       child: Text(
//         "No expenses recorded yet.",
//         style: TextStyle(fontSize: 20),
//       ),
//     );
//   }

//   Widget buildExpensesList(BuildContext context) {
//     return Column(
//       children: [
//         Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Text(
//             'Total Expenses: ${totalExpenses.toStringAsFixed(2)}',
//             style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//           ),
//         ),
//         Expanded(
//           child: ListView.builder(
//             itemCount: expenses.length,
//             itemBuilder: (context, index) {
//               final expense = expenses[index];
//               final expensePercentage =
//                   totalExpenses > 0 ? expense.cost / totalExpenses : 0.0;
//               final color =
//                   Colors.primaries[Random().nextInt(Colors.primaries.length)];

//               return Card(
//                 margin:
//                     const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
//                 child: Padding(
//                   padding: const EdgeInsets.all(8.0),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Stack(
//                         children: [
//                           ClipRRect(
//                             borderRadius: BorderRadius.circular(10),
//                             child: LinearProgressIndicator(
//                               value: expensePercentage,
//                               minHeight: 20, // Makes the progress bar thicker
//                               backgroundColor: color.withOpacity(0.3),
//                               valueColor: AlwaysStoppedAnimation<Color>(color),
//                             ),
//                           ),
//                           Positioned.fill(
//                             child: Padding(
//                               padding:
//                                   const EdgeInsets.symmetric(horizontal: 10),
//                               child: Row(
//                                 mainAxisAlignment:
//                                     MainAxisAlignment.spaceBetween,
//                                 children: [
//                                   Text(expense.name,
//                                       style: TextStyle(
//                                           fontSize: 14,
//                                           fontWeight: FontWeight.bold,
//                                           color: Colors.white)),
//                                   Text(
//                                       "${(expensePercentage * 100).toStringAsFixed(2)}%",
//                                       style: TextStyle(
//                                           fontSize: 14,
//                                           fontWeight: FontWeight.bold,
//                                           color: Colors.white)),
//                                 ],
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                       SizedBox(height: 4),
//                       Text("Cost: ${expense.cost.toStringAsFixed(2)}"),
//                       if (expensePercentage == 1.0) ...[
//                         SizedBox(height: 8),
//                         Text("Details: ${expense.details}"),
//                       ],
//                     ],
//                   ),
//                 ),
//               );
//             },
//           ),
//         ),
//       ],
//     );
//   }

//   void _showExpenseForm(BuildContext context) {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       builder: (BuildContext context) {
//         return Container(
//           padding: const EdgeInsets.all(16.0),
//           height: MediaQuery.of(context).size.height * 0.9,
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               _customInputField(
//                   expenseNameController, 'Expense Name', 'Enter Expense Name'),
//               const SizedBox(height: 16.0),
//               _customInputField(expenseDetailsController, 'Expense Details',
//                   'Enter Expense Details'),
//               const SizedBox(height: 16.0),
//               _customInputField(dateController, 'Date', 'Enter Date',
//                   focusNode: dateFocusNode, onTap: () async {
//                 DateTime? pickedDate = await showDatePicker(
//                   context: context,
//                   initialDate: DateTime.now(),
//                   firstDate: DateTime(2000),
//                   lastDate: DateTime.now().add(const Duration(days: 3650)),
//                 );
//                 if (pickedDate != null) {
//                   String formattedDate =
//                       "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
//                   dateController.text = formattedDate;
//                 }
//               }),
//               const SizedBox(height: 16.0),
//               _customInputField(costController, 'Cost', 'Enter Cost',
//                   keyboardType: TextInputType.number),
//               const SizedBox(height: 40.0),
//               SizedBox(
//                 width: double.infinity,
//                 height: 50,
//                 child: ElevatedButton(
//                   onPressed: () {
//                     // Save the expense here
//                     setState(() {
//                       expenses.add(
//                         Expense(
//                           name: expenseNameController.text,
//                           details: expenseDetailsController.text,
//                           date: DateTime.parse(dateController.text),
//                           cost: double.parse(costController.text),
//                         ),
//                       );
//                     });
//                     Navigator.pop(context); // Close the bottom sheet
//                   },
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor:
//                         const Color.fromRGBO(58, 205, 50, 1), // button color
//                   ),
//                   child: const Text('Save',
//                       style: TextStyle(
//                         fontSize: 25.0,
//                         fontWeight: FontWeight.w600,
//                       )),
//                 ),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   Widget _customInputField(
//     TextEditingController controller,
//     String header,
//     String hintText, {
//     TextInputType keyboardType = TextInputType.text,
//     FocusNode? focusNode,
//     VoidCallback? onTap,
//   }) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           header,
//           style: const TextStyle(
//               fontWeight: FontWeight.bold, fontSize: 20.0, color: Colors.black),
//         ),
//         const SizedBox(height: 8.0),
//         TextField(
//           controller: controller,
//           keyboardType: keyboardType,
//           focusNode: focusNode,
//           onTap: onTap,
//           decoration: InputDecoration(
//             hintText: hintText,
//             fillColor: Colors.white,
//             contentPadding:
//                 const EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
//             border: OutlineInputBorder(
//               borderSide: BorderSide(color: Colors.grey[300]!),
//             ),
//             enabledBorder: OutlineInputBorder(
//               borderSide: BorderSide(color: Colors.grey[300]!),
//             ),
//             focusedBorder: const OutlineInputBorder(
//               borderSide:
//                   BorderSide(color: Color.fromRGBO(58, 205, 50, 1), width: 2.0),
//             ),
//             filled: true,
//           ),
//         ),
//       ],
//     );
//   }

//   void _showMenuContainer(BuildContext context) {
//     // Implement your logic to show the menu container
//   }
// }

import 'package:flutter/material.dart';
import 'package:medfast_go/business/EXPENSES/expense_detail_page.dart';
import 'package:medfast_go/business/Expenses/custom_expense_details_page.dart';
import 'package:medfast_go/data/DatabaseHelper.dart';

import '../models/expenses.dart';

class Expenses extends StatefulWidget {
  const Expenses({super.key});

  @override
  _ExpensesState createState() => _ExpensesState();
}

class _ExpensesState extends State<Expenses> {
  final TextEditingController searchController = TextEditingController();
  final TextEditingController expenseNameController = TextEditingController();
  final TextEditingController expenseDetailsController =
      TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController costController = TextEditingController();
  final FocusNode dateFocusNode = FocusNode();

  List<Expense> expenses = [];

  @override
  void initState() {
    super.initState();
    _fetchExpenses();
  }

  Future<void> _fetchExpenses() async {
    final dbHelper = DatabaseHelper();
    final fetchedExpenses = await dbHelper.getExpenses();
    setState(() {
      expenses = fetchedExpenses;
    });
  }

  // Inside your _ExpensesState class
  Future<void> _filterExpenses(String query) async {
    final dbHelper = DatabaseHelper();
    final allExpenses = await dbHelper.getExpenses();

    setState(() {
      if (query.isEmpty) {
        expenses = allExpenses;
      } else {
        expenses = allExpenses.where((expense) {
          final expenseName = expense.expenseName;
          return expenseName.toLowerCase().contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  void _navigateToEditExpense(Expense expense) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ExpenseDetailPage(expense: expense),
      ),
    ).then((value) {
      // Refresh the expense list when returning from the detail page
      _fetchExpenses();
    });
  }

  Widget _buildExpenseList() {
    // Calculate total expenses
    double totalCost = expenses.fold(0, (sum, expense) => sum + (expense.cost));

    if (expenses.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.only(left: 20.0),
          child: Text(
            "No expenses added yet. Click the + button to add your first expense.",
            style: TextStyle(fontSize: 18.0),
          ),
        ),
      );
    } else {
      return ListView.builder(
        itemCount: expenses.length,
        itemBuilder: (context, index) {
          var expense = expenses[index];
          // Calculate percentage
          double expensePercentage = (expense.cost) / totalCost * 100;
          return Card(
            margin: const EdgeInsets.all(8.0),
            child: ListTile(
              title: Text(expense.expenseName),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Date: ${expense.date}"),
                  Text('Details: ${expense.expenseDetails}'),
                  Text('Cost: ${expense.cost}'),
                  Text('Percentage: ${expensePercentage.toStringAsFixed(2)}%'),
                ],
              ),
              onTap: () => _navigateToEditExpense(expense),
              trailing: IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () => _showDeleteConfirmationDialog(expense),
              ),
            ),
          );
        },
      );
    }
  }

  Widget _customInputField(
    TextEditingController controller,
    String header,
    String hintText,
    TextInputType keyboardType, {
    FocusNode? focusNode,
    VoidCallback? onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          header,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20.0,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8.0),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          focusNode: focusNode,
          onTap: onTap,
          decoration: InputDecoration(
            hintText: hintText,
            fillColor: Colors.white,
            contentPadding:
                const EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
            border: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: const OutlineInputBorder(
              borderSide:
                  BorderSide(color: Color.fromRGBO(58, 205, 50, 1), width: 2.0),
            ),
            filled: true,
          ),
        ),
      ],
    );
  }

  void _showExpenseForm(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16.0),
          height: MediaQuery.of(context).size.height * 0.90,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16.0),
              _customInputField(
                expenseNameController,
                'Expense Name',
                'Enter Expense Name',
                TextInputType.text,
                focusNode: null,
              ),
              const SizedBox(height: 16.0),
              _customInputField(
                expenseDetailsController,
                'Expense Details',
                'Enter Expense Details',
                TextInputType.text,
                focusNode: null,
              ),
              const SizedBox(height: 16.0),
              _customInputField(
                dateController,
                'Date',
                'Enter Date',
                TextInputType.text,
                focusNode: dateFocusNode,
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime.now().add(const Duration(days: 3650)),
                    builder: (BuildContext context, Widget? child) {
                      return Theme(
                        data: ThemeData.light().copyWith(
                          primaryColor: const Color.fromRGBO(58, 205, 50, 1),
                          scaffoldBackgroundColor:
                              const Color.fromRGBO(58, 205, 50, 1),
                          colorScheme: const ColorScheme.light(
                              primary: Color.fromRGBO(58, 205, 50, 1)),
                          buttonTheme: const ButtonThemeData(
                              textTheme: ButtonTextTheme.primary),
                        ),
                        child: child!,
                      );
                    },
                  );
                  if (pickedDate != null) {
                    String formattedDate =
                        "${pickedDate.day}-${pickedDate.month}-${pickedDate.year}";
                    dateController.text = formattedDate;
                  }
                },
              ),
              const SizedBox(height: 16.0),
              _customInputField(
                costController,
                'Cost',
                'Enter Cost',
                TextInputType.number,
                focusNode: null,
              ),
              const SizedBox(height: 40.0),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () async {
                    await _saveExpense();
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromRGBO(58, 205, 50, 1),
                  ),
                  child: const Text(
                    'Save',
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _saveExpense() async {
    if (_validateExpenseForm()) {
      final dbHelper = DatabaseHelper();

      Expense newExpense = Expense(
        expenseName: expenseNameController.text,
        expenseDetails: expenseDetailsController.text,
        date: dateController.text,
        cost: double.tryParse(costController.text) ?? 0.0,
      );

      await dbHelper.insertExpense(newExpense);
      await _fetchExpenses();
      // Clear text controllers after successful submission
      expenseNameController.clear();
      expenseDetailsController.clear();
      dateController.clear();
      costController.clear();
    }
  }

  bool _validateExpenseForm() {
    if (expenseNameController.text.isEmpty ||
        expenseDetailsController.text.isEmpty ||
        dateController.text.isEmpty ||
        costController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all required fields.'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }
    return true;
  }

  void _showDeleteConfirmationDialog(Expense expense) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Expense'),
          content: const Text('Are you sure you want to delete this expense?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteExpense(expense);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteExpense(Expense expense) async {
    final dbHelper = DatabaseHelper();
    await dbHelper.deleteExpense(expense.id!);
    await _fetchExpenses();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Expenses'),
        centerTitle: true,
        backgroundColor: const Color.fromRGBO(58, 205, 50, 1),
        leading: GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: const Icon(Icons.arrow_back),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list_outlined),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => CustomExpenseDetailPage(
                    expense: expenses.isNotEmpty
                        ? expenses[0] // Assuming the first expense in the list
                        : Expense(
                            id: null, // Assuming id is nullable
                            expenseName:
                                '', // Provide a default value or handle it accordingly
                            expenseDetails: '',
                            cost:
                                0.0, // Provide a default value or handle it accordingly
                            date:
                                '', // Provide a default value or handle it accordingly
                          ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            height: 48,
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 2,
                  blurRadius: 3,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: searchController,
                    onChanged: (query) => _filterExpenses(query),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      labelText: 'Search Expenses',
                      labelStyle: TextStyle(color: Colors.green),
                      prefixIcon: Icon(Icons.search),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(child: _buildExpenseList()),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showExpenseForm(context);
        },
        backgroundColor: const Color.fromRGBO(58, 205, 50, 1),
        child: const Icon(Icons.add),
      ),
    );
  }
}
