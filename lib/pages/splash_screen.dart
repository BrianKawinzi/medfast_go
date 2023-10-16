import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pushReplacementNamed(context, '/brandintro');
    });

    return Scaffold(
      backgroundColor: Colors.green,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'lib/assets/Medrxlogo.png',
             
            ),
            const SizedBox(height: 20), // Optional: Add some spacing between the logo and text
            const Text(
              'MedFast',
              style: TextStyle(fontSize: 18, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
