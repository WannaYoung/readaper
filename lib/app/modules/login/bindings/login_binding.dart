// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../controllers/login_controller.dart';
import '../providers/auth_provider.dart';
import '../repositories/auth_repository.dart';
import '../services/auth_storage_service.dart';

class LoginBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => AuthProvider());
    Get.lazyPut(() => AuthRepository(
          provider: Get.find<AuthProvider>(),
          storage: Get.find<AuthStorageService>(),
        ));
    Get.lazyPut(() => LoginController(Get.find<AuthRepository>()));
  }
}
