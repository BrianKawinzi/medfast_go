import 'package:flutter/material.dart';
import 'package:medfast_go/business/add_customer_page.dart';
import 'package:medfast_go/business/customer_selection_Page.dart';
import 'package:medfast_go/business/customers_edit.dart';
import 'package:medfast_go/data/DatabaseHelper.dart';
import 'package:medfast_go/models/customers.dart';

class Customers extends StatefulWidget {
  const Customers({Key? key}) : super(key: key);

  @override
  _CustomersState createState() => _CustomersState();
}

class _CustomersState extends State<Customers> {
  final TextEditingController _searchController = TextEditingController();
  late DatabaseHelper _databaseHelper;
  late List<Customer> _customerList = [];

  @override
  void initState() {
    super.initState();
    _databaseHelper = DatabaseHelper();
    _refreshCustomerList();
  }

  void _refreshCustomerList() async {
    List<Customer> customers = await _databaseHelper.getCustomers();
    setState(() {
      _customerList = customers;
    });
  }

  void _editCustomer(Customer customer) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditCustomerPage(customer: customer),
      ),
    ).then((_) {
      // Refresh customer list after editing
      _refreshCustomerList();
    });
  }

  Future<void> _filterCustomers(String query) async {
    final dbHelper = DatabaseHelper();
    final allCustomers = await dbHelper.getCustomers();

    setState(() {
      if (query.isEmpty) {
        _customerList = allCustomers;
      } else {
        _customerList = allCustomers.where((customer) {
          final customerName = customer.name;
          return customerName.toLowerCase().contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  Widget _buildCustomerList(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
              borderRadius:
                  BorderRadius.circular(10.0), // Circular border radius
              border: Border.all(color: Colors.grey), // Optional: Add a border
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: TextFormField(
                controller: _searchController,
                onChanged: (value) {
                  _filterCustomers(value);
                },
                decoration: const InputDecoration(
                  hintText: 'Search customers...',
                  prefixIcon: Icon(Icons.search),
                  border: InputBorder.none, // Remove default border
                ),
              ),
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _customerList.length,
            itemBuilder: (BuildContext context, int index) {
              Customer customer = _customerList[index];
              // Extract initials from customer's name
              String initials = customer.name.isNotEmpty
                  ? customer.name
                      .trim()
                      .split(' ')
                      .map((e) => e[0])
                      .take(2)
                      .join()
                      .toUpperCase()
                  : '';

              return Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 2.0, horizontal: 4.0),
                child: Card(
                  elevation: 4.0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 4.0, horizontal: 8.0),
                    leading: CircleAvatar(
                      backgroundColor: Colors.greenAccent,
                      child: Text(
                        initials,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(
                      customer.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      customer.contactNo,
                      style: const TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                    onTap: () {
                      _editCustomer(customer);
                    },
                  ),
                ),
              );
            },
          ),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Customers'),
        backgroundColor: const Color.fromRGBO(58, 205, 50, 1),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              // Navigate to the customer selection page
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => CustomerSelectionPage()),
              );
            },
            icon: const Icon(Icons.menu),
          ),
        ],
      ),
      body: _customerList.isEmpty
          ? const Center(
              child: Text(
                "No customers added yet. Click the '+' button to add your first customer.",
                style: TextStyle(fontSize: 20.0),
                textAlign: TextAlign.center,
              ),
            )
          : _buildCustomerList(context),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddCustomerPage()),
          ).then((_) {
            // Refresh customer list after adding a new customer
            _refreshCustomerList();
          });
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
