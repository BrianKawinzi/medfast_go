import 'dart:io';
import 'package:flutter/material.dart';
import 'package:medfast_go/business/sales.dart';
import 'package:medfast_go/data/DatabaseHelper.dart';
import 'package:medfast_go/models/product.dart';
import 'package:medfast_go/pages/bottom_navigation.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'package:fluttertoast/fluttertoast.dart';

class Reports extends StatefulWidget {
  const Reports({Key? key, required this.products}) : super(key: key);
  final List<Product> products;

  @override
  _ReportsState createState() => _ReportsState();
}

class _ReportsState extends State<Reports> {
  DateTimeRange? selectedDateRange;
  DateTime? selectedDate;
  int? expandedIndex;
  List<DataRow> stockRows = [];
  List<DataRow> salesRows = [];
  bool isStockSelected = true;
  bool matchesDate(String dataRowDate, DateTime selectedDate) {
  DateTime parsedDate = DateTime.parse(dataRowDate);
  return parsedDate.year == selectedDate.year &&
         parsedDate.month == selectedDate.month &&
         parsedDate.day == selectedDate.day;
}

bool inDateRange(String dataRowDate, DateTimeRange range) {
  DateTime parsedDate = DateTime.parse(dataRowDate);
  return parsedDate.isAfter(range.start) && parsedDate.isBefore(range.end);
}


  @override
  void initState() {
    super.initState();
    _fetchProductsDetails();
    _fetchSalesDetails();
  }

  Future<void> _fetchSalesDetails() async {
  final dbHelper = DatabaseHelper();
  final fetchedSales = await dbHelper.getProducts();
  _updateSalesRows(fetchedSales);
}

  Future<void> _fetchProductsDetails() async {
    final dbHelper = DatabaseHelper();
    final fetchedProducts = await dbHelper.getProducts();
    _updateStockRows(fetchedProducts);
  }

  void _updateStockRows(List<Product> productList) {
    setState(() {
      stockRows = productList.map((product) => DataRow(cells: [
            DataCell(Text(product.productName)),
            DataCell(Text('${product.quantity}')),
            DataCell(Text(product.expiryDate)),
            DataCell(Text('${product.buyingPrice.toStringAsFixed(2)} Ksh')),
          ])).toList();
    });
  }

void _updateSalesRows(List<Product> productList) {
  setState(() {
    salesRows = productList.map((product) => DataRow(cells: [
      DataCell(Text(product.productName)),
      DataCell(Text('${product.soldQuantity}')),
      DataCell(Text('${product.quantity}')), 
      DataCell(Text('${product.sellingPrice.toStringAsFixed(2)} Ksh')),
      DataCell(Text('${(product.sellingPrice * product.soldQuantity).toStringAsFixed(2)} Ksh')),
    ])).toList();
  });
}

void _showFilterOptions() {
  showModalBottomSheet(
    context: context,
    builder: (context) {
      return Container(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              leading: const Icon(Icons.date_range),
              title: const Text('Filter by Date'),
              onTap: () {
                Navigator.pop(context); 
                _showDatePickerDialog();
              },
            ),
            ListTile(
              leading: const Icon(Icons.shopping_bag),
              title: const Text('Filter by Product'),
              onTap: () {
                Navigator.pop(context); 
                _promptForProductName();
              },
            ),
          ],
        ),
      );
    },
  );
}

void _promptForProductName() {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      TextEditingController productController = TextEditingController();
      return AlertDialog(
        title: const Text("Enter Product Name"),
        content: TextField(
          controller: productController,
          decoration: const InputDecoration(hintText: "Type product name here"),
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('Cancel'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: const Text('Filter'),
            onPressed: () {
              Navigator.of(context).pop();
              _filterByProductName(productController.text);
            },
          ),
        ],
      );
    },
  );
}



void _showDatePickerDialog() {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text("Choose Filter Type"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              title: const Text("Specific Date"),
              leading: const Icon(Icons.calendar_today),
              onTap: () {
                Navigator.pop(context);
                _selectDate(context);
              },
            ),
            ListTile(
              title: const Text("Date Range"),
              leading: const Icon(Icons.date_range),
              onTap: () {
                Navigator.pop(context);
                _selectDateRange(context);
              },
            )
          ],
        ),
      );
    }
  );
}

