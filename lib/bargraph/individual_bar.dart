// import 'dart:math';

// import 'package:flutter/material.dart';

// class IndividualBar extends StatefulWidget {
//   final int x;
//   final List<double> monthlyAmounts;

//   const IndividualBar({
//     required this.x,
//     required this.monthlyAmounts,
//     Key? key,
//   }) : super(key: key);

//   @override
//   State<IndividualBar> createState() => _IndividualBarState();
// }

// class _IndividualBarState extends State<IndividualBar> {
//   late List<BarData> barData;

//   @override
//   void initState() {
//     super.initState();
//     initializeBarData();
//   }

//   void initializeBarData() {
//     barData = List.generate(
//       widget.monthlyAmounts.length,
//       (index) =>
//           BarData(getMonthLabel(index + 1), widget.monthlyAmounts[index]),
//     );
//   }

//   String getMonthLabel(int monthNumber) {
//     switch (monthNumber) {
//       case 1:
//         return 'Jan';
//       case 2:
//         return 'Feb';
//       case 3:
//         return 'Mar';
//       case 4:
//         return 'Apr';
//       case 5:
//         return 'May';
//       case 6:
//         return 'Jun';
//       case 7:
//         return 'Jul';
//       case 8:
//         return 'Aug';
//       case 9:
//         return 'Sep';
//       case 10:
//         return 'Oct';
//       case 11:
//         return 'Nov';
//       case 12:
//         return 'Dec';
//       default:
//         return '';
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       height: 200,
//       child: BarChart(
//         barData: barData,
//         selectedMonthIndex:
//             widget.x - 1, // Assuming `x` is the month number (1-indexed)
//       ),
//     );
//   }
// }

// class BarChart extends StatelessWidget {
//   final List<BarData> barData;
//   final int selectedMonthIndex;

//   const BarChart({
//     required this.barData,
//     this.selectedMonthIndex = -1,
//     Key? key,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     double maxRevenue = barData.map((data) => data.value).reduce(max);

//     return Column(
//       mainAxisAlignment: MainAxisAlignment.end,
//       children: [
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//           crossAxisAlignment: CrossAxisAlignment.end,
//           children: barData.asMap().entries.map((entry) {
//             return Bar(
//               value: entry.value.value,
//               color: Color.fromARGB(255, 174, 176, 172),
//               maxRevenue: maxRevenue,
//               isHighlighted: entry.key == selectedMonthIndex,
//             );
//           }).toList(),
//         ),
//         Container(
//           margin: const EdgeInsets.only(top: 8.0),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//             children: barData
//                 .map((data) =>
//                     Text(data.label, style: TextStyle(fontSize: 12.0)))
//                 .toList(),
//           ),
//         ),
//       ],
//     );
//   }
// }

// class Bar extends StatelessWidget {
//   final double value;
//   final double maxRevenue;
//   final Color color;
//   final bool isHighlighted;

//   const Bar({
//     required this.value,
//     required this.color,
//     required this.maxRevenue,
//     this.isHighlighted = false,
//     Key? key,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     double scaledValue = (value / maxRevenue) * 150.0;
//     return AnimatedContainer(
//       duration: Duration(milliseconds: 500),
//       curve: Curves.easeInOut,
//       width: 20.0,
//       height: scaledValue,
//       color: isHighlighted ? Color.fromARGB(255, 54, 244, 76) : color,
//     );
//   }
// }

// class BarData {
//   final String label;
//   final double value;

//   BarData(this.label, this.value);
// }
