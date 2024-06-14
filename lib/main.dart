import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:medfast_go/business/products/addproductwithoutbarcode.dart';
import 'package:medfast_go/business/editproductpage.dart';
import 'package:medfast_go/business/products/products.dart';
import 'package:medfast_go/business/sales.dart';
import 'package:medfast_go/models/product.dart';
import 'package:medfast_go/pages/auth_page.dart';
import 'package:medfast_go/pages/bottom_navigation.dart';
import 'package:medfast_go/pages/brand_intro.dart';
import 'package:medfast_go/pages/forgot_password.dart';
import 'package:medfast_go/pages/home_page.dart';
import 'package:medfast_go/pages/home_screen.dart';
import 'package:medfast_go/pages/log_in.dart';
import 'package:medfast_go/pages/sign_up.dart';
import 'package:medfast_go/pages/splash_screen.dart';
import 'package:medfast_go/pages/successful_password.dart';
import 'package:medfast_go/pages/verification_page.dart';
import 'package:medfast_go/security/register_pharmacy.dart';
import 'package:medfast_go/pages/profile.dart';
import 'package:mpesa_flutter_plugin/mpesa_flutter_plugin.dart';
import 'package:provider/provider.dart';
import 'package:medfast_go/pages/themes.dart';
import 'package:medfast_go/pages/language.dart';
import 'package:medfast_go/pages/support.dart';
import 'package:medfast_go/pages/faq.dart';
import 'package:medfast_go/pages/settings_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize M-Pesa consumer key and secret
  try {
    await Firebase.initializeApp();
    await MpesaFlutterPlugin.setConsumerKey(
        "s2u9AHfIk9WBTuf3vLZFw0nmQp3pdJAnSc8AsGtWEC6ywOny");
    await MpesaFlutterPlugin.setConsumerSecret(
        "Z8piKGAEZ27k1lnoisJ4683J6JbXGXerCTxcSkD5wfduc3zxLP35VQtn6TZk2wHA");
    print("M-Pesa consumer key and secret set successfully");
  } catch (e) {
    print("Error setting M-Pesa consumer key and secret: $e");
  }

  runApp(
    ChangeNotifierProvider(
      create: (context) => CartProvider(),
      child: const MyApp(),
    ),
  );
}

// Future<String> getInitialRoute() async {
//   DatabaseHelper dbHelper = DatabaseHelper(); // Initialize your database helper
//   String? lastRoute = await dbHelper.getLastRoute();
//   return lastRoute ?? '/splash'; // Default to '/splash' if null
// }

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MedFast',
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/bottom': (context) => const BottomNavigation(),

        '/HomePage': (context) => const HomePage(),
        '/login': (context) => const LoginPage(),
        '/home': (context) => const HomeScreen(
              completedOrders: [],
            ),
        '/auth': (context) => const AuthPage(),
        '/signUp': (context) {
          final Map<String, dynamic> args = ModalRoute.of(context)!
              .settings
              .arguments as Map<String, dynamic>;
          final int? pharmacyId = args['pharmacyId'];
          return SignUpPage(
              pharmacyId: pharmacyId
                  .toString()); // Make sure this matches the class and constructor
        },

        '/password': (context) => ForgotPassword(),
        '/success': (context) => const SuccessfulPassword(),
        '/verify': (context) => const VerificationPage(),
        '/brandintro': (context) => const BrandIntroPage(),
        '/registerpharmacy': (context) =>
            const RegisterPharmacyScreen(), // Ensure RegisterPharmacyScreen is correctly named
        '/profile': (context) =>
            const PharmacyProfile(), // Ensure PharmacyProfile is correctly named
        '/productwithoutbarcode': (context) =>
            const AddProductForm(), // Ensure AddProductWithoutBarcode is correctly named
        '/product': (context) => const Products(productName: ''),
        '/editProduct': (context) {
          final Product product =
              ModalRoute.of(context)!.settings.arguments as Product;
          return EditProductPage(product: product);
        },
        '/themes': (context) => const Themes(),
        '/language': (context) => const Language(),
        '/support': (context) => const Support(),
        '/faq': (context) => const FAQ(),
        '/verify': (context) => const VerificationPage(),
        '/SettingsPage': (context) => const SettingsPage(),
      },
    );
  }
}
