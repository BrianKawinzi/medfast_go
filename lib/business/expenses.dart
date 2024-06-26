import 'dart:math';
import 'package:flutter/material.dart';
import 'package:medfast_go/business/Expenses/custom_expense_details_page.dart';
import 'package:medfast_go/business/Expenses/expense_detail_page.dart';
import 'package:medfast_go/data/DatabaseHelper.dart';
import 'package:medfast_go/models/expenses.dart';
import 'package:fl_chart/fl_chart.dart';

class Expenses extends StatefulWidget {
  const Expenses({super.key});

  @override
  _ExpensesState createState() => _ExpensesState();
}

class _ExpensesState extends State<Expenses> {
  final TextEditingController searchController = TextEditingController();
  final TextEditingController expenseNameController = TextEditingController();
  final TextEditingController expenseDetailsController =
      TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController costController = TextEditingController();
  final FocusNode dateFocusNode = FocusNode();

  List<Expense> expenses = [];
  List<Expense> filteredExpenses = [];
  Map<Expense, Color> expenseColors = {};

  @override
  void initState() {
    super.initState();
    _fetchExpenses();
  }

  Future<void> _fetchExpenses() async {
    final dbHelper = DatabaseHelper();
    final fetchedExpenses = await dbHelper.getExpenses();
    setState(() {
      expenses = fetchedExpenses;
      filteredExpenses = fetchedExpenses;
      _assignColorsToExpenses();
    });
  }

  void _assignColorsToExpenses() {
    final random = Random();
    final colorList = List.of(Colors.primaries)..shuffle(random);
    int colorIndex = 0;
    expenseColors = {
      for (var expense in expenses) expense: colorList[colorIndex++ % colorList.length]
    };
  }

