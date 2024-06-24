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
  void onClose() {
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
        break;
      case ConnectivityResult.mobile:
        connectionStatus.value = 2;
        if (Get.isSnackbarOpen) {
          Get.closeCurrentSnackbar();
        }
        break;
      case ConnectivityResult.none:
        connectionStatus.value = 0;
        break;
      default:
        Get.snackbar("Network Error", 'Failed to connect to a network');
    }
  }
}

// OfflineIcon widget
class OfflineIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 10,
      left: 10,
      child: CircleAvatar(
        backgroundColor: Colors.red,
        child: Icon(
          Icons.wifi_off,
          color: Colors.white,
        ),
      ),
    );
  }
}

// Usage in the main widget tree
class MainPage extends StatelessWidget {
  final NetworkController networkController = Get.put(NetworkController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Network Status Demo'),
      ),
      body: Stack(
        children: [
          Center(
            child: Text('Your main content goes here'),
          ),
          Obx(() {
            if (networkController.connectionStatus.value == 0) {
              return OfflineIcon();
            } else {
              return SizedBox.shrink();
            }
          }),
        ],
      ),
    );
  }
}

void main() {
  runApp(
    GetMaterialApp(
      home: MainPage(),
    ),
  );
}
