import 'package:flutter/material.dart';
import 'package:medfast_go/pages/home_page.dart';

class Reports extends StatefulWidget {
  const Reports({Key? key}) : super(key: key);

  @override
  _ReportsState createState() => _ReportsState();
}

class _ReportsState extends State<Reports> {
  DateTimeRange? selectedDateRange;
  int? expandedIndex;

  String _getFormattedDate(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month}';
  }

  String _selectedFilterOption = 'Filter by';

  void _changeFilterOption(String option) {
    setState(() {
      _selectedFilterOption = option;
    });
  }

  Widget _buildExportTile(String title, Function() onPressed) {
    return ListTile(
      title: Text(title),
      onTap: onPressed,
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
                _buildExportTile('Stock Reports', () {
                  // Logic to export stock reports
                  Navigator.pop(context);
                }),
                _buildExportTile('Sales Reports', () {
                  // Logic to export sales reports
                  Navigator.pop(context);
                }),
                _buildExportTile('Order Reports', () {
                  // Logic to export order reports
                  Navigator.pop(context);
                }),
                _buildExportTile('All Reports', () {
                  // Logic to export all reports
                  Navigator.pop(context);
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  void _toggleExpand(int index) {
    setState(() {
      if (expandedIndex == index) {
        expandedIndex = null;
      } else {
        expandedIndex = index;
      }
    });
  }

  Widget _buildReport(
    String title,
    List<DataColumn> columns,
    List<DataRow> rows,
    int index,
  ) {
    return GestureDetector(
      onTap: () {
        if (expandedIndex == null) {
          _toggleExpand(index);
        } else {
          setState(() {
            expandedIndex = null;
          });
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.only(bottom: 16.0),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black, width: 3.0),
          borderRadius: BorderRadius.circular(10.0),
          color: Colors.white,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    _toggleExpand(index);
                  },
                  icon: Icon(
                    expandedIndex == index
                        ? Icons.expand_less
                        : Icons.expand_more,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
            if (expandedIndex == index)
              SingleChildScrollView(
                child: DataTable(
                  columns: columns,
                  rows: rows,
                ),
              ),
          ],
        ),
      ),
    );
  }

  int getCrossAxisCount(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth > 1200) {
      return 4; // Large screens
    } else if (screenWidth > 600) {
      return 3; // Medium-sized screens
    } else {
      return 2; // Smaller screens
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports'),
        centerTitle: false,
        backgroundColor: Colors.green,
        leading: GestureDetector(
          onTap: () {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => const HomePage(),
              ),
            );
          },
          child: const Icon(Icons.arrow_back),
        ),
        actions: [
          /*Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
                ),
              ),
            ),
          ),*/
          TextButton(
            onPressed: () async {
              final DateTimeRange? pickedDateRange = await showDateRangePicker(
                context: context,
                firstDate: DateTime(2000),
                lastDate: DateTime.now(),
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

              if (pickedDateRange != null) {
                setState(() {
                  selectedDateRange = pickedDateRange;
                });
              }
            },
            child: Text(
              selectedDateRange != null
                  ? '${_getFormattedDate(selectedDateRange!.start)} - ${_getFormattedDate(selectedDateRange!.end)}'
                  : 'Select Date Range',
              style:
                  TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
            ),
            style: TextButton.styleFrom(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 8),
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedFilterOption,
                icon: const Icon(Icons.filter_alt),
                iconSize: 24,
                elevation: 16,
                style: const TextStyle(
                    color: Colors.black, fontWeight: FontWeight.bold),
                dropdownColor: Colors.white,
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    _changeFilterOption(newValue);
                  }
                },
                items: <String>[
                  'Filter by',
                  'Filter by Product',
                  'Filter by Price',
                  'Filter by Quantity'
                ].map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
      backgroundColor: Colors.green,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildReport(
              'Stock Report',
              [
                DataColumn(label: Text('Product Name')),
                DataColumn(label: Text('Product ID')),
                DataColumn(label: Text('Date Added')),
                DataColumn(label: Text('Price')),
                DataColumn(label: Text('Stock Status')),
                DataColumn(label: Text('Quantity')),
              ],
              [
                DataRow(cells: [
                  DataCell(Text('Product A')),
                  DataCell(Text('ID-001')),
                  DataCell(Text('2023-11-01')),
                  DataCell(Text('\Ksh70')),
                  DataCell(Text('In Stock')),
                  DataCell(Text('100')),
                ]),
                DataRow(cells: [
                  DataCell(Text('Product B')),
                  DataCell(Text('ID-002')),
                  DataCell(Text('2023-11-05')),
                  DataCell(Text('\Ksh50')),
                  DataCell(Text('Out of Stock')),
                  DataCell(Text('50')),
                ]),
              ],
              0,
            ),
            _buildReport(
              'Sales Report',
              [
                DataColumn(label: Text('Product Name')),
                DataColumn(label: Text('Initial Stock')),
                DataColumn(label: Text('Current Stock')),
                DataColumn(label: Text('Sold Stock')),
              ],
              [
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
              ],
              1,
            ),
            _buildReport(
              'Orders Report',
              [
                DataColumn(label: Text('Product Name')),
                DataColumn(label: Text('Order Stock')),
                DataColumn(label: Text('Date of Order')),
                DataColumn(label: Text('Order Status')),
              ],
              [
                DataRow(cells: [
                  DataCell(Text('Product A')),
                  DataCell(Text('50')),
                  DataCell(Text('2023-11-15')),
                  DataCell(Text('Pending')),
                ]),
                DataRow(cells: [
                  DataCell(Text('Product B')),
                  DataCell(Text('20')),
                  DataCell(Text('2023-11-20')),
                  DataCell(Text('Delivered')),
                ]),
              ],
              2,
            ),
          ],
        ),
      ),
      floatingActionButton: Container(
        alignment: Alignment.bottomRight,
        margin: const EdgeInsets.all(16.0),
        child: SizedBox(
          width: 120,
          height: 40,
          child: ElevatedButton(
            onPressed: _showExportDialog,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
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
            style: ElevatedButton.styleFrom(
              primary: Colors.white,
              onPrimary: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
