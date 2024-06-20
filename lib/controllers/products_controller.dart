import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:medfast_go/constants/firebase_collections.dart';
import 'package:medfast_go/controllers/authentication_controller.dart';
import 'package:medfast_go/data/DatabaseHelper.dart';
import 'package:medfast_go/models/product.dart';
import 'package:medfast_go/services/SyncService.dart';
import 'package:medfast_go/services/network_provider.dart';
import 'package:medfast_go/utills/common.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class ProductsController extends GetxController {
  final NetworkController networkController = Get.find();

  static final FirebaseFirestore db = FirebaseFirestore.instance;
  static final firebase_storage.FirebaseStorage firebaseStorage =
      firebase_storage.FirebaseStorage.instance;
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  var selectedFile = "".obs;
  Rx<XFile> selectedImageFile = XFile('').obs;
  RxBool creatingLoading = false.obs;
  RxBool updatingProduct = false.obs;
  FilePickerResult? result;

  TextEditingController productNameController = TextEditingController();
  TextEditingController productPriceController = TextEditingController();
  TextEditingController productdescriptionController = TextEditingController();
  TextEditingController productMinController = TextEditingController();
  TextEditingController productCurrController = TextEditingController();
  Timestamp firestoreTimestamp = Timestamp.fromDate(DateTime.now());
  final SyncService _syncService = SyncService();
  var connectivityResult = ConnectivityResult.none.obs;
  final AuthenticationController authenticationController = Get.find();

  @override
  void onInit() {
    super.onInit();
    networkController.connectivity.onConnectivityChanged
        .listen((ConnectivityResult result) {
      connectivityResult.value = result;
    });

    ever(connectivityResult, (ConnectivityResult result) {
      if (result != ConnectivityResult.none) {
        _syncService.syncData();
      }
    });
  }

  Stream<List<Product>> fetchProducts() {
    StreamController<List<Product>> controller =
        StreamController<List<Product>>();
    if (networkController.connectionStatus.value != 0) {
      firestore
          .collection(Collections.PRODUCTS)
          .where('pharmacy_id',
              isEqualTo:
                  authenticationController.currentUserData.value.phymacyId)
          .snapshots()
          .listen((querySnapshot) async {
        List<Product> products = querySnapshot.docs.map((doc) {
          return Product.fromMap(doc.data());
        }).toList();
        await _dbHelper.clearProducts();
        for (var product in products) {
          await _dbHelper.insertProduct(product);
        }
        controller.add(products);
      });
    } else {
      _dbHelper.getProducts().then((products) {
        controller.add(products);
      });
    }
    return controller.stream;
  }

  Future<void> storeProduct({
    required File? image,
    required Product product,
    required BuildContext context,
  }) async {
    creatingLoading.value = true;

    try {
      if (product.buyingPrice == 0.0 && product.sellingPrice == 0.0 ||
          product.sellingPrice < product.buyingPrice) {
        showInvalidPricingDialog(context);
      }

      CollectionReference productsCollection =
          db.collection(Collections.PRODUCTS);
      QuerySnapshot existingProducts = await productsCollection
          .where('productName', isEqualTo: product.productName)
          .get();

      if (existingProducts.docs.isNotEmpty) {
        creatingLoading.value = false;
        CommonUtils.showToast('Product with this name already exists.',
            color: Colors.red);
        return;
      }

      if (networkController.connectionStatus.value != 0) {
        String imageUrl;
        String newImageFilename =
            '${product.productName + product.id.toString()}.jpg';

        firebase_storage.Reference reference = firebaseStorage
            .ref()
            .child(authenticationController.currentUserData.value.uid)
            .child('product-images')
            .child(newImageFilename);

        final metadata = firebase_storage.SettableMetadata(
            contentType: 'image/jpeg',
            customMetadata: {'picked-file-path': image!.path});

        if (image.path.isNotEmpty) {
          if (kIsWeb) {
            await reference.putData(await image.readAsBytes(), metadata);
            imageUrl = await reference.getDownloadURL();
          } else {
            await reference.putFile(image, metadata);
            imageUrl = await reference.getDownloadURL();
          }
        } else {
          imageUrl = '';
        }

        product.userId = authenticationController.currentUserData.value.uid;
        product.image = imageUrl;
        await productsCollection
            .doc(product.id.toString())
            .set(product.toMap());
        creatingLoading.value = false;
        clearControllers();
        Navigator.pushReplacementNamed(context, '/product');
        CommonUtils.showToast('Product data stored in Firestore successfully.');
      } else {
        await _dbHelper.insertProduct(product);
        creatingLoading.value = false;
        clearControllers();
        Navigator.pushReplacementNamed(context, '/product');
        CommonUtils.showToast('Product data stored in SQLite successfully.');
      }
    } on FirebaseException catch (e) {
      CommonUtils.showToast(e.message.toString());
      debugPrint(e.code);
      creatingLoading.value = false;
      update();
    } catch (e) {
      print("::::::::error$e");
      creatingLoading.value = false;
      debugPrint(e.toString());
    }
  }

  Future<void> updateProduct({
    required Product product,
    required BuildContext context,
  }) async {
    creatingLoading.value = true;

    try {
      if (product.buyingPrice == 0.0 && product.sellingPrice == 0.0 ||
          product.sellingPrice < product.buyingPrice) {
        showInvalidPricingDialog(context);
      }
      product.phamacyId =
          authenticationController.currentUserData.value.phymacyId;
      if (networkController.connectionStatus.value != 0) {
        product.userId = authenticationController.currentUserData.value.uid;
        await db
            .collection(Collections.PRODUCTS)
            .doc(product.id.toString())
            .update(product.toMap());
        creatingLoading.value = false;
        clearControllers();
        Navigator.pushReplacementNamed(context, '/product');
        CommonUtils.showToast(
            'Product data updated in Firestore successfully.');
      } else {
        product.userId = authenticationController.currentUserData.value.uid;
        await _dbHelper.insertProduct(product);
        creatingLoading.value = false;
        clearControllers();
        Navigator.pushReplacementNamed(context, '/product');
        CommonUtils.showToast('Product updated stored in SQLite successfully.');
      }
    } on FirebaseException catch (e) {
      CommonUtils.showToast(e.message.toString());
      debugPrint(e.code);
      creatingLoading.value = false;
      update();
    } catch (e) {
      print("::::::::error$e");
      creatingLoading.value = false;
      debugPrint(e.toString());
    }
  }

  fetchProductByBarcode({required String barcode}) async {
    if (networkController.connectionStatus.value != 0) {
      return await fetchProductByBarcodeFromFirebase(barcode);
    } else {
      return await _dbHelper.getProductByBarcode(barcode);
    }
  }

  Future fetchProductByBarcodeFromFirebase(String barcode) async {
    try {
      CollectionReference productsCollection =
          FirebaseFirestore.instance.collection(Collections.PRODUCTS);

      QuerySnapshot querySnapshot =
          await productsCollection.where('barcode', isEqualTo: barcode).get();

      if (querySnapshot.docs.isNotEmpty) {
        // Assuming there's only one product with the specified barcode
        DocumentSnapshot productSnapshot = querySnapshot.docs.first;
        Map<String, dynamic> productData =
            productSnapshot.data() as Map<String, dynamic>;
        Product product = Product.fromMap(productData);
        return product;
      } else {
        return CommonUtils.showToast('No product by that barcode');
      }
    } catch (e) {
      print('Error fetching product: $e');
      // Handle errors here
    }
  }

  Future<void> updateProductQuantity(List<Map<String, dynamic>> sales) async {
    try {
      CollectionReference productsCollection =
          FirebaseFirestore.instance.collection('products');

      WriteBatch batch = FirebaseFirestore.instance.batch();

      for (var sale in sales) {
        DocumentReference productDoc =
            productsCollection.doc(sale['productId']);
        DocumentSnapshot productSnapshot = await productDoc.get();

        if (productSnapshot.exists) {
          Product product =
              Product.fromMap(productSnapshot.data() as Map<String, dynamic>);
          num newQuantity = product.quantity - sale['quantity'];
          num quantitySold = product.soldQuantity + sale['quantitySold'];

          if (newQuantity < 0) {
            newQuantity = 0;
          }

          batch.update(productDoc, {
            'quantity': newQuantity,
            'soldQuantity': quantitySold,
          });
        }
      }

      await batch.commit();
      print('Product quantities updated successfully.');
    } catch (e) {
      print('Error updating product quantities: $e');
      // Handle errors here
    }
  }

  void showInvalidPricingDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Invalid Pricing'),
          content: const Text(
              'The selling price must be greater than or equal to the buying price, which must not be 0.'),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void handleError(String error) {
    CommonUtils.showToast(error);
    debugPrint(error);
  }

  clearControllers() {
    productCurrController.clear();
    productdescriptionController.clear();
    productPriceController.clear();
    productMinController.clear();
    productNameController.clear();
    selectedImageFile.close();
  }

  Future<DocumentSnapshot?> getProductDocumentById(String productId) async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection(Collections.PRODUCTS)
        .where('id', isEqualTo: productId)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      return querySnapshot.docs.first;
    } else {
      print("No such document!");
      return null;
    }
  }

  Future<void> deleteProduct({
    required Product product,
    required BuildContext context,
  }) async {
    try {
      if (networkController.connectionStatus.value != 0) {
        await deleteProductFromFirestore(product);
        await deleteImageFromFirebaseStorage(product.image);
      } else {
        // Offline: Delete from SQLite
        await deleteProductFromSQLite(product);
      }
      Navigator.pushReplacementNamed(context, '/product');
      CommonUtils.showToast('Product deleted successfully.');
    } on FirebaseException catch (e) {
      handleError(e.message!);
    } catch (e) {
      handleError(e.toString());
    } finally {}
  }

  Future<void> deleteProductFromFirestore(Product product) async {
    await db
        .collection(Collections.PRODUCTS)
        .doc(product.id.toString())
        .delete();
  }

  Future<void> deleteImageFromFirebaseStorage(String? imageUrl) async {
    if (imageUrl != null && imageUrl.isNotEmpty) {
      try {
        firebase_storage.Reference reference =
            firebaseStorage.refFromURL(imageUrl);
        await reference.delete();
      } catch (e) {
        debugPrint('Error deleting image: $e');
      }
    }
  }

  Future<void> deleteProductFromSQLite(Product product) async {
    await _dbHelper.deleteProduct(product.id);
  }
}
