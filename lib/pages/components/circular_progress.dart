import 'package:flutter/material.dart';


class MyCircularProgressIndicator extends StatelessWidget {
  final String title;
  final int percentage;
  final Color color;


  const MyCircularProgressIndicator({
    required this.title,
    required this.percentage,
    required this.color,
    super.key
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 100.0,
              height: 100.0,
              child: CircularProgressIndicator(
                value: percentage / 100,
                strokeWidth: 10.0,
                valueColor: AlwaysStoppedAnimation<Color>(color),
                backgroundColor: Colors.grey[300],
              ),
            ),
            Text(
              '$percentage%',
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 16.0,
              ),
            ),
          ],
        ),
        SizedBox(height: 8.0),
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