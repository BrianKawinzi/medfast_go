import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:csv/csv.dart';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:medfast_go/constants/firebase_collections.dart';
import 'package:medfast_go/data/DatabaseHelper.dart';
import 'package:medfast_go/models/product.dart';
import 'package:medfast_go/services/SyncService.dart';
import 'package:medfast_go/services/network_provider.dart';
import 'package:medfast_go/utills/common.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class ProductsController extends GetxController {
  final NetworkController networkController = Get.find();

  static final FirebaseFirestore db = FirebaseFirestore.instance;
  static final firebase_storage.FirebaseStorage firebaseStorage =
      firebase_storage.FirebaseStorage.instance;
  final DatabaseHelper _dbHelper = DatabaseHelper();

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

  Future<void> storeProduct({
    required File? image,
    required Product product,
    required BuildContext context,
  }) async {
    creatingLoading.value = true;

    try {
      if (product.buyingPrice == 0.0 && product.sellingPrice == 0.0 ||
          product.sellingPrice < product.buyingPrice) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Invalid Pricing'),
              content: const Text(
                  'The selling price must be greater than or equal to the buying price which must not be equal to 0'),
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
        return;
      }

      // Check if a product with the same name already exists
      CollectionReference productsCollection =
          db.collection(Collections.PRODUCTS);
      QuerySnapshot existingProducts = await productsCollection
          .where('itemName', isEqualTo: productNameController.text)
          .get();

      if (existingProducts.docs.isNotEmpty) {
        creatingLoading.value = false;
        CommonUtils.showToast('Product with this name already exists.',
            color: Colors.red);
        return;
      }

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
          customMetadata: {'picked-file-path': image!.path ?? ''});

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

      if (networkController.connectionStatus.value == 0) {
        await productsCollection
            .doc(product.id.toString())
            .set(product.toMap());
        creatingLoading.value = false;
        Navigator.pushReplacementNamed(context, '/product');
        clearControllers();
        CommonUtils.showToast('Product data stored in Firestore successfully.');
      } else {
        await _dbHelper.insertProduct(product);
        creatingLoading.value = false;
        Navigator.pushReplacementNamed(context, '/product');
        clearControllers();
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

  // Future<void> updateProduct({
  //   required String imageUrl,
  //   required String productId,
  // }) async {
  //   updatingProduct.value = true;
  //   try {
  //     DocumentSnapshot? productDoc = await getProductDocumentById(productId);
  //     final Timestamp firestoreTimestamp = Timestamp.now();

  //     if (productDoc != null) {
  //       Map<String, dynamic> updatedProduct = ProductModel(
  //         itemName: productNameController.text,
  //         itemDescription: productdescriptionController.text,
  //         price: productPriceController.text,
  //         createdOn: firestoreTimestamp.toDate().toString(),
  //         image: imageUrl.toString(),
  //         minStock: productMinController.text,
  //         currStock: productCurrController.text,
  //         shopId:
  //             authenticationController.currentUserData.value.shopId.toString(),
  //         id: productId,
  //         uid: authenticationController.firebaseUser.value!.uid,
  //       ).toMap();

  //       await FirebaseFirestore.instance
  //           .collection(Collections.PRODUCTS)
  //           .doc(productDoc.id)
  //           .update(updatedProduct);
  //       Get.offAll(const ProductsPage());
  //       productCurrController.clear();
  //       productdescriptionController.clear();
  //       productPriceController.clear();
  //       productMinController.clear();
  //       productNameController.clear();
  //       selectedImageFile.close();
  //       updatingProduct.value = false;
  //       return CommonUtils.showToast('product data updated successfully.');
  //     } else {
  //       updatingProduct.value = false;
  //       CommonUtils.showToast(
  //         "Product not found for the given ID.",
  //         color: Colors.red,
  //       );
  //     }
  //   } on FirebaseException catch (e) {
  //     updatingProduct.value = false;
  //     CommonUtils.showToast(e.message.toString(), color: Colors.red);
  //   }
  // }

  // sendProductLimitFcm({
  //   required String productName,
  //   required String limit,
  // }) async {
  //   // Get the user's FCM token
  //   DocumentSnapshot userDoc = await FirebaseFirestore.instance
  //       .collection(Collections.USERS)
  //       .doc(authenticationController.currentUserData.value.managerUid)
  //       .get();
  //   String? fcmToken = userDoc['fcm_Token'];
  //   String? managerName = userDoc['name'];

  //   // Send push notification to the user
  //   if (fcmToken != null) {
  //     await pushNotifaction.sendPushNotification(
  //       title: 'Product Quantity Alert',
  //       body:
  //           'Dear $managerName, The quantity of a $productName has reached a $limit ,Please restock .',
  //       fcmToken: fcmToken,
  //       page: 'reports',
  //       itemId: '',
  //     );
  //   }
  // }

  Future<void> requestPermissions() async {
    await Permission.storage.request();
  }

  Future<void> uploadExcel(FilePickerResult file) async {
    if (result != null) {
      File file = File(result!.files.single.path!);

      // Read the Excel file
      var bytes = file.readAsBytesSync();
      var excel = Excel.decodeBytes(bytes);
      // Convert to CSV data and store in Firestore
      await storeToProductsFromExel(excel);
    }
  }

  Future<void> storeToProductsFromExel(Excel excel) async {
    CollectionReference collection =
        FirebaseFirestore.instance.collection('uploads');

    Map<String, dynamic> rowData = {};
    for (var table in excel.tables.keys) {
      for (var row in excel.tables[table]!.rows) {
        for (var cell in row) {
          if (cell != null) {
            rowData[cell.cellIndex.toString()] = cell.value;
          }
        }
      }
    }
    List<List<dynamic>> cvsTable =
        const CsvToListConverter().convert(rowData.toString());
    List<List<dynamic>> data = [];
    data = cvsTable;

    for (var i = 0; i < data.length; i++) {
      var record = {
        "data": data[i][1],
      };
      collection.add(record);
    }
    CommonUtils.showToast("Added sucessfully");
  }
}
