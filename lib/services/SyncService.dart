import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:medfast_go/constants/firebase_collections.dart';
import 'package:medfast_go/data/DatabaseHelper.dart';
import 'package:medfast_go/models/product.dart';
import 'package:medfast_go/services/network_provider.dart';

class SyncService {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final NetworkController networkController = Get.put(NetworkController());

  Future<void> syncData() async {
    if (networkController.connectionStatus.value != 0) {
      List<Product> localData = await _dbHelper.getProducts();

      for (var product in localData) {
        await _firestore
            .collection(Collections.PRODUCTS)
            .doc(product.id.toString())
            .set(product.toMap());
        await _dbHelper.deleteProduct(product.id);
      }

      QuerySnapshot remoteData = await _firestore.collection('products').get();
      for (var doc in remoteData.docs) {
        Product product = Product.fromMap(doc as Map<String, dynamic>);
        await _dbHelper.insertProduct(product);
      }
    }
  }
}
