import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:medfast_go/constants/firebase_collections.dart';
import 'package:medfast_go/models/pharmacy.dart';
import 'package:medfast_go/models/user_model.dart';
import 'package:medfast_go/pages/bottom_navigation.dart';
import 'package:medfast_go/pages/log_in.dart';
import 'package:medfast_go/pages/sign_up.dart';
import 'package:medfast_go/pages/splash_screen.dart';
import 'package:medfast_go/utills/common.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthenticationController extends GetxController {
  RxBool loading = false.obs;
  static FirebaseAuth auth = FirebaseAuth.instance;
  static final FirebaseFirestore db = FirebaseFirestore.instance;
  late CollectionReference usersRef;
  late Rx<User?> firebaseUser;
  RxBool isSigningWithGoogle = false.obs;
  final Future<SharedPreferences> sharedPreferences =
      SharedPreferences.getInstance();
  RxBool creatingUser = false.obs;
  TextEditingController userName = TextEditingController();
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  RxString pharmacyId = ''.obs;

  Rx<Userz> currentUserData = Userz(
          uid: '',
          email: '',
          displayName: '',
          isAdmin: false,
          phymacyId: '',
          fcmToken: '',
          managerUid: '')
      .obs;

  @override
  void onInit() {
    super.onInit();
    firebaseUser = Rx<User?>(auth.currentUser);
    firebaseUser.bindStream(auth.userChanges());
    usersRef = FirebaseFirestore.instance.collection(Collections.USERS);
    ever(firebaseUser, _setInitialScreen);
    ever(firebaseUser, getCurrentUserData);
  }

  getNameByUid(String uid) async {
    CollectionReference users = FirebaseFirestore.instance.collection('users');
    QuerySnapshot querySnapshot =
        await users.where('uid', isEqualTo: uid).get();
    if (querySnapshot.docs.isNotEmpty) {
      return querySnapshot.docs.first['name'];
    } else {
      return null;
    }
  }

  _setInitialScreen(User? user) async {
    if (user == null) {
      Get.to(const LoginPage());
    } else {
      DocumentSnapshot userSnapshot = await usersRef.doc(user.uid).get();
      if (userSnapshot.exists) {
        Get.to(const BottomNavigation());
      } else {
        Get.to(const SplashScreen());
      }
    }
  }

  getCurrentUserData(User? user) async {
    if (user != null) {
      StreamSubscription<DocumentSnapshot<Map<String, dynamic>>> snapshot =
          singleProfileStream(userId: user.uid).listen((snapshot) {
        currentUserData.value = Userz.fromSnapShot(snapshot);
      });
    }
  }

  Future<void> signOut() async {
    await auth.signOut();
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> singleProfileStream(
      {required String userId}) {
    return db.collection(Collections.USERS).doc(userId).snapshots();
  }

  Future<void> registerPharmacy(BuildContext context, Pharmacy pharmacy) async {
    try {
      DocumentReference docRef = await firestore.collection('pharmacies').add({
        'pharmacyName': pharmacy.pharmacyName,
        'county': pharmacy.county,
        'phoneNumber': pharmacy.phoneNumber,
        'latitude': pharmacy.latitude,
        'longitude': pharmacy.longitude,
      });
      pharmacyId.value = docRef.id;
      update();
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SignUpPage(
            pharmacyId: pharmacyId.value,
          ),
        ),
      );
      print("::::::::::${pharmacyId.value}");
    } catch (e) {
      print('Error registering pharmacy: $e');
      rethrow;
    }
  }

  Future<void> registerWithEmailAndPassword({
    required BuildContext context,
    required String userName,
    required String email,
    required String password,
    required String phamacyId,
  }) async {
    creatingUser.value = true;
    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      creatingUser.value = false;

      DocumentSnapshot userSnapshot =
          await usersRef.doc(userCredential.user!.uid).get();
      if (userSnapshot.exists) {
        print("User exists::${userCredential.user!.uid}");
        Navigator.of(context).pushReplacementNamed('/login');
      } else {
        print("user does not exixt::::${userCredential.user!.uid}");
        return await storeUserInFirestore(
          user: userCredential.user!,
          phymacyId: phamacyId,
          userName: userName,
        );
      }
      Navigator.of(context).pushReplacementNamed('/login');
    } on FirebaseAuthException catch (e) {
      creatingUser.value = false;

      if (e.code == 'weak-password') {
        creatingUser.value = false;
        CommonUtils.showToast('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        creatingUser.value = false;
        CommonUtils.showToast('The account already exists for that email.');
      } else {
        creatingUser.value = false;
        CommonUtils.showToast('Error: ${e.message}');
      }
    } catch (e) {
      creatingUser.value = false;

      print('Error: $e');
    }
  }

  Future<void> loginInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    loading.value = true;
    try {
      final UserCredential userCredential = await auth
          .signInWithEmailAndPassword(email: email, password: password);

      if (userCredential.user != null) {
        String? fcmToken = await FirebaseMessaging.instance.getToken();

        if (fcmToken != null) {
          await usersRef.doc(userCredential.user!.uid).update({
            'fcm_Token': fcmToken,
          });
        }

        DocumentSnapshot userSnapshot =
            await usersRef.doc(userCredential.user!.uid).get();
        loading.value = false;
        update();
        if (userSnapshot.exists) {
          Navigator.of(Get.context!).pushReplacementNamed('/bottom');

          // CommonUtils.showToast('You do not have a account register first');
        } else {}
      } else if (userCredential.user != null &&
          !userCredential.user!.emailVerified) {
        loading.value = false;
        update();
        Get.snackbar(
            "Email Verification", "Please you need to verify your email",
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white);
      }
    } on FirebaseAuthException catch (e) {
      loading.value = false;
      update();
      Get.snackbar("Error !", e.code,
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red);
    } catch (e) {
      loading.value = false;
      print(e.toString());
      debugPrint(e.toString());
    }
  }

  Future signInWithGoogle() async {
    isSigningWithGoogle.value = true;
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    final GoogleSignInAuthentication? googleAuth =
        await googleUser?.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    isSigningWithGoogle.value = false;
    update();
    FirebaseAuth.instance
        .signInWithCredential(credential)
        .then((UserCredential userCredential) async {
      DocumentSnapshot userSnapshot =
          await usersRef.doc(userCredential.user!.uid).get();
      if (userSnapshot.exists) {
        print("User exists::${userCredential.user!.uid}");
      } else {
        print("user does not exixt::::${userCredential.user!.uid}");
        return await storeUserInFirestore(
          user: userCredential.user!,
          phymacyId: '',
          userName: userCredential.user!.displayName!,
        );
      }
    }).catchError((error) {});
  }

  Future<void> storeUserInFirestore(
      {required User user,
      required String phymacyId,
      required String userName}) async {
    try {
      CollectionReference usersRef =
          FirebaseFirestore.instance.collection(Collections.USERS);
      DocumentSnapshot userSnapshot = await usersRef.doc(user.uid).get();
      String? fcmToken = await FirebaseMessaging.instance.getToken();

      if (!userSnapshot.exists) {
        await usersRef.doc(user.uid).set(Userz(
              uid: user.uid,
              email: user.email!,
              displayName: userName,
              isAdmin: true,
              phymacyId: phymacyId.toString(),
              fcmToken: fcmToken!,
              managerUid: '',
            ).toMap());
        CommonUtils.showToast('User data stored in Firestore successfully.');
      } else {
        // User already exists in Firestore
        CommonUtils.showToast('User already exists in Firestore.');
      }
    } catch (error) {
      print('Error storing user data in Firestore: $error');
    }
  }

  // Future<void> createWorker(User user) async {
  //   try {
  //     CollectionReference usersRef =
  //         FirebaseFirestore.instance.collection('users');
  //     DocumentSnapshot userSnapshot = await usersRef.doc(user.uid).get();
  //     String? fcmToken = await FirebaseMessaging.instance.getToken();

  //     if (!userSnapshot.exists) {
  //       await usersRef.doc(user.uid).set(Userz(
  //             uid: user.uid,
  //             email: user.email!,
  //             displayName: userName.text,
  //             isAdmin: false,
  //             shopId: currentUserData.value.shopId,
  //             fcmToken: '',
  //             managerUid: currentUserData.value.uid,
  //           ).toMap());
  //       CommonUtils.showToast('User data stored in Firestore successfully.');
  //     } else {
  //       CommonUtils.showToast('User already exists in Firestore.');
  //     }
  //   } catch (error) {
  //     print('Error storing user data in Firestore: $error');
  //   }
  // }
}
