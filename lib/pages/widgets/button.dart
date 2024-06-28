import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final Function()? onTap;
  final String? text;
  final double? padding;
  final double? margin;
  final Color? color;

  const CustomButton({
    super.key,
    required this.onTap,
    this.text,
    this.padding = 20,
    this.margin = 20,
    this.color = Colors.black,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(padding!),
        margin: EdgeInsets.symmetric(horizontal: margin!),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Center(
          child: Text(
            text!,
            style: const TextStyle(
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
