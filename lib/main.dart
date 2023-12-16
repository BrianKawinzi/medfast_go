import 'package:flutter/material.dart';
import 'package:medfast_go/business/addproductwithoutbarcode.dart';
import 'package:medfast_go/business/editproductpage.dart';
import 'package:medfast_go/business/products.dart';
import 'package:medfast_go/models/product.dart';
import 'package:medfast_go/pages/brand_intro.dart';
import 'package:medfast_go/pages/forgot_password.dart';
import 'package:medfast_go/pages/home_page.dart';
import 'package:medfast_go/pages/log_in.dart';
import 'package:medfast_go/pages/sign_up.dart';
import 'package:medfast_go/pages/splash_screen.dart';
import 'package:medfast_go/pages/successful_password.dart';
import 'package:medfast_go/pages/verification_page.dart';
import 'package:medfast_go/security/register_pharmacy.dart';
import 'package:medfast_go/pages/profile.dart';

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
        '/signUp': (context) {
          final Map<String, dynamic> args =
              ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
          final int? pharmacyId = args['pharmacyId'] as int?;
          return signUpPage(pharmacyId: pharmacyId);
        },
        // '/invent': (context) => InventoryPage(),
        '/password':(context) => forgotPassword(),
        '/success':(context) => const SuccessfulPassword(),
        '/verify':(context) => const VerificationPage(),
        '/brandintro':(context) => const BrandIntroPage(),
        '/registerpharmacy':(context) =>  RegisterPharmacyScreen(),
        '/profile':(context) => const PharmacyProfile(),
        '/productwithoutbarcode':(context) =>  AddProductForm(),
        '/product':(context) =>  Products(),
        '/editProduct': (context) {
    final Product product = ModalRoute.of(context)!.settings.arguments as Product;
    return EditProductPage(product: product);
  },
        
        
      },
    );
  }
}