import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:medfast_go/pages/components/my_button.dart';
import 'package:medfast_go/pages/components/my_textfield.dart';
import 'package:medfast_go/pages/components/normal_tf.dart';

class signUpPage extends StatelessWidget {
  signUpPage({super.key,  required this.pharmacyId});
 final int? pharmacyId;
  //controllers
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final emailController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  //sign upmethod
  void SignUserUp(BuildContext context) async {
    final url =
        Uri.parse('https://medrxapi.azurewebsites.net/api/Account/register');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'email': emailController.text,
        'password': passwordController.text,
        'username': usernameController.text,
        'phoneNumber': '0700394809',
        'pharmacyId': 5,
      }),
    );

    if (response.statusCode == 200) {

      print('User registered successfully'); // Fixed typo here
      Navigator.of(context).pushReplacementNamed('/login');
    } else {
      print('Failed to register user. Status code: ${response.statusCode}');
      print('Response body: ${response.body}');
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
              children: [
                //Back button
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded),
                      onPressed: () {
                        //Navigate back to the previous screen
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 50),

                //Welcome to medfast
                Text(
                  'Welcome to MedFast!',
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 20,
                  ),
                ),

                const SizedBox(height: 25),

                //username textfield
                normalTF(
                    controller: usernameController,
                    hintText: 'Username',
                    obscureText: false),
                const SizedBox(height: 10),

                //email textfield
                normalTF(
                  controller: emailController,
                  hintText: 'Email',
                  obscureText: false,
                ),
                const SizedBox(height: 10),

                //password textfield
                MyTextField(
                  controller: passwordController,
                  hintText: 'Password',
                  obscureText: true,
                ),
                const SizedBox(height: 10),

                //confirm password textfield
                MyTextField(
                  controller: confirmPasswordController,
                  hintText: 'Confirm Password',
                  obscureText: true,
                ),
                const SizedBox(height: 20),

                //register button
                MyButton(
                  onTap: () => SignUserUp(context),
                  buttonText: "Agree and Register",
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
