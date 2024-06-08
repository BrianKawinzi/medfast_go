import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Delay the execution to ensure the build method completes.
    Future.delayed(const Duration(seconds: 1), () {
      navigateBasedOnTokenValidity();
    });
  }

  void navigateBasedOnTokenValidity() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    String routeName = '/brandintro'; // Assume '/login' is your login route
    if (token != null) {
      final payload = decodeJwtPayload(token);
      final exp = payload['exp'];
      if (exp != null) {
        final expiryDate = DateTime.fromMillisecondsSinceEpoch(exp * 1000);
        if (DateTime.now().isBefore(expiryDate)) {
          routeName =
              '/bottom'; // Navigate to the home screen if the token is valid
        }
      }
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Navigator.of(context).pushReplacementNamed(routeName);
      }
    });
  }

  Map<String, dynamic> decodeJwtPayload(String token) {
    final parts = token.split('.');
    if (parts.length != 3) {
      throw Exception('Invalid token');
    }
    final payload = parts[1];
    final normalized = base64Url.normalize(payload);
    final resp = utf8.decode(base64Url.decode(normalized));
    return json.decode(resp);
  }

  @override
  Widget build(BuildContext context) {
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pushReplacementNamed(context, '/brandintro');
    });
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 238, 240, 238),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'lib/assets/Flashsplash1.png', // Ensure this path is correct for your project.
            ),
            const SizedBox(height: 20),
            const Text(
              '',
              style: TextStyle(fontSize: 18, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
