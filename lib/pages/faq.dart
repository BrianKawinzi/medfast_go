import 'package:flutter/material.dart';
import 'package:medfast_go/pages/bottom_navigation.dart';

class FAQ extends StatelessWidget {
  const FAQ({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('FAQ'),
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
