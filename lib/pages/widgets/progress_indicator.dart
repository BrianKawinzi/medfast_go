 import 'package:flutter/material.dart';
import 'package:medfast_go/pages/components/circular_progress.dart';
 
 Widget buildHorizontalProgressIndicators(
    String title1,
    int percentage1,
    Color color1,
    String title2,
    int percentage2,
    Color color2,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          MyCircularProgressIndicator(title: title1, percentage: percentage1, color: color1),
          const SizedBox(width: 16.0),
          MyCircularProgressIndicator(title: title2, percentage: percentage2, color: color2),
        ],
      ),
    );
  }