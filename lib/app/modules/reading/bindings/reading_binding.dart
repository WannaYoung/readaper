import 'package:get/get.dart';
import '../controllers/reading_controller.dart';
import '../../home/providers/bookmark_provider.dart';

class ReadingBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => BookmarkProvider());
    Get.lazyPut(() => ReadingController(Get.find<BookmarkProvider>()));
  }
}
