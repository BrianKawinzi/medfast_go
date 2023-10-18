import 'package:flutter/material.dart';
import 'package:medfast_go/pages/home_page.dart';

class Expenses extends StatelessWidget {
  final TextEditingController expenseNameController = TextEditingController();
  final TextEditingController expenseDetailsController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController costController = TextEditingController();
  final FocusNode dateFocusNode = FocusNode();

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
            child: Text('Hey!', style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold, color: Colors.black)),
          ),
          SizedBox(height: 10.0),
          Text("You don't have any expenses recorded yet.", style: TextStyle(fontSize: 20.0, color: Colors.black)),
          SizedBox(height: 10.0),
          Text("It's essential to track your expenses to manage your finances. Let's start by adding your expenses.", style: TextStyle(fontSize: 20.0, color: Colors.black)),
          SizedBox(height: 10.0),
          Text('Tap on the + Icon below to record your first expense.', style: TextStyle(fontSize: 20.0, color: Colors.black)),
        ],
      ),
    );
  }

  void _showExpenseForm(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (BuildContext context) {
      return Container(
        padding: const EdgeInsets.all(16.0),
        height: MediaQuery.of(context).size.height * 0.58,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _customInputField(expenseNameController, 'Expense Name', 'Enter Expense Name'),
            const SizedBox(height: 16.0),
            _customInputField(expenseDetailsController, 'Expense Details', 'Enter Expense Details'),
            const SizedBox(height: 16.0),
            _customInputField(
              dateController, 
              'Date', 
              'Enter Date', 
              focusNode: dateFocusNode,
              onTap: () async {
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime.now().add(const Duration(days: 3650)), // 10 years into the future
                  builder: (BuildContext context, Widget? child) {
                    return Theme(
                      data: ThemeData.light().copyWith(
                        primaryColor: const Color.fromRGBO(58, 205, 50, 1),
                        scaffoldBackgroundColor: const Color.fromRGBO(58, 205, 50, 1),
                        colorScheme: const ColorScheme.light(primary: Color.fromRGBO(58, 205, 50, 1)),
                        buttonTheme: const ButtonThemeData(textTheme: ButtonTextTheme.primary)
                      ),
                      child: child!,
                    );
                  },
                );
                if (pickedDate != null) {
                  String formattedDate = "${pickedDate.day}-${pickedDate.month}-${pickedDate.year}";
                  dateController.text = formattedDate;
                }
              }
            ),
            const SizedBox(height: 16.0),
            _customInputField(costController, 'Cost', 'Enter Cost', keyboardType: TextInputType.number),
            const SizedBox(height: 40.0),
            Container(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  // Save the expense here
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromRGBO(58, 205, 50, 1), // button color
                ),
                child: const Text('Save', style: TextStyle(fontSize: 20.0)),
              ),
            ),
          ],
        ),
      );
    },
  );
}


  Widget _customInputField(TextEditingController controller, String header, String hintText, 
    {TextInputType keyboardType = TextInputType.text, FocusNode? focusNode, VoidCallback? onTap}) {
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
          focusNode: focusNode,
          onTap: onTap,
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

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Expenses'),
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
        ),
        body: buildEmptyMessage(context),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            _showExpenseForm(context);
          },
          backgroundColor: const Color.fromRGBO(58, 205, 50, 1),
          child: const Icon(Icons.add),
        ),
      );
}
