import 'package:flutter/material.dart';
import 'package:medfast_go/models/expenses.dart'; // Ensure this points to your Expense model

class EditExpenseScreen extends StatefulWidget {
  final Expense expense;
  final Function(Expense) onUpdate;

  EditExpenseScreen({Key? key, required this.expense, required this.onUpdate})
      : super(key: key);

  @override
  _EditExpenseScreenState createState() => _EditExpenseScreenState();
}

class _EditExpenseScreenState extends State<EditExpenseScreen> {
  late TextEditingController _nameController;
  late TextEditingController _detailsController;
  late TextEditingController _costController;
  late TextEditingController _dateController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.expense.id.toString());
    _detailsController =
        TextEditingController(text: widget.expense.date.toString());
    _costController =
        TextEditingController(text: widget.expense.cost.toString());
    _dateController =
        TextEditingController(text: widget.expense.date.toString());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Expense'),
        backgroundColor: const Color.fromRGBO(58, 205, 50, 1),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Expense Name'),
            ),
            TextField(
              controller: _detailsController,
              decoration: InputDecoration(labelText: 'Details'),
            ),
            TextField(
              controller: _costController,
              decoration: InputDecoration(labelText: 'Cost'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _dateController,
              decoration: InputDecoration(labelText: 'Date'),
              readOnly: true,
              onTap: () async {
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.parse(_dateController.text),
                  firstDate: DateTime(2000),
                  lastDate: DateTime.now(),
                );
                if (pickedDate != null) {
                  setState(() {
                    _dateController.text = pickedDate.toIso8601String();
                  });
                }
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                widget.onUpdate(
                  Expense(expenseName: '', cost: 0, date: '', expenseDetails: ''
                      // name: _nameController.text,
                      // details: _detailsController.text,
                      // cost: double.parse(_costController.text),
                      // date: DateTime.parse(_dateController.text),
                  ),
                );
                Navigator.pop(context);
              },
              child: Text('Update Expense'),
              style: ElevatedButton.styleFrom(
                primary: const Color.fromRGBO(58, 205, 50, 1),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
