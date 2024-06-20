import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CommonUtils {
  static showToast(String s, {Color color = Colors.black}) {
    Get.showSnackbar(
      GetSnackBar(
        backgroundColor: color,
        message: s,
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        borderRadius: 8.0,
      ),
    );
  }

  static Widget nameAndValue({required String name, required String value}) {
    return Row(
      children: [
        Text(
          "$name : ",
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        Text(
          value,
        )
      ],
    );
  }
}
