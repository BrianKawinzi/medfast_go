import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:medfast_go/pages/components/my_button.dart';
import 'package:medfast_go/pages/components/my_textfield.dart';
import 'package:medfast_go/pages/components/normal_tf.dart';

class SignUpPage extends StatefulWidget {
  final int? pharmacyId;

  SignUpPage({super.key, required this.pharmacyId});

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final emailController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  String errorMessage = '';
  bool showErrorMessage = false;
  bool isLoading = false;

  void SignUserUp(BuildContext context) async {
    if (passwordController.text != confirmPasswordController.text) {
      setState(() {
        errorMessage = "Password don't match";
        showErrorMessage = true;
      });
      return;
    } else {
      setState(() {
        showErrorMessage = false;
        isLoading = true;
      });
    }

    final url = Uri.parse('https://medrxapi.azurewebsites.net/api/Account/register');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': emailController.text,
        'password': passwordController.text,
        'username': usernameController.text,
        'phoneNumber': passwordController.text,
        'pharmacyId': widget.pharmacyId,
      }),
    );

    if (response.statusCode == 200) {
      Navigator.of(context).pushReplacementNamed('/login');
    } else {
      final Map<String, dynamic> responseBody = json.decode(response.body);
      String apiErrorMessage = responseBody['message'] ?? 'Password needs: 6+ characters, A-Z, a-z, 0-9, and  \nsymbols like #, @.';
      setState(() {
        errorMessage = apiErrorMessage;
        showErrorMessage = true;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back_ios_new_rounded),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 50),
                    Text(
                      'Welcome to MedFast!',
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(height: 25),
                    normalTF(
                        controller: usernameController,
                        hintText: 'Username',
                        obscureText: false),
                    const SizedBox(height: 10),
                    normalTF(
                      controller: emailController,
                      hintText: 'Email',
                      obscureText: false,
                    ),
                    const SizedBox(height: 10),
                    MyTextField(
                      controller: passwordController,
                      hintText: 'Password',
                      obscureText: true,
                    ),
                    if (showErrorMessage)
                      Text(
                        errorMessage,
                        style: TextStyle(color: Colors.red),
                      ),
                    const SizedBox(height: 10),
                    MyTextField(
                      controller: confirmPasswordController,
                      hintText: 'Confirm Password',
                      obscureText: true,
                    ),
                    const SizedBox(height: 20),
                    MyButton(
                      onTap: () => SignUserUp(context),
                      buttonText: "Agree and Register",
                    ),
                  ],
                ),
              ),
            ),
            if (isLoading)
              Container(
                color: Colors.black45,
                child: Center(child: CircularProgressIndicator()),
              ),
          ],
        ),
      ),
    );
  }
}
