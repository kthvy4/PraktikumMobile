import 'package:demo_mobile/app/modules/connection/controller/connection_controller.dart';
import 'package:get/get.dart';

class ConnectionBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ConnectionController>(() => ConnectionController());
  }
}
