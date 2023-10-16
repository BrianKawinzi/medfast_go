import 'dart:async';

import 'package:flutter/material.dart';

class BrandIntroPage extends StatefulWidget {
  const BrandIntroPage({super.key});

  @override
  _BrandIntroPageState createState() => _BrandIntroPageState();
}

class _BrandIntroPageState extends State<BrandIntroPage> {
  List<Map<String, dynamic>> slides = [
    {
      'title': 'Solutions for your pharmacy',
      'description': 'Run and manage your pharmacy from your phone',
      'image': 'lib/assets/medicine.png',
    },
    {
      'title': 'Fast Delivery',
      'description': 'Get your medicines right at your doorstep',
      'image': 'lib/assets/medicine.png',
    },
    {
      'title': 'Wide Range',
      'description': 'Choose from a variety of medical products',
      'image': 'lib/assets/medicine.png',
    },
  ];

  late Timer timer;
  int currentIndex = 0;
  PageController pageController = PageController(initialPage: 0);

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  void startTimer() {
    timer = Timer.periodic(const Duration(seconds: 5), (Timer t) {
      if (currentIndex < slides.length - 1) {
        currentIndex++;
      } else {
        currentIndex = 0;
      }

      pageController.animateToPage(
        currentIndex,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeIn,
      );
    });
  }

  void stopTimer() {
    if (timer.isActive) {
      timer.cancel();
    }
  }

  @override
  void dispose() {
    stopTimer();
    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: const Text('MedFastGo'),
        backgroundColor: Colors.green,
      ),
      body: Column(
        children: [
          SizedBox(
            height: screenHeight * 0.5,
            child: PageView.builder(
              controller: pageController,
              itemCount: slides.length,
              onPageChanged: (val) {
                setState(() {
                  currentIndex = val;
                });
              },
              itemBuilder: (context, index) {
                return GestureDetector(
                  onPanUpdate: (details) {
                    stopTimer();
                  },
                  onPanEnd: (details) {
                    startTimer();
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        slides[index]['image'],
                        fit: BoxFit.cover,
                        height: screenHeight * 0.38,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        slides[index]['title'],
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Color.fromRGBO(44, 44, 44, 1),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        slides[index]['description'],
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Color.fromRGBO(44, 44, 44, 1),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(slides.length, (index) {
              return Container(
                margin: const EdgeInsets.all(4.0),
                width: currentIndex == index ? 12.0 : 8.0,
                height: currentIndex == index ? 12.0 : 8.0,
                decoration: BoxDecoration(
                  color: currentIndex == index ? Colors.green : Colors.grey,
                  shape: BoxShape.circle,
                ),
              );
            }),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, '/signUp');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
            ),
            child: const Text('Sign Up'),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, '/login');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
            ),
            child: const Text('Already Have an Account'),
          ),
        ],
      ),
    );
  }
}