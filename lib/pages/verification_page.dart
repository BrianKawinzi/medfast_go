import 'package:flutter/material.dart';
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

  // Create focus nodes for each text field
  final FocusNode focusNode1 = FocusNode();
  final FocusNode focusNode2 = FocusNode();
  final FocusNode focusNode3 = FocusNode();
  final FocusNode focusNode4 = FocusNode();

  @override
  void initState() {
    super.initState();

    // Add listeners to detect changes in text
    codeController1.addListener(() {
      if (codeController1.text.isEmpty) {
        // Move to the next text field when deleting
        FocusScope.of(context).requestFocus(focusNode1);
      } else if (codeController1.text.length == 1) {
        // Move to the next text field when a character is entered
        FocusScope.of(context).requestFocus(focusNode2);
      }
    });

    codeController2.addListener(() {
      if (codeController2.text.isEmpty) {
        // Move to the previous text field when deleting
        FocusScope.of(context).requestFocus(focusNode1);
      } else if (codeController2.text.length == 1) {
        // Move to the next text field when a character is entered
        FocusScope.of(context).requestFocus(focusNode3);
      }
    });

    codeController3.addListener(() {
      if (codeController3.text.isEmpty) {
        // Move to the previous text field when deleting
        FocusScope.of(context).requestFocus(focusNode2);
      } else if (codeController3.text.length == 1) {
        // Move to the next text field when a character is entered
        FocusScope.of(context).requestFocus(focusNode4);
      }
    });

    codeController4.addListener(() {
      if (codeController4.text.isEmpty) {
        // Move to the previous text field when deleting
        FocusScope.of(context).requestFocus(focusNode3);
      }
    });
  }

  // Verify method
  void Verify() {
    // Add your verification logic here
  }

  @override
  void dispose() {
    // Dispose the focus nodes and text controllers to prevent memory leaks
    codeController1.dispose();
    codeController2.dispose();
    codeController3.dispose();
    codeController4.dispose();
    focusNode1.dispose();
    focusNode2.dispose();
    focusNode3.dispose();
    focusNode4.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
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
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 10),

                // Enter the verification code that we just sent to your email address
                Text(
                  'Enter the verification code that we just sent to your email address',
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 25),

                // Four text fields for entering the verification code
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
                  ],
                ),

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
  Widget buildCodeTextField(TextEditingController controller, FocusNode focusNode) {
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
}