  Future<void> _filterExpenses(String query) async {
    setState(() {
      if (query.isEmpty) {
        filteredExpenses = expenses;
      } else {
        filteredExpenses = expenses.where((expense) {
          final expenseName = expense.expenseName.toLowerCase();
          return expenseName.contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  void _navigateToEditExpense(Expense expense) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ExpenseDetailPage(expense: expense),
      ),
    ).then((value) {
      _fetchExpenses();
    });
  }

  Widget _buildExpenseList() {
    double totalCost = expenses.fold(0, (sum, expense) => sum + (expense.cost));

    if (filteredExpenses.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.0),
          child: Text(
            "No expenses added yet. Click the + button to add your first expense.",
            style: TextStyle(fontSize: 18.0),
            textAlign: TextAlign.center,
          ),
        ),
      );
    } else {
      return ListView.builder(
        itemCount: filteredExpenses.length,
        itemBuilder: (context, index) {
          var expense = filteredExpenses[index];
          double expensePercentage =
              (totalCost > 0) ? (expense.cost / totalCost * 100) : 0;
          Color? expenseColor = expenseColors[expense];
          return Card(
            margin: const EdgeInsets.all(8.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
            child: ListTile(
              leading: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: expenseColor,
                ),
              ),
              title: Text(
                expense.expenseName,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Date: ${expense.date}"),
                  Text("Details: ${expense.expenseDetails}"),
                  Text("Cost: ${expense.cost}"),
                  Text("Percentage: ${expensePercentage.toStringAsFixed(2)}%"),
                ],
              ),
              onTap: () => _navigateToEditExpense(expense),
              trailing: IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () => _showDeleteConfirmationDialog(expense),
              ),
            ),
          );
        },
      );
    }
  }

  Widget _buildPieChart() {
    return Container(
      height: 250,
      padding: const EdgeInsets.all(16.0),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        elevation: 4.0,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: PieChart(
            PieChartData(
              sections: _getPieChartSections(),
              centerSpaceRadius: 40,
              sectionsSpace: 2,
            ),
          ),
        ),
      ),
    );
  }

  List<PieChartSectionData> _getPieChartSections() {
    double totalCost = expenses.fold(0, (sum, expense) => sum + (expense.cost));
    return expenses.map((expense) {
      final percentage = (totalCost > 0) ? (expense.cost / totalCost * 100) : 0;
      final isFiltered = filteredExpenses.contains(expense);
      return PieChartSectionData(
        value: expense.cost,
        title: "${percentage.toStringAsFixed(1)}%",
        color: isFiltered ? expenseColors[expense] : expenseColors[expense]!.withOpacity(0.3),
        radius: isFiltered ? 60 : 50,
        titleStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
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
              borderRadius: BorderRadius.circular(10.0),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(10.0),
            ),
            focusedBorder: const OutlineInputBorder(
              borderSide:
                  BorderSide(color: Color.fromRGBO(58, 205, 50, 1), width: 2.0),
              borderRadius: BorderRadius.all(Radius.circular(10.0)),
            ),
            filled: true,
          ),
        ),
      ],
    );
  }

  void _showExpenseForm(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16.0),
          height: MediaQuery.of(context).size.height * 0.90,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16.0),
              _customInputField(
                expenseNameController,
                "Expense Name",
                "Enter Expense Name",
                TextInputType.text,
                focusNode: null,
              ),
              const SizedBox(height: 16.0),
              _customInputField(
                expenseDetailsController,
                "Expense Details",
                "Enter Expense Details",
                TextInputType.text,
                focusNode: null,
              ),
              const SizedBox(height: 16.0),
              _customInputField(
                dateController,
                "Date",
                "Enter Date",
                TextInputType.text,
                focusNode: dateFocusNode,
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime.now().add(const Duration(days: 3650)),
                    builder: (BuildContext context, Widget? child) {
                      return Theme(
                        data: ThemeData.light().copyWith(
                          primaryColor: const Color.fromRGBO(58, 205, 50, 1),
                          scaffoldBackgroundColor:
                              const Color.fromRGBO(58, 205, 50, 1),
                          colorScheme: const ColorScheme.light(
                              primary: Color.fromRGBO(58, 205, 50, 1)),
                          buttonTheme: const ButtonThemeData(
                              textTheme: ButtonTextTheme.primary),

                        ),

                        child: child!,

                      );
                    },
                  );

                  if (pickedDate != null) {

                    String formattedDate =

                        "${pickedDate.day}-${pickedDate.month}-${pickedDate.year}";

                    dateController.text = formattedDate;

                  }

                },

              ),

              const SizedBox(height: 16.0),

              _customInputField(

                costController,

                "Cost",

                "Enter Cost",

                TextInputType.number,

                focusNode: null,

              ),

              const SizedBox(height: 40.0),

              SizedBox(

                width: double.infinity,

                height: 50,

                child: ElevatedButton(

                  onPressed: () async {

                    await _saveExpense();

                    Navigator.of(context).pop();

                  },

                  style: ElevatedButton.styleFrom(

                    backgroundColor: const Color.fromRGBO(58, 205, 50, 1),

                    shape: RoundedRectangleBorder(

                      borderRadius: BorderRadius.circular(10.0),

                    ),

                  ),

                  child: const Text(

                    "Save",

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

        );

      },

    );

  }
 
  Future<void> _saveExpense() async {

    if (_validateExpenseForm()) {

      final dbHelper = DatabaseHelper();
 
      Expense newExpense = Expense(

        expenseName: expenseNameController.text,

        expenseDetails: expenseDetailsController.text,

        date: dateController.text,

        cost: double.tryParse(costController.text) ?? 0.0,

      );
 
      await dbHelper.insertExpense(newExpense);

      await _fetchExpenses();

      expenseNameController.clear();

      expenseDetailsController.clear();

      dateController.clear();

      costController.clear();

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
 
  void _showDeleteConfirmationDialog(Expense expense) {

    showDialog(

      context: context,

      builder: (BuildContext context) {

        return AlertDialog(

          title: const Text('Delete Expense'),

          content: const Text('Are you sure you want to delete this expense?'),

          actions: [

            TextButton(

              onPressed: () => Navigator.of(context).pop(),

              child: const Text('Cancel'),

            ),

            TextButton(

              onPressed: () {

                Navigator.of(context).pop();

                _deleteExpense(expense);

              },

              child: const Text('Delete'),

            ),

          ],

        );

      },

    );

  }
 
  Future<void> _deleteExpense(Expense expense) async {

    final dbHelper = DatabaseHelper();

    await dbHelper.deleteExpense(expense.id!);

    await _fetchExpenses();

  }
 
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

            icon: const Icon(Icons.filter_list_outlined),

            onPressed: () {

              Navigator.of(context).push(

                MaterialPageRoute(

                  builder: (context) => CustomExpenseDetailPage(

                    expense: expenses.isNotEmpty

                        ? expenses[0]

                        : Expense(

                            id: null,

                            expenseName: '',

                            expenseDetails: '',

                            cost: 0.0,

                            date: '',

                          ),

                  ),

                ),

              );

            },

          ),

        ],

      ),

      body: Column(

        children: [

          Container(

            width: double.infinity,

            height: 48,

            margin: const EdgeInsets.all(16),

            padding: const EdgeInsets.symmetric(horizontal: 16),

            decoration: BoxDecoration(

              color: Colors.white,

              borderRadius: BorderRadius.circular(24),

              boxShadow: [

                BoxShadow(

                  color: Colors.grey.withOpacity(0.5),

                  spreadRadius: 2,

                  blurRadius: 3,

                  offset: const Offset(0, 2),

                ),

              ],

            ),

            child: Row(

              children: [

                Expanded(

                  child: TextField(

                    controller: searchController,

                    onChanged: (query) => _filterExpenses(query),

                    decoration: const InputDecoration(

                      border: InputBorder.none,

                      hintText: 'Search Expenses',

                      labelStyle: TextStyle(color: Colors.green),

                      prefixIcon: Icon(Icons.search),

                    ),

                  ),

                ),

              ],

            ),

          ),

          _buildPieChart(),

          Expanded(child: _buildExpenseList()),

        ],

      ),

      floatingActionButton: FloatingActionButton(

        onPressed: () {

          _showExpenseForm(context);

        },

        backgroundColor: const Color.fromRGBO(58, 205, 50, 1),

        child: const Icon(Icons.add),

      ),

    );

  }

}