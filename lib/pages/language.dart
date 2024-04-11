import 'package:flutter/material.dart';
import 'package:medfast_go/pages/bottom_navigation.dart';

class Language extends StatelessWidget {
  const Language({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Language'),
          centerTitle: true,
          backgroundColor: const Color.fromRGBO(58, 205, 50, 1),
          leading: GestureDetector(
            onTap: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => const BottomNavigation(),
                ),
              );
            },
            child: const Icon(Icons.arrow_back),
          ),
        ),
      );
}
