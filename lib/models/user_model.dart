import 'package:cloud_firestore/cloud_firestore.dart';

class Users {
  final String uid;

  Users(
    this.uid,
  );
}

class Userz {
  final String managerUid;
  final String uid;
  final String email;
  final String displayName;
  final bool isAdmin;
  final String phymacyId;
  final String fcmToken;

  Userz({
    required this.managerUid,
    required this.uid,
    required this.email,
    required this.displayName,
    required this.isAdmin,
    required this.phymacyId,
    required this.fcmToken,
  });

  // Convert user object to map
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'name': displayName,
      'isAdmin': isAdmin,
      'phymacy_id': phymacyId,
      'fcm_Token': fcmToken,
      'manager_uid': managerUid,
    };
  }

  factory Userz.fromSnapShot(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    Map? data = snapshot.data();
    return Userz(
      uid: data!['uid'],
      email: data['email'],
      displayName: data['name'],
      isAdmin: data['isAdmin'],
      fcmToken: data['fcm_Token'],
      phymacyId: data['phymacy_id'],
      managerUid: data['manager_uid'],
    );
  }
}

class Clients {
  final String managerUid;
  final String uid;
  final String email;
  final String displayName;
  final bool isAdmin;
  final int shopId;
  final String fcmToken;

  Clients({
    required this.managerUid,
    required this.uid,
    required this.email,
    required this.displayName,
    required this.isAdmin,
    required this.shopId,
    required this.fcmToken,
  });

  // Convert user object to map
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'name': displayName,
      'isAdmin': isAdmin,
      'shop_id': shopId,
      'fcm_Token': fcmToken,
      'manager_uid': managerUid,
    };
  }

  factory Clients.fromSnapShot(
      DocumentSnapshot<Map<String, dynamic>> snapshot) {
    Map? data = snapshot.data();
    return Clients(
      uid: data!['uid'],
      email: data['email'],
      displayName: data['name'],
      isAdmin: data['isAdmin'],
      fcmToken: data['fcm_Token'],
      shopId: data['shop_id'],
      managerUid: data['manager_uid'],
    );
  }
}
