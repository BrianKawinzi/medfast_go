import 'dart:math';
import 'package:flutter/material.dart';
import 'package:medfast_go/models/expenses.dart'; // Ensure this points to your Expense model

class Expenses extends StatefulWidget {
  @override
  _ExpensesState createState() => _ExpensesState();
}

class _ExpensesState extends State<Expenses> {
  final TextEditingController expenseNameController = TextEditingController();
  final TextEditingController expenseDetailsController =
      TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController costController = TextEditingController();
  final FocusNode dateFocusNode = FocusNode();

  List<Expense> expenses = []; // List to hold expenses

  double get totalExpenses => expenses.fold(0, (sum, item) => sum + item.cost);

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
            icon: const Icon(Icons.calendar_view_month_sharp),
            onPressed: () => _showMenuContainer(context),
          ),
        ],
      ),
      body: expenses.isEmpty
          ? buildEmptyMessage(context)
          : buildExpensesList(context),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showExpenseForm(context),
        backgroundColor: const Color.fromRGBO(58, 205, 50, 1),
        child: const Icon(Icons.add, size: 36),
      ),
    );
  }

  Widget buildEmptyMessage(BuildContext context) {
    return Center(
      child: Text(
        "No expenses recorded yet.",
        style: TextStyle(fontSize: 20),
      ),
    );
  }

  Widget buildExpensesList(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Total Expenses: ${totalExpenses.toStringAsFixed(2)}',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: expenses.length,
            itemBuilder: (context, index) {
              final expense = expenses[index];
              final expensePercentage =
                  totalExpenses > 0 ? expense.cost / totalExpenses : 0.0;
              final color =
                  Colors.primaries[Random().nextInt(Colors.primaries.length)];

              return Card(
                margin:
                    const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: LinearProgressIndicator(
                              value: expensePercentage,
                              minHeight: 20, // Makes the progress bar thicker
                              backgroundColor: color.withOpacity(0.3),
                              valueColor: AlwaysStoppedAnimation<Color>(color),
                            ),
                          ),
                          Positioned.fill(
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(expense.name,
                                      style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white)),
                                  Text(
                                      "${(expensePercentage * 100).toStringAsFixed(2)}%",
                                      style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 4),
                      Text("Cost: ${expense.cost.toStringAsFixed(2)}"),
                      if (expensePercentage == 1.0) ...[
                        SizedBox(height: 8),
                        Text("Details: ${expense.details}"),
                      ],
                    ],
                  ),
                ),
              );
            },
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
          height: MediaQuery.of(context).size.height * 0.9,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _customInputField(
                  expenseNameController, 'Expense Name', 'Enter Expense Name'),
              const SizedBox(height: 16.0),
              _customInputField(expenseDetailsController, 'Expense Details',
                  'Enter Expense Details'),
              const SizedBox(height: 16.0),
              _customInputField(dateController, 'Date', 'Enter Date',
                  focusNode: dateFocusNode, onTap: () async {
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime.now().add(const Duration(days: 3650)),
                );
                if (pickedDate != null) {
                  String formattedDate =
                      "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
                  dateController.text = formattedDate;
                }
              }),
              const SizedBox(height: 16.0),
              _customInputField(costController, 'Cost', 'Enter Cost',
                  keyboardType: TextInputType.number),
              const SizedBox(height: 40.0),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    // Save the expense here
                    setState(() {
                      expenses.add(
                        Expense(
                          name: expenseNameController.text,
                          details: expenseDetailsController.text,
                          date: DateTime.parse(dateController.text),
                          cost: double.parse(costController.text),
                        ),
                      );
                    });
                    Navigator.pop(context); // Close the bottom sheet
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        const Color.fromRGBO(58, 205, 50, 1), // button color
                  ),
                  child: const Text('Save',
                      style: TextStyle(
                        fontSize: 25.0,
                        fontWeight: FontWeight.w600,
                      )),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _customInputField(
    TextEditingController controller,
    String header,
    String hintText, {
    TextInputType keyboardType = TextInputType.text,
    FocusNode? focusNode,
    VoidCallback? onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          header,
          style: const TextStyle(
              fontWeight: FontWeight.bold, fontSize: 20.0, color: Colors.black),
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

  void _showMenuContainer(BuildContext context) {
    // Implement your logic to show the menu container
  }
}
