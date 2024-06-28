// expense_detail_page.dart

import 'package:flutter/material.dart';
import 'package:medfast_go/business/Expenses/edit_expense_page.dart';
import 'package:medfast_go/models/expenses.dart';

class ExpenseDetailPage extends StatelessWidget {
  final Expense expense;

  const ExpenseDetailPage({Key? key, required this.expense}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Expense Details'),
        centerTitle: true,
        backgroundColor: const Color.fromRGBO(58, 205, 50, 1),
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context); // Navigate back when arrow back is pressed
          },
          child: const Icon(Icons.arrow_back),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              _navigateToEditExpense(context, expense);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Name: ${expense.expenseName}'),
            Text('Date: ${expense.date}'),
            Text('Details: ${expense.expenseDetails}'),
            Text('Cost: ${expense.cost}'),
            // Add more details as needed
          ],
        ),
      ),
    );
  }

  void _navigateToEditExpense(BuildContext context, Expense expense) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditExpensePage(expense: expense),
      ),
    ).then((editedExpense) {
      // Handle the edited expense if needed
      if (editedExpense != null) {
        // Update the UI or perform any actions
      }
    });
  }
}
