// ignore_for_file: override_on_non_overriding_member

import 'package:flutter/material.dart';
import 'package:medfast_go/pages/faq.dart';
import 'package:medfast_go/pages/home_page.dart';
import 'package:medfast_go/pages/home_screen.dart';
import 'package:medfast_go/pages/language.dart';
import 'package:medfast_go/pages/log_out.dart';
import 'package:medfast_go/pages/profile.dart';
import 'package:medfast_go/pages/settings_page.dart';
import 'package:medfast_go/pages/support.dart';
import 'package:medfast_go/pages/themes.dart';

class NavigationDrawerWidget extends StatelessWidget {
  final padding = const EdgeInsets.symmetric(horizontal: 20);

  const NavigationDrawerWidget({super.key});
  @override
  Widget buildHeader({
    required String urlImage,
    required String name,
    required String email,
    required VoidCallback onClicked,
  }) =>
      InkWell(
        onTap: onClicked,
        child: Container(
          padding: padding.add(const EdgeInsets.symmetric(vertical: 40)),
          child: Row(
            children: [
              CircleAvatar(radius: 30, backgroundImage: NetworkImage(urlImage)),
              const SizedBox(width: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(fontSize: 20, color: Colors.white),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    email,
                    style: const TextStyle(fontSize: 14, color: Colors.white),
                  ),
                ],
              ),
              const Spacer(),
              const CircleAvatar(
                radius: 24,
                backgroundColor: Color.fromRGBO(30, 60, 168, 1),
                child: Icon(Icons.add_comment_outlined, color: Colors.white),
              )
            ],
          ),
        ),
      );

  Widget buildSearchField() {
    const color = Colors.white;

    return TextField(
      style: const TextStyle(color: color),
      decoration: InputDecoration(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        hintText: 'Search',
        hintStyle: const TextStyle(color: color),
        prefixIcon: const Icon(Icons.search, color: color),
        filled: true,
        fillColor: Colors.white12,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5),
          borderSide: BorderSide(color: color.withOpacity(0.7)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5),
          borderSide: BorderSide(color: color.withOpacity(0.7)),
        ),
      ),
    );
  }

  Widget buildMenuItem({
    required String text,
    required IconData icon,
    VoidCallback? onClicked,
  }) {
    const color = Colors.white;
    const hoverColor = Colors.white70;

    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(text, style: const TextStyle(color: color)),
      hoverColor: hoverColor,
      onTap: onClicked,
    );
  }

  @override
  Widget build(BuildContext context) {
    const name = 'Tala Chemist';
    const email = 'talachemist@gmail.com';
    const urlImage =
        'https://images.unsplash.com/photo-1603706580932-6befcf7d8521?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1287&q=80';

    return Drawer(
      child: Material(
        color: const Color.fromRGBO(58, 205, 50, 1),
        child: ListView(
          children: <Widget>[
            buildHeader(
              urlImage: urlImage,
              name: name,
              email: email,
              onClicked: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => const PharmacyProfile(),
              )),
            ),
            Container(
              padding: padding,
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  buildSearchField(),
                  const SizedBox(height: 16),
                  buildMenuItem(
                    text: 'Home',
                    icon: Icons.home,
                    onClicked: () {
                      Navigator.of(context).pop(); // Close the drawer
                      Navigator.of(context).pushReplacement(MaterialPageRoute(
                        builder: (context) =>
                            const HomeScreen(), // Navigate to the HomePage
                      ));
                    },
                  ),
                  buildMenuItem(
                    text: 'Profile',
                    icon: Icons.person_2,
                    onClicked: () {
                      Navigator.of(context).pop(); // Close the drawer
                      Navigator.of(context).pushReplacement(MaterialPageRoute(
                        builder: (context) => const PharmacyProfile(),
                      ));
                    },
                  ),
                  const SizedBox(height: 10),
                  buildMenuItem(
                    text: 'Themes',
                    icon: Icons.color_lens_outlined,
                    onClicked: () {
                      Navigator.of(context).pop(); // Close the drawer
                      Navigator.of(context).pushReplacement(MaterialPageRoute(
                        builder: (context) =>
                            const Themes(), // Navigate to the HomePage
                      ));
                    },
                  ),
                  const SizedBox(height: 10),
                  buildMenuItem(
                    text: 'Language',
                    icon: Icons.language,
                    onClicked: () {
                      Navigator.of(context).pop(); // Close the drawer
                      Navigator.of(context).pushReplacement(MaterialPageRoute(
                        builder: (context) =>
                            const Language(), // Navigate to the HomePage
                      ));
                    },
                  ),
                  const SizedBox(height: 10),
                  buildMenuItem(
                    text: 'Support',
                    icon: Icons.support_agent_rounded,
                    onClicked: () {
                      Navigator.of(context).pop(); // Close the drawer
                      Navigator.of(context).pushReplacement(MaterialPageRoute(
                        builder: (context) =>
                            
                             Support(),
                      ));
                    },
                  ),
                  const SizedBox(height: 10),
                  buildMenuItem(
                    text: 'FAQ',
                    icon: Icons.question_answer_outlined,
                    onClicked: () {
                      Navigator.of(context).pop(); // Close the drawer
                      Navigator.of(context).pushReplacement(MaterialPageRoute(
                        builder: (context) =>
                            const FAQ(), // Navigate to the HomePage
                      ));
                    },
                  ),
                  const SizedBox(height: 10),
                  const Divider(color: Colors.white70),
                  const SizedBox(height: 10),
                  buildMenuItem(
                    text: 'Settings',
                    icon: Icons.settings,
                    onClicked: () {
                      Navigator.of(context).pop(); // Close the drawer
                      Navigator.of(context).pushReplacement(MaterialPageRoute(
                        builder: (context) =>
                            const SettingsPage(), // Navigate to the HomePage
                      ));
                    },
                  ),
                  const SizedBox(height: 10),
                  buildMenuItem(
                    text: 'Log Out',
                    icon: Icons.logout,
                    onClicked: () {
                      Navigator.of(context).pop(); // Close the drawer
                      Navigator.of(context).pushReplacement(MaterialPageRoute(
                        builder: (context) =>
                            const LogOutPage(), // Navigate to the HomePage
                      ));
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}