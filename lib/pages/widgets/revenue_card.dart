import 'dart:math';
import 'package:flutter/material.dart';
import 'package:medfast_go/data/DatabaseHelper.dart';

class RevenueCard extends StatefulWidget {
  final List<String> monthNames;
  final int selectedMonthIndex;
  final Future<double> Function(String) calculateTotalRevenue;
  final Function(String?) onMonthChanged;

  RevenueCard({
    Key? key,
    required this.monthNames,
    required this.selectedMonthIndex,
    required this.calculateTotalRevenue,
    required this.onMonthChanged,
  }) : super(key: key);

  @override
  _RevenueCardState createState() => _RevenueCardState();
}

class _RevenueCardState extends State<RevenueCard> {
  late int _selectedMonthIndex;

  @override
  void initState() {
    super.initState();
    _selectedMonthIndex = widget.selectedMonthIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5.0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total \n Revenue',
                    style: TextStyle(fontSize: 12.0, color: Colors.grey)),
                FutureBuilder<double>(
                  future: widget.calculateTotalRevenue(
                      widget.monthNames[_selectedMonthIndex]),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    } else if (snapshot.hasData) {
                      return Text('KSH ${snapshot.data!.toStringAsFixed(0)}',
                          style: TextStyle(
                              fontSize: 18.0, fontWeight: FontWeight.bold));
                    } else {
                      return const Text('Error',
                          style: TextStyle(
                              fontSize: 18.0, fontWeight: FontWeight.bold));
                    }
                  },
                ),
                DropdownButton<String>(
                  value: widget.monthNames[_selectedMonthIndex],
                  icon: const Icon(Icons.arrow_drop_down),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedMonthIndex =
                          widget.monthNames.indexOf(newValue!);
                      widget.onMonthChanged(newValue);
                    });
                  },
                  items: widget.monthNames
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ],
            ),
            SizedBox(
              height: 180,
              child: IndividualBar(
                selectedMonthIndex: _selectedMonthIndex,
                monthlyAmounts:
                    List.generate(12, (index) => Random().nextDouble() * 1000),
            
              ),
            )
          ],
        ),
      ),
    );
  }
}

// IndividualBar and related classes included in the same file
class IndividualBar extends StatefulWidget {
  final int selectedMonthIndex;
  final List<double> monthlyAmounts;

  const IndividualBar({
    Key? key,
    required this.selectedMonthIndex,
    required this.monthlyAmounts,
  }) : super(key: key);

  @override
  State<IndividualBar> createState() => _IndividualBarState();
}

class _IndividualBarState extends State<IndividualBar> {
  late List<BarData> barData;
  

  @override
  void initState() {
    super.initState();
    initializeBarData();
    
  }

  void initializeBarData() {
    barData = List.generate(
      widget.monthlyAmounts.length,
      (index) => BarData(getMonthLabel(index), widget.monthlyAmounts[index]),
    );
  }
  

  String getMonthLabel(int monthNumber) {
    switch (monthNumber) {
      case 0:
        return '';
      case 1:
        return 'Jan';
      case 2:
        return 'Feb';
      case 3:
        return 'Mar';
      case 4:
        return 'Apr';
      case 5:
        return 'May';
      case 6:
        return 'Jun';
      case 7:
        return 'Jul';
      case 8:
        return 'Aug';
      case 9:
        return 'Sep';
      case 10:
        return 'Oct';
      case 11:
        return 'Nov';
      case 12:
        return 'Dec';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      child: BarChart(
        barData: barData,
        selectedMonthIndex: widget
            .selectedMonthIndex, // Assuming `x` is the month number (1-indexed)
      ),
    );
  }
}

class BarChart extends StatelessWidget {
  final List<BarData> barData;
  final int selectedMonthIndex;

  const BarChart({
    required this.barData,
    required this.selectedMonthIndex,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double maxRevenue = 0.0; // Default value

// Check if barData is not empty before calling reduce
    if (barData.isNotEmpty) {
      maxRevenue = barData.map((data) => data.value).reduce(max);
    }


    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: barData.asMap().entries.map((entry) {
            return Bar(
              value: entry.value.value,
              color: Color.fromARGB(255, 174, 176, 172),
              maxRevenue: maxRevenue,
              isHighlighted: entry.key == selectedMonthIndex,
            );
          }).toList(),
        ),
        Container(
          margin: const EdgeInsets.only(top: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: barData
                .map((data) =>
                    Text(data.label, style: TextStyle(fontSize: 12.0)))
                .toList(),
          ),
        ),
      ],
    );
  }
}

class Bar extends StatelessWidget {
  final double value;
  final double maxRevenue;
  final Color color;
  final bool isHighlighted;

  const Bar({
    required this.value,
    required this.color,
    required this.maxRevenue,
    this.isHighlighted = false,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double scaledValue = (value / maxRevenue) * 150.0;
    return AnimatedContainer(
      duration: Duration(milliseconds: 500),
      curve: Curves.easeInOut,
      width: 20.0,
      height: scaledValue,
      color: isHighlighted ? Color.fromARGB(255, 54, 244, 76) : color,
    );
  }
}

class BarData {
  final String label;
  final double value;

  BarData(this.label, this.value);
}
