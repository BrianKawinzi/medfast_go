import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:medfast_go/pages/components/my_button.dart';
import 'package:medfast_go/pages/components/normal_tf.dart';
import 'verification_page.dart';

class ForgotPassword extends StatelessWidget {
  ForgotPassword({super.key});

  // Text editing controllers
  final emailController = TextEditingController();

  // Send code method
  void sendCode(BuildContext context) async {
    final email = emailController.text;
    if (email.isNotEmpty) {
      // Send a request to the API
      final response = await http.post(
        Uri.parse(
            'https://medrxapi.azurewebsites.net/api/Account/request-password-reset'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: '{"email": "$email"}',
      );

      if (response.statusCode == 200) {
        // Store email in SharedPreferences
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('email', email);

        // Navigate to verification page
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const VerificationPage()),
        );
      } else {
        // Handle error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send code')),
        );
      }
    } else {
      // Handle empty email
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter your email')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.center, // Align children to the center
              children: [
                // Back button
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded),
                      onPressed: () {
                        // Navigate back to the previous screen
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 50),

                // Forgot password text
                const Text(
                  'Forgot Password?',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 30,
                  ),
                  textAlign: TextAlign.center, // Center the text
                ),

                const SizedBox(height: 10),

                // Don't worry text
                Text(
                  'Don\'t worry! It occurs. Please enter the email address linked with your account.',
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center, // Center the text
                ),

                const SizedBox(height: 50),

                // Enter your email textfield
                normalTF(
                  controller: emailController,
                  hintText: 'Enter your email',
                  obscureText: false,
                ),

                const SizedBox(height: 25),

                // Send code button
                MyButton(
                  onTap: () => sendCode(context),
                  buttonText: "Send Code",
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
