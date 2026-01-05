// Package imports:
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

// Project imports:
import '../modules/bookmark/bookmark.dart';
import '../modules/login/services/auth_storage_service.dart';
import 'app_lifecycle_service.dart';
import 'localization_service.dart';
import 'share_intent_service.dart';
import 'theme_service.dart';

class AppInitializer {
  static Future<void> init() async {
    await GetStorage.init();

    Get.put(LocalizationService());
    Get.put(ThemeService());
    Get.put(AuthStorageService());

    // 本地数据库可以提前初始化；网络 Provider 延迟到真正需要时再创建
    Get.put(BookmarkDbService());
    Get.lazyPut<BookmarkProvider>(() => BookmarkProvider(), fenix: true);

    Get.put(ShareIntentService()).init();
    Get.put(AppLifecycleService()).init();

    // 只有登录后才初始化同步服务，避免未登录时走到网络初始化链路
    final authStorage = Get.find<AuthStorageService>();
    if (authStorage.hasToken) {
      BookmarkSyncService().init();
    }
  }
}
