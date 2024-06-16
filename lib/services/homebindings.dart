import 'package:get/get.dart';
import 'package:medfast_go/services/network_provider.dart';

class HomeBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<NetworkController>(NetworkController());
  }
}
