import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:medfast_go/pages/components/my_button.dart';

class VerificationPage extends StatefulWidget {
  const VerificationPage({super.key});

  @override
  _VerificationPageState createState() => _VerificationPageState();
}

class _VerificationPageState extends State<VerificationPage> {
  // Create text editing controllers for each text field
  final TextEditingController codeController1 = TextEditingController();
  final TextEditingController codeController2 = TextEditingController();
  final TextEditingController codeController3 = TextEditingController();
  final TextEditingController codeController4 = TextEditingController();
  final TextEditingController codeController5 = TextEditingController();
  final TextEditingController codeController6 = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  // Create focus nodes for each text field
  final FocusNode focusNode1 = FocusNode();
  final FocusNode focusNode2 = FocusNode();
  final FocusNode focusNode3 = FocusNode();
  final FocusNode focusNode4 = FocusNode();
  final FocusNode focusNode5 = FocusNode();
  final FocusNode focusNode6 = FocusNode();
  final FocusNode passwordFocusNode = FocusNode();
  final FocusNode confirmPasswordFocusNode = FocusNode();

  String email = '';

  @override
  void initState() {
    super.initState();
    _loadEmail();

    // Add listeners to detect changes in text
    codeController1.addListener(() {
      if (codeController1.text.isEmpty) {
        FocusScope.of(context).requestFocus(focusNode1);
      } else if (codeController1.text.length == 1) {
        FocusScope.of(context).requestFocus(focusNode2);
      }
    });

    codeController2.addListener(() {
      if (codeController2.text.isEmpty) {
        FocusScope.of(context).requestFocus(focusNode1);
      } else if (codeController2.text.length == 1) {
        FocusScope.of(context).requestFocus(focusNode3);
      }
    });

    codeController3.addListener(() {
      if (codeController3.text.isEmpty) {
        FocusScope.of(context).requestFocus(focusNode2);
      } else if (codeController3.text.length == 1) {
        FocusScope.of(context).requestFocus(focusNode4);
      }
    });

    codeController4.addListener(() {
      if (codeController4.text.isEmpty) {
        FocusScope.of(context).requestFocus(focusNode3);
      } else if (codeController4.text.length == 1) {
        FocusScope.of(context).requestFocus(focusNode5);
      }
    });

    codeController5.addListener(() {
      if (codeController5.text.isEmpty) {
        FocusScope.of(context).requestFocus(focusNode4);
      } else if (codeController5.text.length == 1) {
        FocusScope.of(context).requestFocus(focusNode6);
      }
    });

    codeController6.addListener(() {
      if (codeController6.text.isEmpty) {
        FocusScope.of(context).requestFocus(focusNode5);
      } else if (codeController6.text.length == 1) {
        FocusScope.of(context).requestFocus(passwordFocusNode);
      }
    });
  }

  void _loadEmail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      email = prefs.getString('email') ?? '';
    });
  }

  // Verify method
  void Verify() async {
    final resetCode = codeController1.text +
        codeController2.text +
        codeController3.text +
        codeController4.text +
        codeController5.text +
        codeController6.text;
    final newPassword = passwordController.text;
    final confirmPassword = confirmPasswordController.text;

    if (newPassword != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match')),
      );
      return;
    }

    final response = await http.post(
      Uri.parse(
          'https://medrxapi.azurewebsites.net/api/Account/reset-password'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body:
          '{"email": "$email", "resetCode": "$resetCode", "newPassword": "$newPassword"}',
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password reset successful')),
      );
      // Navigate to login page
      Navigator.pushReplacementNamed(context, '/login');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to reset password: ${response.body}')),
      );
    }
  }

  @override
  void dispose() {
    // Dispose the focus nodes and text controllers to prevent memory leaks
    codeController1.dispose();
    codeController2.dispose();
    codeController3.dispose();
    codeController4.dispose();
    codeController5.dispose();
    codeController6.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    focusNode1.dispose();
    focusNode2.dispose();
    focusNode3.dispose();
    focusNode4.dispose();
    focusNode5.dispose();
    focusNode6.dispose();
    passwordFocusNode.dispose();
    confirmPasswordFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 30.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
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

                // OTP Verification
                const Text(
                  'OTP Verification',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 10),

                // Enter the verification code that we just sent to your email address
                Text(
                  'Enter the verification code that we just sent to $email',
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 25),

                // Six text fields for entering the verification code
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    buildCodeTextField(codeController1, focusNode1),
                    const SizedBox(width: 10),
                    buildCodeTextField(codeController2, focusNode2),
                    const SizedBox(width: 10),
                    buildCodeTextField(codeController3, focusNode3),
                    const SizedBox(width: 10),
                    buildCodeTextField(codeController4, focusNode4),
                    const SizedBox(width: 10),
                    buildCodeTextField(codeController5, focusNode5),
                    const SizedBox(width: 10),
                    buildCodeTextField(codeController6, focusNode6),
                  ],
                ),

                const SizedBox(height: 25),

                // New password fields
                const Text(
                  'Enter your new password',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 10),

                // Password field
                buildPasswordTextField(
                    passwordController, passwordFocusNode, 'New Password'),

                const SizedBox(height: 20),

                // Confirm password field
                buildPasswordTextField(confirmPasswordController,
                    confirmPasswordFocusNode, 'Confirm Password'),

                const SizedBox(height: 25),

                // Verify button
                MyButton(
                  onTap: Verify,
                  buttonText: 'Verify',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper method to build a single code text field
  Widget buildCodeTextField(
      TextEditingController controller, FocusNode focusNode) {
    return SizedBox(
      width: 50, // Adjust the width as needed
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        maxLength: 1, // Limit the input to a single digit
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          counterText: '', // Remove the character counter
        ),
      ),
    );
  }

  // Helper method to build a password text field
  Widget buildPasswordTextField(
      TextEditingController controller, FocusNode focusNode, String hintText) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      obscureText: true,
      decoration: InputDecoration(
        hintText: hintText,
        border: OutlineInputBorder(),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }
}
