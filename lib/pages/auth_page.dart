import 'package:flutter/material.dart';
import 'package:medfast_go/pages/bottom_navigation.dart';
import 'package:medfast_go/pages/brand_intro.dart';
import 'package:medfast_go/pages/log_in.dart';
import 'package:medfast_go/pages/splash_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';


class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  Future<bool> isLoggedIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    //check if user is logged in based on a stored token
    if (prefs.containsKey('userToken')) {
      //returning user
      return true;
    } else {
      //new user 
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: isLoggedIn(),
      builder: (context, snapshot) {
        if(snapshot.connectionState == ConnectionState.waiting) {
          return const SplashScreen();
        } else if (snapshot.data == true) {
          return const BottomNavigation();
        } else if(snapshot.data == false) {

          return const BrandIntroPage();
        }
        else {
          return LoginPage();
        }
      },
    );
      

  }
}