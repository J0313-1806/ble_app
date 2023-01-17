import 'package:ble_app/source/controller/home_controller.dart';
import 'package:get/get.dart';

class AppBindings extends Bindings {
  @override
  void dependencies() {
    Get.put(HomeController());
  }
}
