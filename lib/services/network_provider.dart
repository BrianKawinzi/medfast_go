import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class NetworkController extends GetxController {
  var connectionStatus = 0.obs;
  final Connectivity connectivity = Connectivity();
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;

  @override
  void onInit() {
    super.onInit();
    initConnectivity();
    _connectivitySubscription =
        connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }

  @override
  onClose() {
    _connectivitySubscription.cancel();
  }

  initConnectivity() async {
    ConnectivityResult result;
    try {
      result = await connectivity.checkConnectivity();
    } on PlatformException catch (e) {
      throw ({e});
    }
    return _updateConnectionStatus(result);
  }

  _updateConnectionStatus(ConnectivityResult result) {
    switch (result) {
      case ConnectivityResult.wifi:
        connectionStatus.value = 1;
        if (Get.isSnackbarOpen) {
          Get.closeCurrentSnackbar();
        }
        // _syncService.syncData();

        break;
      case ConnectivityResult.mobile:
        connectionStatus.value = 2;
        if (Get.isSnackbarOpen) {
          Get.closeCurrentSnackbar();
        }
        // _syncService.syncData();

        break;
      case ConnectivityResult.none:
        connectionStatus.value = 0;
        Get.rawSnackbar(
          messageText: const Text(
            'PLEASE CONNECT TO INTERNET',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
          ),
          isDismissible: false,
          duration: const Duration(days: 1),
          backgroundColor: Colors.red.shade400,
          icon: const Icon(
            Icons.wifi_off,
            color: Colors.white,
            size: 35,
          ),
          margin: EdgeInsets.zero,
          snackStyle: SnackStyle.GROUNDED,
        );
        break;

      default:
        Get.snackbar("Network Error", 'Failed to connect to a network');
    }
  }
}
