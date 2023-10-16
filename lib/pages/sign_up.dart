import 'package:flutter/material.dart';
import 'package:medfast_go/pages/components/my_button.dart';
import 'package:medfast_go/pages/components/my_textfield.dart';



class signUpPage extends StatelessWidget {
  signUpPage({super.key});

  //controllers
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final emailController = TextEditingController();
  final confirmPasswordController = TextEditingController();


  //sign upmethod
  void SignUserUp() {}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: Center(
          child: Column(
            children: [
              const SizedBox(height: 50),
              //logo
              const Icon(
                Icons.lock,
                size: 100,
              ),

              const SizedBox(height: 50),


              //Welcome to medfast
              Text(
                'Welcome to MedFast!',
                style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: 16,
                ),
              ),

              const SizedBox(height: 25),

              //username textfield
              MyTextField(
                controller: usernameController, 
                hintText: 'Username', 
                obscureText: false,
              ),
              const SizedBox(height: 10),

              //email textfield
              MyTextField(
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
              const SizedBox(height: 10),

              //register button
              MyButton(
                onTap: SignUserUp,
                buttonText: "Sign Up",
              ),

            ],
            ),
            ),
      ),
    );
  }
}