Future<void> _selectDate(BuildContext context) async {
  final DateTime? picked = await showDatePicker(
    context: context,
    initialDate: selectedDate ?? DateTime.now(),
    firstDate: DateTime(2000),
    lastDate: DateTime(2100),
    builder: (context, child) {
      return Theme(
        data: ThemeData.light().copyWith(
          colorScheme: const ColorScheme.light(
            primary: Colors.green,
            onPrimary: Colors.white, 
            onSurface: Colors.black, 
          ),
          dialogBackgroundColor: Colors.white,
        ),
        child: child!,
      );
    },
  );
  if (picked != null && picked != selectedDate) {
    setState(() {
      selectedDate = picked;
      _filterDataForDate(picked); 
    });
  }
}

Future<void> _selectDateRange(BuildContext context) async {
  final DateTimeRange? range = await showDateRangePicker(
    context: context,
    initialDateRange: selectedDateRange,
    firstDate: DateTime(2000),
    lastDate: DateTime.now(),
    builder: (context, child) {
      return Theme(
        data: ThemeData.light().copyWith(
          colorScheme: const ColorScheme.light(
            primary: Colors.green, 
            onPrimary: Colors.white, 
            onSurface: Colors.black, 
          ),
          dialogBackgroundColor: Colors.white,
        ),
        child: child!,
      );
    },
  );
  if (range != null && range != selectedDateRange) {
    setState(() {
      selectedDateRange = range;
      _filterDataForDateRange(range); 
    });
  }
}

void _filterDataForDate(DateTime date) {
  stockRows = stockRows.where((row) => matchesDate(const Row() as String, date)).toList();
   salesRows = salesRows.where((row) => matchesDate(const Row() as String, date)).toList();
  setState(() {});
}

void _filterDataForDateRange(DateTimeRange range) {
 
  stockRows = stockRows.where((row) => inDateRange(const Row() as String, range)).toList();
  salesRows = salesRows.where((row) => inDateRange(const Row() as String, range)).toList();
  setState(() {});
}

