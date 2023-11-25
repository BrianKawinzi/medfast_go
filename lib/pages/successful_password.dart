import 'package:flutter/material.dart';
import 'package:medfast_go/pages/components/my_button.dart';

class SuccessfulPassword extends StatelessWidget {
  const SuccessfulPassword({super.key});

  void backLogin(BuildContext context) {

    Navigator.of(context).pushReplacementNamed('/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'lib/assets/Successmark.png',
            ),
            const SizedBox(height: 20),
            //Password Changed
            const Text(
              'Password Changed!',
              style: TextStyle(fontSize: 30, color: Colors.black),
            ),

            const SizedBox(height: 10),

            //Your password has been changed successfully
            Text(
              'Your password has been changed successfully.',
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),

            //Back to Login button
            MyButton(onTap: () {
              backLogin(context);
            }, buttonText: "Back to Login",
            ),
          ],
        ),
      ),
    );
  }
}