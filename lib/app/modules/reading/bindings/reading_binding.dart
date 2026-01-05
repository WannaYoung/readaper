// Package imports:
import 'package:get/get.dart';

// Project imports:
import 'package:readaper/app/modules/bookmark/bookmark.dart';
import '../controllers/reading_controller.dart';
import '../services/reading_content_service.dart';

class ReadingBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ReadingContentService());
    Get.lazyPut(() => ReadingController(
          Get.find<BookmarkProvider>(),
          Get.find<ReadingContentService>(),
        ));
  }
}
