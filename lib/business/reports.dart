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
  int? expandedIndex;
  List<DataRow> stockRows = [];
  List<DataRow> salesRows = [];
  bool isStockSelected = true;
  SalesHistoryManager salesHistoryManager = SalesHistoryManager();

  @override
  void initState() {
    super.initState();
    _fetchProductsDetails();
    _initializeSalesHistory();
  }

  Future<void> _initializeSalesHistory() async {
    await salesHistoryManager.initializeSalesHistory();
    _updateSalesRows();
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

  void _updateSalesRows() {
    setState(() {
      salesRows = salesHistoryManager.salesHistory.map((history) => DataRow(cells: [
            DataCell(Text(history.productName)),
            DataCell(Text(history.quantitySold.toString())),
            DataCell(Text(history.currentStock.toString())),
            DataCell(Text(history.unitPrice.toStringAsFixed(2))),
            DataCell(Text(history.totalPrice.toStringAsFixed(2))),
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
                leading: Icon(Icons.date_range),
                title: Text('Filter by Date'),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: Icon(Icons.shopping_bag),
                title: Text('Filter by Product'),
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      },
    );
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
                _buildExportTile('All Reports', () => Navigator.pop(context)),
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
    final List<List<dynamic>> rows = [
      ['Product Name', 'Quantity', 'Expiry Date', 'Price (Ksh)']
    ];
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
      backgroundColor: Color.fromARGB(255, 203, 195, 195),
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
          backgroundColor: isStockSelected == forStock ? Colors.white : Color.fromARGB(255, 202, 184, 184),
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
