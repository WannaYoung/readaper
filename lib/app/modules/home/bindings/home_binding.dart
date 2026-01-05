// Package imports:
import 'package:get/get.dart';

// Project imports:
import 'package:readaper/app/modules/bookmark/bookmark.dart';
import '../../home/controllers/controllers.dart';
import '../services/home_dialogs_service.dart';
import '../services/home_error_handler.dart';
import '../services/home_layout_service.dart';
import '../services/home_sidebar_service.dart';

/// 首页模块依赖注入
///
/// - 统一注册 home 模块用到的 Controller/Service/Repository
/// - 由 GetX 在路由进入时调用
class HomeBinding extends Bindings {
  /// 注册依赖
  @override
  void dependencies() {
    Get.lazyPut(() => SidebarGestureController());
    Get.lazyPut(() =>
        HomeSidebarService(sidebar: Get.find<SidebarGestureController>()));
    Get.lazyPut(() => HomeLayoutService());
    Get.lazyPut(() => HomeErrorHandler());
    Get.lazyPut(() => BookmarkRepository(
          provider: Get.find<BookmarkProvider>(),
          db: Get.find<BookmarkDbService>(),
        ));
    Get.lazyPut(() {
      final repo = Get.find<BookmarkRepository>();
      return HomeListController(repo);
    });
    Get.lazyPut(() => HomeDialogsService());
    Get.lazyPut(() => HomeController(Get.find<BookmarkProvider>()));
  }
}
