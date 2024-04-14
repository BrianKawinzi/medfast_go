import 'package:flutter/material.dart';

class MyCircularProgressIndicator extends StatelessWidget {
  final String title;
  final String value;
  final Color color;
  final double size;
  final double strokeWidth;
  final double percentage; // New field to handle dynamic progress

  const MyCircularProgressIndicator({
    Key? key,
    required this.title,
    required this.value,
    required this.color,
    this.size = 100.0,
    this.strokeWidth = 8.0,
    this.percentage = 100.0, // Default to 100% completion
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Calculate the progress value from the percentage
    double progressValue = percentage / 100;

    return Container(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          CircularProgressIndicator(
            strokeWidth: strokeWidth,
            valueColor: AlwaysStoppedAnimation<Color>(color),
            value: progressValue, // Use the calculated progress value
          ),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 16.0,
            ),
          ),
        ],
      ),
    );
  }
}
