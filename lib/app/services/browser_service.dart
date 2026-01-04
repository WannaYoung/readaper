import 'package:get/get.dart';
import 'package:readaper/app/shared/widgets/in_app_browser_page.dart';

/// 浏览器服务
///
/// - 统一负责在 App 内打开链接
/// - 避免散落 Get.to
class BrowserService {
  /// 在 App 内置浏览器中打开链接
  ///
  /// - url：链接
  static void open(String url, {String? title}) {
    final link = url.trim();
    if (link.isEmpty) return;

    Get.to(() => InAppBrowserPage(
          url: link,
          title: title,
        ));
  }
}
