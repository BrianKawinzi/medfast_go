import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:medfast_go/constants/firebase_collections.dart';
import 'package:medfast_go/data/DatabaseHelper.dart';
import 'package:medfast_go/models/product.dart';
import 'package:medfast_go/services/network_provider.dart';
import 'package:sqflite/sqflite.dart';

class SyncService {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final NetworkController networkController = Get.put(NetworkController());

  Future<void> syncData() async {
    if (networkController.connectionStatus.value != 0) {
      // Fetch local data
      List<Product> localData = await _dbHelper.getProducts();
      Map<int, Product> localDataMap = {
        for (var product in localData) product.id: product
      };

      // Fetch remote data
      QuerySnapshot remoteDataSnapshot =
          await _firestore.collection(Collections.PRODUCTS).get();
      List<Product> remoteData = remoteDataSnapshot.docs
          .map((doc) => Product.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
      Map<int, Product> remoteDataMap = {
        for (var product in remoteData) product.id: product
      };

      // Prepare batch for Firestore
      WriteBatch firestoreBatch = _firestore.batch();

      // Prepare batch for SQLite
      final db = await _dbHelper.database;
      Batch sqliteBatch = db!.batch();

      // Compare local and remote data using last_modified
      for (var localProduct in localData) {
        Product? remoteProduct = remoteDataMap[localProduct.id];

        if (remoteProduct != null) {
          if (DateTime.parse(localProduct.lastModified!)
              .isAfter(DateTime.parse(remoteProduct.lastModified!))) {
            // Update Firestore if local is newer
            firestoreBatch.update(
                _firestore
                    .collection(Collections.PRODUCTS)
                    .doc(localProduct.id.toString()),
                localProduct.toMap());
          } else if (DateTime.parse(localProduct.lastModified!)
              .isBefore(DateTime.parse(remoteProduct.lastModified!))) {
            // Update SQLite if remote is newer
            sqliteBatch.update(
              'products',
              remoteProduct.toMap(),
              where: 'id = ?',
              whereArgs: [remoteProduct.id],
            );
          }
        } else {
          // If the product exists only in local, add it to Firestore
          firestoreBatch.set(
              _firestore
                  .collection(Collections.PRODUCTS)
                  .doc(localProduct.id.toString()),
              localProduct.toMap());
        }
      }

      for (var remoteProduct in remoteData) {
        if (!localDataMap.containsKey(remoteProduct.id)) {
          // If the product exists only in remote, add it to SQLite
          sqliteBatch.insert('products', remoteProduct.toMap());
        }
      }

      // Commit the batches
      await firestoreBatch.commit();
      await sqliteBatch.commit();
    }
  }
}
