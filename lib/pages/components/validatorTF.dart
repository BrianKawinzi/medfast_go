import 'package:flutter/material.dart';

class ValidatorTF extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final bool obscureText;
  final String Function(String?)? validator;
  final void Function(String?)? onSaved;

  const ValidatorTF({
    Key? key,
    required this.controller,
    required this.hintText,
    required this.obscureText,
    required this.validator,
    required this.onSaved,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.grey[500]),
        ),
        validator: validator,
        onSaved: onSaved, // This is used when this widget is part of a Form
      ),
    );
  }
}
