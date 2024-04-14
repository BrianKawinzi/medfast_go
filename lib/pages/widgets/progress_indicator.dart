import 'package:flutter/material.dart';

class MyCircularProgressIndicator extends StatelessWidget {
  final String title;
  final String value;
  final Color color;
  final double size;
  final double strokeWidth;

  const MyCircularProgressIndicator({
    Key? key,
    required this.title,
    required this.value,
    required this.color,
    this.size = 100.0,
    this.strokeWidth = 8.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          CircularProgressIndicator(
            strokeWidth: strokeWidth,
            valueColor: AlwaysStoppedAnimation<Color>(color),
            value:
                1.0, // Assuming you want to show it as full for static display
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
