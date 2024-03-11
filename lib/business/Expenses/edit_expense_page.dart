// edit_expense_page.dart

import 'package:flutter/material.dart';
import 'package:medfast_go/data/DatabaseHelper.dart';
import 'package:medfast_go/models/expenses.dart';

class EditExpensePage extends StatefulWidget {
  final Expense expense;

  const EditExpensePage({Key? key, required this.expense}) : super(key: key);

  @override
  _EditExpensePageState createState() => _EditExpensePageState();
}

class _EditExpensePageState extends State<EditExpensePage> {
  final TextEditingController expenseNameController = TextEditingController();
  final TextEditingController expenseDetailsController =
      TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController costController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initialize controllers with current expense details
    expenseNameController.text = widget.expense.expenseName;
    expenseDetailsController.text = widget.expense.expenseDetails;
    dateController.text = widget.expense.date;
    costController.text = widget.expense.cost.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Expense'),
        centerTitle: true,
        backgroundColor: const Color.fromRGBO(58, 205, 50, 1),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _customInputField(
              expenseNameController,
              'Expense Name',
              'Enter Expense Name',
              TextInputType.text,
            ),
            const SizedBox(height: 16.0),
            _customInputField(
              expenseDetailsController,
              'Expense Details',
              'Enter Expense Details',
              TextInputType.text,
            ),
            const SizedBox(height: 16.0),
            _customInputField(
              dateController,
              'Date',
              'Enter Date',
              TextInputType.text,
              onTap: () async {
                // Implement date selection logic if needed
              },
            ),
            const SizedBox(height: 16.0),
            _customInputField(
              costController,
              'Cost',
              'Enter Cost',
              TextInputType.number,
            ),
            const SizedBox(height: 40.0),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () async {
                  await _saveEditedExpense();
                  Navigator.of(context)
                      .pop(widget.expense); // Return the edited expense
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
      ),
    );
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

  Future<void> _saveEditedExpense() async {
    if (_validateExpenseForm()) {
      final dbHelper = DatabaseHelper();

      Expense editedExpense = Expense(
        id: widget.expense.id,
        expenseName: expenseNameController.text,
        expenseDetails: expenseDetailsController.text,
        date: dateController.text,
        cost: double.tryParse(costController.text) ?? 0.0,
      );

      await dbHelper.updateExpense(editedExpense);
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
}
