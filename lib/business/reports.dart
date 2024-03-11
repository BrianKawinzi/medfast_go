import 'package:flutter/material.dart';
import 'package:medfast_go/pages/bottom_navigation.dart';

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
        backgroundColor: const Color.fromARGB(255, 8, 100, 11),
        leading: GestureDetector(
          onTap: () {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => const BottomNavigation(),
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
            style: TextButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 30, 136, 9),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
            child: Text(
              selectedDateRange != null
                  ? '${_getFormattedDate(selectedDateRange!.start)} - ${_getFormattedDate(selectedDateRange!.end)}'
                  : 'Select Date Range',
              style: const TextStyle(
                  color: Colors.black, fontWeight: FontWeight.bold),
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 8),
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 29, 122, 11),
              borderRadius: BorderRadius.circular(10),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedFilterOption,
                icon: const Icon(Icons.filter_alt),
                iconSize: 24,
                iconEnabledColor: const Color.fromARGB(255, 233, 223, 223),
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
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildReport(
              'Stock Report',
              [
                const DataColumn(label: Text('Product Name')),
                const DataColumn(label: Text('Product ID')),
                const DataColumn(label: Text('Date Added')),
                const DataColumn(label: Text('Price')),
                const DataColumn(label: Text('Stock Status')),
                const DataColumn(label: Text('Quantity')),
              ],
              [
                const DataRow(cells: [
                  DataCell(Text('Product A')),
                  DataCell(Text('ID-001')),
                  DataCell(Text('2023-11-01')),
                  DataCell(Text('Ksh70')),
                  DataCell(Text('In Stock')),
                  DataCell(Text('100')),
                ]),
                const DataRow(cells: [
                  DataCell(Text('Product B')),
                  DataCell(Text('ID-002')),
                  DataCell(Text('2023-11-05')),
                  DataCell(Text('Ksh50')),
                  DataCell(Text('Out of Stock')),
                  DataCell(Text('50')),
                ]),
              ],
              0,
            ),
            _buildReport(
              'Sales Report',
              [
                const DataColumn(label: Text('Product Name')),
                const DataColumn(label: Text('Initial Stock')),
                const DataColumn(label: Text('Current Stock')),
                const DataColumn(label: Text('Sold Stock')),
              ],
              [
                const DataRow(cells: [
                  DataCell(Text('Product A')),
                  DataCell(Text('100')),
                  DataCell(Text('80')),
                  DataCell(Text('20')),
                ]),
                const DataRow(cells: [
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
                const DataColumn(label: Text('Product Name')),
                const DataColumn(label: Text('Order Stock')),
                const DataColumn(label: Text('Date of Order')),
                const DataColumn(label: Text('Order Status')),
              ],
              [
                const DataRow(cells: [
                  DataCell(Text('Product A')),
                  DataCell(Text('50')),
                  DataCell(Text('2023-11-15')),
                  DataCell(Text('Pending')),
                ]),
                const DataRow(cells: [
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
