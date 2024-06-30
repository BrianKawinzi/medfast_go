import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medfast_go/controllers/authentication_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:medfast_go/pages/bottom_navigation.dart';

class NavigationDrawerWidget extends StatelessWidget {
  final padding = const EdgeInsets.symmetric(horizontal: 20);
  final AuthenticationController authenticationController = Get.find();

  NavigationDrawerWidget({Key? key}) : super(key: key);

  Future<Map<String, String>> getUserDetails() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('user_email') ?? 'No email';
    final pharmacyName = prefs.getString('pharmacy_name') ?? 'Pharmacy Name';
    return {'email': email, 'pharmacyName': pharmacyName};
  }

  Widget buildHeader(VoidCallback onClicked) {
    const urlImage =
        'https://images.unsplash.com/photo-1603706580932-6befcf7d8521?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=1287&q=80';

    return FutureBuilder<Map<String, String>>(
      future: getUserDetails(),
      builder: (context, snapshot) {
        final email = snapshot.data?['email'] ?? 'Loading...';
        final pharmacyName =
            snapshot.data?['pharmacyName'] ?? 'Loading..'; // Adjusted key
        // final pharmacyName = prefs.getString('pharmacy_name') ?? 'Pharmacy Name'; // Adjusted key
        // return {'email': email, 'pharmacyName': pharmacyName};
        return InkWell(
          onTap: onClicked,
          child: Container(
            padding: padding.add(const EdgeInsets.symmetric(vertical: 40)),
            child: Row(
              children: [
                const CircleAvatar(
                    radius: 30, backgroundImage: NetworkImage(urlImage)),
                const SizedBox(width: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pharmacyName, // Dynamic pharmacy name
                      style: const TextStyle(fontSize: 20, color: Colors.white),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      authenticationController.currentUserData.value.email,
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
      },
    );
  }

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
    return Drawer(
      child: Material(
        color: const Color.fromRGBO(58, 205, 50, 1),
        child: ListView(
          children: <Widget>[
            buildHeader(() => Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => const BottomNavigation()))),
            const SizedBox(height: 10),
            buildSearchField(),
            const SizedBox(height: 16),
            // Repeat for each item as needed
            buildMenuItem(
                text: 'Home',
                icon: Icons.home,
                onClicked: () => Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) => const BottomNavigation(),
                      ),
                    )),
            buildMenuItem(
              text: 'Profile',
              icon: Icons.person,
              onClicked: () =>
                  Navigator.of(context).popAndPushNamed('/profile'),
            ),
            // buildMenuItem(
            //   text: 'Themes',
            //   icon: Icons.color_lens,
            //   onClicked: () {
            //     Navigator.of(context).pop();
            //     Navigator.of(context)
            //         .pushNamed('/themes'); // Navigate to the Themes page
            //   },
            // ),
            // buildMenuItem(
            //   text: 'Language',
            //   icon: Icons.language,
            //   onClicked: () {
            //     Navigator.of(context).pop(); // Close the drawer
            //     Navigator.of(context)
            //         .pushNamed('/language'); // Navigate to the language page
            //   },
            // ),
            buildMenuItem(
              text: 'Support',
              icon: Icons.support,
              onClicked: () {
                Navigator.of(context).pop(); // Close the drawer
                Navigator.of(context)
                    .pushNamed('/support'); // Navigate to the support page
              },
            ),
            buildMenuItem(
              text: 'FAQ',
              icon: Icons.question_answer,
              onClicked: () {
                Navigator.of(context).pop(); // Close the drawer
                Navigator.of(context)
                    .pushNamed('/faq'); // Navigate to the faq page
              },
            ),
            const Divider(color: Colors.white70),
            // buildMenuItem(
            //   text: 'Settings',
            //   icon: Icons.settings,
            //   onClicked: () {
            //     Navigator.of(context).pop(); // Close the drawer
            //     Navigator.of(context).pushNamed(
            //         '/SettingsPage'); // Navigate to the settings page
            //   },
            // ),
            buildMenuItem(
              text: 'Log Out',
              icon: Icons.exit_to_app,
              onClicked: () async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.clear();
                await authenticationController.signOut();
                Navigator.of(context).popAndPushNamed('/login');
              },
            ),
          ],
        ),
      ),
    );
  }
}
