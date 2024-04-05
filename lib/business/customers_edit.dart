import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Import package for date formatting
import 'package:medfast_go/data/DatabaseHelper.dart';
import 'package:medfast_go/models/customers.dart';

class EditCustomerPage extends StatefulWidget {
  final Customer customer;

  EditCustomerPage({required this.customer});

  @override
  _EditCustomerPageState createState() => _EditCustomerPageState();
}

class _EditCustomerPageState extends State<EditCustomerPage> {
  late TextEditingController _customerNameController;
  late TextEditingController _contactNoController;
  late TextEditingController _emailAddressController;
  late TextEditingController _dateController; // Added controller for date
  late DateTime _selectedDate;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _customerNameController = TextEditingController(text: widget.customer.name);
    _contactNoController =
        TextEditingController(text: widget.customer.contactNo);
    _emailAddressController =
        TextEditingController(text: widget.customer.emailAddress);
    _dateController = TextEditingController(
        text: DateFormat('dd-MM-yyyy').format(DateFormat('dd-MM-yyyy')
            .parse(widget.customer.date))); // Initialize date controller
    _selectedDate = DateFormat('dd-MM-yyyy').parse(widget.customer.date);
  }

  @override
  void dispose() {
    _customerNameController.dispose();
    _contactNoController.dispose();
    _emailAddressController.dispose();
    _dateController.dispose(); // Dispose date controller
    super.dispose();
  }

  void _saveCustomer() async {
    if (_formKey.currentState!.validate()) {
      Customer updatedCustomer = Customer(
        id: widget.customer.id,
        name: _customerNameController.text,
        contactNo: _contactNoController.text,
        emailAddress: _emailAddressController.text,
        date: DateFormat('dd-MM-yyyy').format(_selectedDate),
      );

      await DatabaseHelper().updateCustomer(updatedCustomer);
      Navigator.pop(context);
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );
    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
        _dateController.text = DateFormat('dd-MM-yyyy')
            .format(pickedDate); // Update text field value
      });
    }
  }

  String? _validateContactNo(String? value) {
    if (value == null || value.isEmpty) {
      return 'Contact number is required';
    }
    if (value.length != 10) {
      return 'Contact number should be 10 digits';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Edit Customer',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: const Color.fromRGBO(58, 205, 50, 1),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Name',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                ),
              ),
              TextFormField(
                controller: _customerNameController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Name is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              const Text(
                'Contact No',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                ),
              ),
              TextFormField(
                controller: _contactNoController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
                validator: _validateContactNo,
              ),
              const SizedBox(height: 16.0),
              const Text(
                'Email Address',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                ),
              ),
              TextFormField(
                controller: _emailAddressController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                        .hasMatch(value)) {
                      return 'Enter a valid email';
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              const Text(
                'Date',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _dateController,
                      readOnly: true,
                      onTap: () => _selectDate(context),
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.calendar_today),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: _saveCustomer,
                child: const Text('Save Changes'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
