import 'package:flutter/material.dart';
import 'package:medfast_go/pages/home_page.dart';
import 'package:medfast_go/pages/brand_intro.dart'; // Import the BrandIntroPage

class LogOutPage extends StatefulWidget {
  const LogOutPage({Key? key}) : super(key: key);

  @override
  LogOutPageState createState() => LogOutPageState();
}

class LogOutPageState extends State<LogOutPage> {
  @override
  void initState() {
    super.initState();
    // Navigate to the BrandIntroPage when the LogOutPage is opened
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const BrandIntroPage(),
        ),
      );
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
        // Additional UI components for the LogOutPage if needed
      );
}
