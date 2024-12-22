import 'package:demo_mobile/app/modules/connection/binding/connection_binding.dart';

class DependencyInjection {
  
  static void init() {
    ConnectionBinding().dependencies();
  }
}