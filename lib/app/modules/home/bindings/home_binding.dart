import 'package:get/get.dart';

import '../controllers/home_controller.dart';
import '../providers/bookmark_provider.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => BookmarkProvider());
    Get.lazyPut(() => HomeController(Get.find<BookmarkProvider>()));
  }
}
