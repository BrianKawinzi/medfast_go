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
  final AuthenticationController authenticationController = Get.find();
  final SyncService _syncService = SyncService();
  final DatabaseHelper _dbHelper = DatabaseHelper();

  static final FirebaseFirestore firestoreInstance = FirebaseFirestore.instance;
  static final firebase_storage.FirebaseStorage storageInstance =
      firebase_storage.FirebaseStorage.instance;

  var selectedFile = "".obs;
  Rx<XFile> selectedImageFile = XFile('').obs;
  RxBool creatingLoading = false.obs;
  RxBool updatingProduct = false.obs;
  FilePickerResult? result;

  TextEditingController productNameController = TextEditingController();
  TextEditingController productPriceController = TextEditingController();
  TextEditingController productDescriptionController = TextEditingController();
  TextEditingController productMinController = TextEditingController();
  TextEditingController productCurrController = TextEditingController();
  Timestamp firestoreTimestamp = Timestamp.fromDate(DateTime.now());

  var connectivityResult = ConnectivityResult.none.obs;

  @override
  void onInit() {
    super.onInit();
    networkController.connectivity.onConnectivityChanged.listen((result) {
      connectivityResult.value = result;
    });

    ever(connectivityResult, (result) {
      if (result != ConnectivityResult.none) {
        _syncService.syncData();
      }
    });
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
        return;
      }

      // Check if product with the same name already exists in Firestore
      CollectionReference productsCollection =
          firestoreInstance.collection(Collections.PRODUCTS);
      QuerySnapshot existingProducts = await productsCollection
          .where('productName', isEqualTo: product.productName)
          .get();

      if (existingProducts.docs.isNotEmpty) {
        creatingLoading.value = false;
        CommonUtils.showToast('Product with this name already exists.',
            color: Colors.red);
        return;
      }

      String imageUrl = '';
      if (image != null) {
        String newImageFilename =
            '${product.productName + product.id.toString()}.jpg';
        firebase_storage.Reference reference = storageInstance
            .ref()
            .child(authenticationController.currentUserData.value.uid)
            .child('product-images')
            .child(newImageFilename);

        final metadata = firebase_storage.SettableMetadata(
            contentType: 'image/jpeg',
            customMetadata: {'picked-file-path': image.path});
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
      }

      product.userId = authenticationController.currentUserData.value.uid;
      product.image = imageUrl;

      // Store in Firestore
      await productsCollection.doc(product.id.toString()).set(product.toMap());

      // Store in SQLite
      await _dbHelper.insertProduct(product);

      creatingLoading.value = false;
      clearControllers();
      Navigator.pushReplacementNamed(context, '/product');
      CommonUtils.showToast('Product data stored successfully.');
    } on FirebaseException catch (e) {
      CommonUtils.showToast(e.message.toString());
      debugPrint(e.code);
      creatingLoading.value = false;
      update();
    } catch (e) {
      print("Error: $e");
      CommonUtils.showToast('An error occurred while storing the product.');
      creatingLoading.value = false;
      debugPrint(e.toString());
    }
  }

  Future<void> updateProduct({
    required Product product,
    required BuildContext context,
  }) async {
    updatingProduct.value = true;

    try {
      if (product.buyingPrice == 0.0 && product.sellingPrice == 0.0 ||
          product.sellingPrice < product.buyingPrice) {
        showInvalidPricingDialog(context);
        return;
      }

      product.phamacyId =
          authenticationController.currentUserData.value.phymacyId;
      if (networkController.connectionStatus.value != 0) {
        product.userId = authenticationController.currentUserData.value.uid;
        await firestoreInstance
            .collection(Collections.PRODUCTS)
            .doc(product.id.toString())
            .update(product.toMap());
        updatingProduct.value = false;
        clearControllers();
        Navigator.pushReplacementNamed(context, '/product');
        CommonUtils.showToast(
            'Product data updated in Firestore successfully.');
      } else {
        product.userId = authenticationController.currentUserData.value.uid;
        await _dbHelper.updateProduct(product);
        updatingProduct.value = false;
        clearControllers();
        Navigator.pushReplacementNamed(context, '/product');
        CommonUtils.showToast('Product updated stored in SQLite successfully.');
      }
    } on FirebaseException catch (e) {
      CommonUtils.showToast(e.message.toString());
      debugPrint(e.code);
      updatingProduct.value = false;
      update();
    } catch (e) {
      print("Error: $e");
      CommonUtils.showToast('An error occurred while updating the product.');
      updatingProduct.value = false;
      debugPrint(e.toString());
    }
  }

  Future<void> deleteProduct(
      {required Product product, required BuildContext context}) async {
    try {
      if (networkController.connectionStatus.value != 0) {
        await _deleteProductFromFirestore(product);
        await _deleteImageFromFirebaseStorage(product.image);
      } else {
        await _deleteProductFromSQLite(product);
      }
      Navigator.pushReplacementNamed(context, '/product');
      CommonUtils.showToast('Product deleted successfully.');
    } on FirebaseException catch (e) {
      handleError(e.message!);
    } catch (e) {
      handleError(e.toString());
    }
  }

  Future<void> _deleteProductFromFirestore(Product product) async {
    await firestoreInstance
        .collection(Collections.PRODUCTS)
        .doc(product.id.toString())
        .delete();
  }

  Future<void> _deleteImageFromFirebaseStorage(String? imageUrl) async {
    if (imageUrl != null && imageUrl.isNotEmpty) {
      try {
        firebase_storage.Reference reference =
            storageInstance.refFromURL(imageUrl);
        await reference.delete();
      } catch (e) {
        debugPrint('Error deleting image: $e');
      }
    }
  }

  Future<void> _deleteProductFromSQLite(Product product) async {
    await _dbHelper.deleteProduct(product.id);
  }

  Future<Product?> fetchProductByBarcode({required String barcode}) async {
    if (networkController.connectionStatus.value != 0) {
      return await _fetchProductByBarcodeFromFirebase(barcode);
    } else {
      return await _dbHelper.getProductByBarcode(barcode);
    }
  }

  Future<Product?> _fetchProductByBarcodeFromFirebase(String barcode) async {
    try {
      CollectionReference productsCollection =
          firestoreInstance.collection(Collections.PRODUCTS);
      QuerySnapshot querySnapshot =
          await productsCollection.where('barcode', isEqualTo: barcode).get();

      if (querySnapshot.docs.isNotEmpty) {
        DocumentSnapshot productSnapshot = querySnapshot.docs.first;
        Map<String, dynamic> productData =
            productSnapshot.data() as Map<String, dynamic>;
        return Product.fromMap(productData);
      } else {
        CommonUtils.showToast('No product by that barcode');
        return null;
      }
    } catch (e) {
      print('Error fetching product: $e');
      return null;
    }
  }

  Stream<List<Product>> fetchProducts() {
    StreamController<List<Product>> controller =
        StreamController<List<Product>>();
    if (networkController.connectionStatus.value != 0) {
      firestoreInstance
          .collection(Collections.PRODUCTS)
          .where('pharmacy_id',
              isEqualTo:
                  authenticationController.currentUserData.value.phymacyId)
          .snapshots()
          .listen((querySnapshot) async {
        List<Product> products = querySnapshot.docs
            .map((doc) => Product.fromMap(doc.data()))
            .toList();
        await _dbHelper.clearProducts();
        for (var product in products) {
          await _dbHelper.insertProduct(product);
        }
        controller.add(products);
      });
    } else {
      _dbHelper.getProducts().then((products) => controller.add(products));
    }
    return controller.stream;
  }

  void clearControllers() {
    productNameController.clear();
    productPriceController.clear();
    productDescriptionController.clear();
    productMinController.clear();
    productCurrController.clear();
    selectedImageFile.close();
  }

void showInvalidPricingDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
title: const Text("Invalid Pricing"),
          content: const Text(
              "The selling price must be greater than or equal to the buying price, which must not be 0."),
          actions: [
            TextButton(
child: const Text("OK"),
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
}
