import 'package:flutter/material.dart';

class AppBarWidget extends StatelessWidget {
  final String title;
  final VoidCallback? onMenuPressed;

  const AppBarWidget({
    required this.title,
    this.onMenuPressed,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Color.fromARGB(255, 16, 253, 44),
      elevation: 10.0,
      title: Row(
        children: [
          //Burger menu
          IconButton(
            onPressed: onMenuPressed,
            icon: Icon(
              Icons.menu,
              color: Colors.white,
            ),
          ),

          //Page title
          Text(
            title,
            style: TextStyle(
              color: Colors.white,
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      actions: [
        //Notification button
        IconButton(
          onPressed: () {
            //Handle notification logic here
          },
          icon: Icon(
            Icons.notifications,
            color: Colors.white,
          ),
        ),

        //help button
        IconButton(
          onPressed: () {
            //handle help logic here
          },
          icon: Icon(
            Icons.help_outline_rounded,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}
