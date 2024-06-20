import 'package:get/get.dart';
import 'package:medfast_go/controllers/authentication_controller.dart';
import 'package:medfast_go/controllers/products_controller.dart';
import 'package:medfast_go/services/network_provider.dart';

class HomeBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<AuthenticationController>(AuthenticationController());
    Get.put<NetworkController>(NetworkController());
    Get.put<ProductsController>(ProductsController());
  }
}
