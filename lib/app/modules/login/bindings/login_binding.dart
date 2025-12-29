import 'package:get/get.dart';
import '../controllers/login_controller.dart';
import '../providers/auth_provider.dart';

class LoginBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => AuthProvider());
    Get.lazyPut(() => LoginController(Get.find<AuthProvider>()));
  }
}
