import 'package:flutter/material.dart';
import 'package:medfast_go/pages/brand_intro.dart';
import 'package:medfast_go/pages/forgot_password.dart';
import 'package:medfast_go/pages/home_page.dart';
import 'package:medfast_go/pages/log_in.dart';
import 'package:medfast_go/pages/sign_up.dart';
import 'package:medfast_go/pages/splash_screen.dart';
import 'package:medfast_go/pages/successful_password.dart';
import 'package:medfast_go/pages/verification_page.dart';

void main() async {
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return  MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MedFast',
      initialRoute: '/splash',
      routes: {
        '/splash': (context) =>  const SplashScreen(),
        '/HomePage': (context) => const HomePage(),
        '/login': (context) => LoginPage(),
        '/signUp': (context) => signUpPage(),
        // '/invent': (context) => InventoryPage(),
        '/password':(context) => forgotPassword(),
        '/success':(context) => const SuccessfulPassword(),
        '/verify':(context) => const VerificationPage(),
        '/brandintro':(context) => const BrandIntroPage(),
      },
    );
  }
}