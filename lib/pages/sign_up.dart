import 'package:flutter/material.dart';
import 'package:medfast_go/pages/components/my_button.dart';
import 'package:medfast_go/pages/components/my_textfield.dart';
import 'package:medfast_go/pages/components/normal_tf.dart';

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
          child: SingleChildScrollView(
            child: Column(
              children: [
                //Back button
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: IconButton(
                      icon: Icon(Icons.arrow_back_ios_new_rounded),
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
                  hintText: 'Password', obscureText: true,
                ),
                const SizedBox(height: 10),

                //confirm password textfield
                MyTextField(
                  controller: confirmPasswordController,
                  hintText: 'Confirm Password', obscureText: true,
                ),
                const SizedBox(height: 20),

                //register button
                MyButton(
                  onTap: SignUserUp,
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