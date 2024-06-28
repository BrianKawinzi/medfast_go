import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:medfast_go/pages/brand_intro.dart'; // Import the BrandIntroPage
import 'package:medfast_go/pages/home_page.dart';

class LogOutPage extends StatefulWidget {
  const LogOutPage({Key? key}) : super(key: key);

  @override
  LogOutPageState createState() => LogOutPageState();
}

class LogOutPageState extends State<LogOutPage> {
  @override
  void initState() {
    super.initState();
    logoutUser();
  }

  Future<void> logoutUser() async {
    // Here you can add your logout logic
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('pharmacyId'); // Remove the specific pharmacy ID
    await prefs.remove('pharmacyName'); // Remove the specific pharmacy name
    await prefs.remove('county'); // Remove the specific county
    await prefs.remove('phone'); // Remove the specific phone number
    await prefs.remove('profilePicture'); // Remove the profile picture

    // After performing the necessary logout operations, navigate to the BrandIntroPage
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const BrandIntroPage()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Log Out'),
          centerTitle: true,
          backgroundColor: const Color.fromRGBO(58, 205, 50, 1),
          leading: GestureDetector(
            onTap: () {
              Navigator.of(context).pushReplacement(MaterialPageRoute(
                builder: (context) => const HomePage(),
              ));
            },
            child: const Icon(Icons.arrow_back),
          ),
        ),
        body: Center(
          child:
              CircularProgressIndicator(), // Show a loading indicator while logging out
        ),
      );
}