void _filterByProductName(String productName) {
  setState(() {
    stockRows = stockRows.where((row) => (row.cells[0].child as Text).data!.toLowerCase().contains(productName.toLowerCase())).toList();
    salesRows = salesRows.where((row) => (row.cells[0].child as Text).data!.toLowerCase().contains(productName.toLowerCase())).toList();
  });
}


  Future<void> _showExportDialog() async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Export Reports'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                _buildExportTile('Stock Reports', _exportStockReport),
                _buildExportTile('Sales Reports', _exportSalesReport),
               _buildExportTile('All Reports', _exportAllReports),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildExportTile(String title, Function() onPressed) {
    return ListTile(
      title: Text(title),
      onTap: onPressed,
    );
  }

  Future<void> _exportStockReport() async {
    if (await _checkAndRequestStoragePermission()) {
      _exportReport(stockRows, 'stock_reports');
    }
  }

  Future<void> _exportSalesReport() async {
    if (await _checkAndRequestStoragePermission()) {
      _exportReport(salesRows, 'sales_reports');
    }
  }

  Future<bool> _checkAndRequestStoragePermission() async {
    final status = await Permission.storage.status;
    if (!status.isGranted) {
      return await Permission.storage.request().isGranted;
    }
    return true;
  }

  Future<void> _exportReport(List<DataRow> dataRows, String fileNamePrefix) async {
    
    List<List<dynamic>> rows;
  if (fileNamePrefix == 'sales_reports') {
    rows = [
      ['Product Name', 'Quantity Sold', 'Current Stock', 'Unit Price (Ksh)', 'Total Price (Ksh)']
    ];
  } else {
    rows = [
      ['Product Name', 'Quantity', 'Expiry Date', 'Price (Ksh)']
    ];
  }
    
    for (var dataRow in dataRows) {
      List<dynamic> row = dataRow.cells.map((cell) => (cell.child as Text).data ?? '').toList();
      rows.add(row);
    }

    String timeStamp = DateTime.now().toString();
    String csv = const ListToCsvConverter().convert(rows);
    final String dir = (await getApplicationDocumentsDirectory()).path;
    final String path = '$dir/$fileNamePrefix$timeStamp.csv';

    final File file = File(path);
    await file.writeAsString(csv);
    await FlutterFileDialog.saveFile(params: SaveFileDialogParams(sourceFilePath: path));

    Fluttertoast.showToast(
      msg: "The CSV file successfully saved on downloads folder",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.black54,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  Future<void> _exportAllReports() async {
  if (!await _checkAndRequestStoragePermission()) return;

  List<List<dynamic>> combinedRows = [];

  // Adding Stock Reports
  combinedRows.add(['Stock Reports']);
  combinedRows.add(['Product Name', 'Quantity', 'Expiry Date', 'Price (Ksh)']);
  for (var dataRow in stockRows) {
    List<dynamic> row = dataRow.cells.map((cell) => (cell.child as Text).data ?? '').toList();
    combinedRows.add(row);
  }
  combinedRows.add(['']); // Add an empty row for separation

  // Adding Sales Reports
  combinedRows.add(['Sales Reports']);
  combinedRows.add(['Product Name', 'Quantity Sold', 'Current Stock', 'Unit Price (Ksh)', 'Total Price (Ksh)']);
  for (var dataRow in salesRows) {
    List<dynamic> row = dataRow.cells.map((cell) => (cell.child as Text).data ?? '').toList();
    combinedRows.add(row);
  }

  // Preparing to save the CSV
  String timeStamp = DateTime.now().toString();
  String csv = const ListToCsvConverter().convert(combinedRows);
  final String dir = (await getApplicationDocumentsDirectory()).path;
  final String path = '$dir/CombinedReports_$timeStamp.csv';

  final File file = File(path);
  await file.writeAsString(csv);
  await FlutterFileDialog.saveFile(params: SaveFileDialogParams(sourceFilePath: path));

  Fluttertoast.showToast(
    msg: "The CSV file with all reports successfully saved on downloads folder",
    toastLength: Toast.LENGTH_SHORT,
    gravity: ToastGravity.BOTTOM,
    timeInSecForIosWeb: 1,
    backgroundColor: Colors.black54,
    textColor: Colors.white,
    fontSize: 16.0,
  );
}


  Widget _buildReport() {
    return Expanded(
      flex: 5,
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columns: isStockSelected ? [
              const DataColumn(label: Text('Product Name')),
              const DataColumn(label: Text('Quantity')),
              const DataColumn(label: Text('Expiry Date')),
              const DataColumn(label: Text('Price (Ksh)')),
            ] : [
              const DataColumn(label: Text('Product Name')),
              const DataColumn(label: Text('Quantity Sold')),
              const DataColumn(label: Text('Current Stock')),
              const DataColumn(label: Text('Unit Price (Ksh)')),
              const DataColumn(label: Text('Total Price (Ksh)')),
            ],
            rows: isStockSelected ? stockRows : salesRows,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports'),
        centerTitle: false,
        backgroundColor: const Color.fromARGB(255, 8, 100, 11),
        leading: GestureDetector(
          onTap: () => Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const BottomNavigation())),
          child: const Icon(Icons.arrow_back),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list, color: Colors.white),
            onPressed: _showFilterOptions,
          ),
        ],
      ),
      backgroundColor: const Color.fromARGB(255, 203, 195, 195),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildReportButton('Stock Reports', true),
              _buildReportButton('Sales Reports', false),
            ],
          ),
          _buildReport(),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildReportButton(String title, bool forStock) {
    return Expanded(
      flex: 3,
      child: ElevatedButton(
        onPressed: () {
          setState(() {
            isStockSelected = forStock;
          });
        },
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.black,
          backgroundColor: isStockSelected == forStock ? Colors.white : const Color.fromARGB(255, 202, 184, 184),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          side: BorderSide.none,
        ),
        child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return Container(
      alignment: Alignment.bottomRight,
      margin: const EdgeInsets.all(16.0),
      child: SizedBox(
        width: 120,
        height: 40,
        child: ElevatedButton(
          onPressed: _showExportDialog,
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.black,
            backgroundColor: const Color.fromARGB(255, 214, 212, 212),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.download),
              SizedBox(width: 4),
              Text('Export', style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }
}