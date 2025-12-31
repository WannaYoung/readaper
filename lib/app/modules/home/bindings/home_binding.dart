import 'package:get/get.dart';
import '../providers/bookmark_provider.dart';
import '../../home/controllers/controllers.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => BookmarkProvider());
    Get.lazyPut(() => SidebarGestureController());
    Get.lazyPut(() => HomeListController(Get.find<BookmarkProvider>()));
    Get.lazyPut(() => HomeController(Get.find<BookmarkProvider>()));
  }
}
