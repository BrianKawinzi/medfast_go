import 'package:flutter/material.dart';
import 'package:medfast_go/models/expenses.dart';

class CustomExpenseDetailPage extends StatelessWidget {
  final Expense expense;

  CustomExpenseDetailPage({Key? key, required this.expense}) : super(key: key);

  Future<void> _showDatePicker(BuildContext context, String title) async {
    DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (selectedDate != null) {
      print('$title: $selectedDate');
      // Here you can add logic to fetch and display expenses for the selected date
      // Example: fetchExpensesForDate(selectedDate);
    }
  }

  // Example method to fetch expenses for a specific date
  // Replace this with your actual data-fetching logic
  void fetchExpensesForDate(DateTime date) {
    // Your logic to fetch and display expenses for the selected date goes here
    // You may use a state management solution or a callback to update the UI
    // with the fetched expenses.
    // Example: expenses = fetchExpensesFromDatabase(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Expense History'),
        centerTitle: true,
        backgroundColor: const Color.fromRGBO(58, 205, 50, 1),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20.0),
            buildSection(context, 'Today'),
            const SizedBox(height: 20.0),
            buildSection(context, 'Yesterday'),
            const SizedBox(height: 20.0),
            buildSection(context, 'Last 7 Days'),
            const SizedBox(height: 20.0),
            buildSection(context, 'Last 30 Days'),
            const SizedBox(height: 20.0),
            buildSection(context, 'Current Month'),
            const SizedBox(height: 20.0),
            buildSection(context, 'Previous Month'),
            const SizedBox(height: 20.0),
            buildSection(context, 'All'),
            const SizedBox(height: 28.0),
            buildDateRow(context, 'Start Date', 'End Date'),
            const SizedBox(height: 28.0),
            Align(
              alignment: Alignment.bottomRight,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  textStyle: const TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                child: const Text(
                  'Close',
                  style: TextStyle(
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

  Widget buildSection(BuildContext context, String title) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black, width: 1.0),
        borderRadius: const BorderRadius.all(Radius.circular(8.0)),
      ),
      child: InkWell(
        onTap: () {
          // Handle section click
          // Example: fetchExpensesForSection(title);
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.black,
                  fontWeight: FontWeight.normal,
                  decoration: TextDecoration.none,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildDateRow(
      BuildContext context, String startDateTitle, String endDateTitle) {
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: InkWell(
            onTap: () {
              _showDatePicker(context, startDateTitle);
            },
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black, width: 1.0),
                borderRadius: const BorderRadius.all(Radius.circular(8.0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      startDateTitle,
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.black,
                        fontWeight: FontWeight.normal,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 48.0),
        Expanded(
          flex: 1,
          child: InkWell(
            onTap: () {
              _showDatePicker(context, endDateTitle);
            },
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black, width: 1.0),
                borderRadius: const BorderRadius.all(Radius.circular(8.0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      endDateTitle,
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.black,
                        fontWeight: FontWeight.normal,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
