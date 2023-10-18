import 'package:flutter/material.dart';
import 'package:medfast_go/pages/home_page.dart';

class Customers extends StatelessWidget {
  final TextEditingController customerNameController = TextEditingController();
  final TextEditingController contactNoController = TextEditingController();
  final TextEditingController emailAddressController = TextEditingController();

  Widget buildEmptyMessage(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.3,  // 30% of the screen height
      padding: const EdgeInsets.all(16.0),
      margin: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(58, 205, 50, 0.1),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(top: 16.0),
            child: Text('Hello!', style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold, color: Colors.black)),
          ),
          SizedBox(height: 10.0),
          Text("You haven't added any customers yet.", style: TextStyle(fontSize: 20.0, color: Colors.black)),
          SizedBox(height: 10.0),
          Text("Keep track of your customers by adding their details.", style: TextStyle(fontSize: 20.0, color: Colors.black)),
          SizedBox(height: 10.0),
          Text('Tap on the + Icon below to add a new customer.', style: TextStyle(fontSize: 20.0, color: Colors.black)),
        ],
      ),
    );
  }

  void _showCustomerForm(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16.0),
          height: MediaQuery.of(context).size.height * 0.48,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16.0),
              _customInputField(customerNameController, 'Customer Name', 'Enter Customer Name'),
              const SizedBox(height: 16.0),
              _customInputField(contactNoController, 'Contact No', 'Enter Contact No', TextInputType.phone),
              const SizedBox(height: 16.0),
              _customInputField(emailAddressController, 'Email Address', 'Enter Email Address', TextInputType.emailAddress),
              const SizedBox(height: 40.0),
              Container(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    // Save the customer details here
                  },
                  child: const Text('Save'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromRGBO(58, 205, 50, 1), // button color
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _customInputField(TextEditingController controller, String header, String hintText, [TextInputType keyboardType = TextInputType.text]) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          header,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20.0,
            color: Colors.black
          ),
        ),
        const SizedBox(height: 8.0),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hintText,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
            border: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Color.fromRGBO(58, 205, 50, 1), width: 2.0),
            ),
            filled: true,
          ),
        ),
      ],
    );
  }

  void _showMenuContainer(BuildContext context) {
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: "Dismiss",
    barrierColor: Colors.black.withOpacity(0.5),
    transitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (context, anim1, anim2) {
      return Align(
        alignment: Alignment.topCenter,
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height * 0.3,
          margin: const EdgeInsets.only(top: 50, left: 16.0, right: 16.0),
          padding: const EdgeInsets.all(16.0),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(
              Radius.circular(8.0),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 20.0),
                child: Text(
                  'Customers',
                  style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold, color: Colors.black, decoration: TextDecoration.none),
                ),
              ),
              const SizedBox(height: 30.0),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    // Action for exporting to PDF/Excel
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromRGBO(58, 205, 50, 1),
                    textStyle: const TextStyle(fontSize: 20),
                  ),
                  icon: const Icon(Icons.insert_drive_file),
                  label: const Text('Export as PDF/Excel'),
                ),
              ),
              const SizedBox(height: 20.0),
              const Divider(height: 30.0, thickness: 1.0, indent: 20.0, endIndent: 20.0),  // This is the underline
              const Spacer(), // Pushes the next widget to the end
              Align(
                alignment: Alignment.bottomRight,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // To close the dialog
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    textStyle: const TextStyle(fontSize: 20),
                  ),
                  child: const Text('Close'),
                ),
              ),
            ],
          ),
        ),
      );
    },
    transitionBuilder: (context, anim1, anim2, child) {
      return SlideTransition(
        position: Tween(begin: const Offset(0, -1), end: const Offset(0, 0)).animate(anim1),
        child: child,
      );
    },
  );
}

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
  title: const Text('Customers'),
  centerTitle: true,
  backgroundColor: const Color.fromRGBO(58, 205, 50, 1),
  leading: GestureDetector(
    onTap: () {
      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (context) => HomePage(), // Navigate to the HomePage
      ));
    },
    child: const Icon(Icons.arrow_back), // Use the back arrow icon
  ),
  actions: [
    IconButton(
      icon: const Icon(Icons.menu),  // This is the burger menu icon
      onPressed: () {
        _showMenuContainer(context);
      },
    ),
  ],
),

        body: buildEmptyMessage(context), 
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            _showCustomerForm(context); // Show the customer form when clicked
          },
          backgroundColor: const Color.fromRGBO(58, 205, 50, 1),
          child: const Icon(Icons.add),
        ),
      );
}
