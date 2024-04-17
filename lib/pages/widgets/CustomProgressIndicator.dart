import 'package:flutter/material.dart';
import 'dart:math' as math;

class CustomProgressIndicator extends StatelessWidget {
  final String title;
  final String value;
  final Color color;
  final double size;
  final double strokeWidth;
  final double percentage; // Add a percentage parameter

  const CustomProgressIndicator({
    Key? key,
    required this.title,
    required this.value,
    required this.color,
    this.size = 150,
    this.strokeWidth = 10,
    this.percentage = 100,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double progressValue = percentage / 100;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: size,
          height: size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CircularProgressIndicator(
                strokeWidth: strokeWidth,
                value: progressValue, // Use the calculated progress value here
                valueColor: AlwaysStoppedAnimation<Color>(color),
                backgroundColor: Colors.grey[300],
              ),
              Text(
                value,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: size / 5,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        SizedBox(height: 8),
        Text(
          title,
          style: TextStyle(
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}
