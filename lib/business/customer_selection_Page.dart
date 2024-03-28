import 'package:flutter/material.dart';
import 'package:medfast_go/data/DatabaseHelper.dart';
import 'package:medfast_go/models/customers.dart';

class CustomerSelectionPage extends StatefulWidget {
  @override
  _CustomerSelectionPageState createState() => _CustomerSelectionPageState();
}

class _CustomerSelectionPageState extends State<CustomerSelectionPage> {
  late DatabaseHelper _databaseHelper;
  late List<Customer> _customerList = [];
  late List<bool> _selectedCustomers = [];

  @override
  void initState() {
    super.initState();
    _databaseHelper = DatabaseHelper();
    _fetchCustomers();
  }

  Future<void> _fetchCustomers() async {
    List<Customer> customers = await _databaseHelper.getCustomers();
    setState(() {
      _customerList = customers;
      _selectedCustomers =
          List<bool>.generate(customers.length, (index) => false);
    });
  }

  void _onCustomerSelected(int index, bool selected) {
    setState(() {
      _selectedCustomers[index] = selected;
    });
  }

  void _onSaveSelectedCustomers() {
    List<Customer> selectedCustomers = [];
    for (int i = 0; i < _selectedCustomers.length; i++) {
      if (_selectedCustomers[i]) {
        selectedCustomers.add(_customerList[i]);
      }
    }
    // Do something with selectedCustomers
    Navigator.pop(context, selectedCustomers);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Customers'),
        backgroundColor: const Color.fromRGBO(58, 205, 50, 1),
        actions: [
          IconButton(
            onPressed: _onSaveSelectedCustomers,
            icon: const Icon(Icons.check),
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: _customerList.length,
        itemBuilder: (BuildContext context, int index) {
          Customer customer = _customerList[index];
          return CheckboxListTile(
            title: Text(customer.name),
            subtitle: Text(customer.contactNo),
            value: _selectedCustomers[index],
            onChanged: (bool? value) {
              _onCustomerSelected(index, value ?? false);
            },
          );
        },
      ),
    );
  }
}
