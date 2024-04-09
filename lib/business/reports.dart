import 'dart:io';
import 'package:flutter/material.dart';
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

  @override
  void initState() {
    super.initState();
    _fetchProductsDetails();
  }

  Future<void> _fetchProductsDetails() async {
    final dbHelper = DatabaseHelper();
    final fetchedProducts = await dbHelper.getProducts();
    _updateStockRows(fetchedProducts);
    _updateSalesRows();
  }

  void _updateStockRows(List<Product> productList) {
    setState(() {
      stockRows = productList
          .map((product) => DataRow(cells: [
                DataCell(Text(product.productName)),
                DataCell(Text('1')),
                DataCell(Text(product.expiryDate)),
                DataCell(Text('${product.buyingPrice}')),
              ]))
          .toList();
    });
  }

  void _updateSalesRows() {
    // Placeholder data, replace with actual sales data
    setState(() {
      salesRows = [
        DataRow(cells: [
          DataCell(Text('Product A')),
          DataCell(Text('100')),
          DataCell(Text('80')),
          DataCell(Text('20')),
        ]),
        DataRow(cells: [
          DataCell(Text('Product B')),
          DataCell(Text('50')),
          DataCell(Text('30')),
          DataCell(Text('20')),
        ]),
      ];
    });
  }

  String _getFormattedDate(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}';
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
                onTap: () {
                  // Handle date filter
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(Icons.shopping_bag),
                title: Text('Filter by Product'),
                onTap: () {
                  // Handle product filter
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildExportTile(String title, Function() onPressed) {
    return ListTile(
      title: Text(title),
      onTap: () => onPressed(),
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
                _buildExportTile('All Reports', () {
                  Navigator.pop(context);
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _exportStockReport() async {
    final status = await Permission.storage.status;
    if (!status.isGranted) {
      await Permission.storage.request();
    }

    if (await Permission.storage.isGranted) {
      final List<List<dynamic>> rows = [
        ['Product Name', 'Quantity', 'Expiry Date', 'Price (Ksh)']
      ];

      for (var dataRow in stockRows) {
        List<dynamic> row = dataRow.cells.map((cell) {
          String cellContent = cell.child.runtimeType == Text
              ? (cell.child as Text).data ?? ''
              : '';
          cellContent = cellContent.replaceAll("Text(", "").replaceAll(")", "");
          cellContent = cellContent.replaceAll('"', '').trim();

          return cellContent;
        }).toList();

        rows.add(row);
      }

      String timeStamp = DateTime.now().toString();
      String csv = const ListToCsvConverter().convert(rows);
      final String dir = (await getApplicationDocumentsDirectory()).path;
      final String path = '$dir/stock_reports$timeStamp.csv';

      final File file = File(path);
      await file.writeAsString(csv);

      await FlutterFileDialog.saveFile(
          params: SaveFileDialogParams(
            sourceFilePath: path,
          ));

      // Display toast message
      Fluttertoast.showToast(
        msg: "The CSV file successfully saved on downloads folder",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.black54,
        textColor: Colors.white,
        fontSize: 16.0,
      );

      Navigator.pop(context);
    } else {
      print("Storage permission denied");
    }
  }

  Future<void> _exportSalesReport() async {
    final status = await Permission.storage.status;
    if (!status.isGranted) {
      await Permission.storage.request();
    }

    if (await Permission.storage.isGranted) {
      final List<List<dynamic>> rows = [
        ['Product Name', 'Initial Stock', 'Current Stock', 'Sold Stock']
      ];

      for (var dataRow in salesRows) {
        List<dynamic> row = dataRow.cells.map((cell) {
          String cellContent = cell.child.runtimeType == Text
              ? (cell.child as Text).data ?? ''
              : '';
          cellContent = cellContent.replaceAll("Text(", "").replaceAll(")", "");
          cellContent = cellContent.replaceAll('"', '').trim();

          return cellContent;
        }).toList();

        rows.add(row);
      }

      String timeStamp = DateTime.now().toString();
      String csv = const ListToCsvConverter().convert(rows);
      final String dir = (await getApplicationDocumentsDirectory()).path;
      final String path = '$dir/sales_reports$timeStamp.csv';

      final File file = File(path);
      await file.writeAsString(csv);

      await FlutterFileDialog.saveFile(
          params: SaveFileDialogParams(
            sourceFilePath: path,
          ));

      // Display toast message
      Fluttertoast.showToast(
        msg: "The CSV file successfully saved on downloads folder",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.black54,
        textColor: Colors.white,
        fontSize: 16.0,
      );

      Navigator.pop(context);
    } else {
      print("Storage permission denied");
    }
  }

  Widget _buildReport(
    List<DataColumn> columns,
    List<DataRow> rows,
  ) {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: columns,
          rows: rows,
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
        onTap: () {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => const BottomNavigation(),
            ),
          );
        },
        child: const Icon(Icons.arrow_back,),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.filter_list,
          color: Colors.white,),
          onPressed: () {
            _showFilterOptions();
          },
        ),
      ],
    ),
    backgroundColor: Color.fromARGB(255, 203, 195, 195),
    body: Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              flex: 3,  
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    isStockSelected = true;
                  });
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.black, backgroundColor: isStockSelected ? Colors.white : Color.fromARGB(255, 202, 184, 184),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(10),
                      bottomLeft: Radius.circular(10),
                    ),
                  ),
                  side: BorderSide.none,
                ),
                child: const Text(
                  'Stock Reports',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
            Expanded(
              flex: 3,  
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    isStockSelected = false;
                  });
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.black, backgroundColor: isStockSelected ? Colors.grey : Colors.white,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(10),
                      bottomRight: Radius.circular(10),
                    ),
                  ),
                  side: BorderSide.none,
                ),
                child: const Text(
                  'Sales Reports',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
        Expanded(
          flex: 5,
          child: _buildReport(
            isStockSelected
                ? [
                    const DataColumn(label: Text('Product Name')),
                    const DataColumn(label: Text('Quantity')),
                    const DataColumn(label: Text('Expiry Date')),
                    const DataColumn(label: Text('Price (Ksh)')),
                  ]
                : [
                    const DataColumn(label: Text('Product Name')),
                    const DataColumn(label: Text('Initial Stock')),
                    const DataColumn(label: Text('Current Stock')),
                    const DataColumn(label: Text('Sold Stock')),
                  ],
            isStockSelected ? stockRows : salesRows,
          ),
        ),
      ],
    ),
    floatingActionButton: Container(
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
              Text(
                'Export',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
}
