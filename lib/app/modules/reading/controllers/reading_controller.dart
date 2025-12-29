import 'package:get/get.dart';
import 'package:readaper/app/modules/home/models/bookmark.dart';
import 'package:readaper/app/modules/reading/models/reading_settings.dart';
import 'package:readaper/app/modules/home/controllers/home_controller.dart';
import '../../home/providers/bookmark_provider.dart';
import '../../../network/api_client.dart';

/// 阅读页控制器
///
/// - 负责加载文章 Markdown
/// - 负责阅读设置加载/保存/临时调整
/// - 负责滚动时 AppBar 显隐
class ReadingController extends GetxController {
  final BookmarkProvider provider;
  ReadingController(this.provider);

  final markdown = ''.obs;
  final loading = false.obs;
  final showAppBar = true.obs;
  final lastOffset = 0.0.obs; // 滚动偏移
  final isReady = false.obs;
  final article = Bookmark().obs;

  // 阅读设置
  final settings = ReadingSettings().obs;
  final tempSettings = ReadingSettings().obs; // 用于临时调整

  final articleId = ''.obs;

  @override
  void onInit() {
    super.onInit();
    // 读取路由参数中的书签信息
    final args = Get.arguments;
    if (args is Map && args['bookmark'] is Bookmark) {
      article.value = args['bookmark'] as Bookmark;
    }
    articleId.value = article.value.id ?? '';

    // 加载设置
    loadSettings();

    if (articleId.value.isNotEmpty) {
      // 延迟一帧再加载，让页面先显示出来
      Future.microtask(() => fetchMarkdown());
    }
  }

  /// 加载阅读设置
  Future<void> loadSettings() async {
    final loadedSettings = await ReadingSettings.load();
    settings.value = loadedSettings;
    tempSettings.value = loadedSettings.copy();
  }

  /// 保存阅读设置
  Future<void> saveSettings() async {
    settings.value = tempSettings.value.copy();
    await settings.value.save();
    Get.snackbar('success'.tr, 'settingsSaved'.tr);
  }

  /// 重置设置为默认值
  void resetSettings() {
    tempSettings.value = ReadingSettings();
  }

  /// 应用临时设置（用于实时预览）
  void applyTempSettings() {
    settings.value = tempSettings.value.copy();
  }

  /// 拉取文章 Markdown 内容
  Future<void> fetchMarkdown() async {
    if (loading.value) return;
    loading.value = true;
    try {
      // 先显示加载动画
      isReady.value = false;

      // 异步加载内容
      final content = await provider.getArticleMarkdown(articleId.value);

      // 处理内容（去掉 frontmatter、统一 https 等）
      String processedContent = content
          .replaceAll('http://', 'https://')
          .replaceFirst(RegExp(r'^---[\s\S]*?---\s*'), '')
          .replaceAll('。**', '**');

      if (processedContent.trim().isEmpty) {
        processedContent = 'loadFailed'.tr;
      }

      // 更新内容
      markdown.value = processedContent;

      // 延迟一帧再显示内容，让过渡更平滑
      await Future.delayed(const Duration(milliseconds: 50));
      isReady.value = true;
    } on ApiException catch (e) {
      Get.snackbar('failed'.tr, e.message);
      markdown.value = 'loadFailed'.tr;
      isReady.value = true;
    } catch (e) {
      Get.snackbar('failed'.tr, e.toString());
      markdown.value = 'loadFailed'.tr;
      isReady.value = true;
    } finally {
      loading.value = false;
    }
  }

  /// 收藏/取消收藏
  void clickFavorite() {
    final homeController = Get.find<HomeController>();
    homeController
        .markBookmark(article.value, !article.value.isMarked)
        .then((_) {
      article.update((val) {
        val?.isMarked = !article.value.isMarked;
      });
    });
  }

  /// 归档/取消归档
  void clickArchive() {
    final homeController = Get.find<HomeController>();
    homeController
        .archiveBookmark(article.value, !article.value.isArchived)
        .then((_) {
      article.update((val) {
        val?.isArchived = !article.value.isArchived;
      });
    });
  }

  /// 滚动监听，控制AppBar显隐
  void handleScroll(double offset) {
    double delta = offset - lastOffset.value;
    if (delta > 1 && showAppBar.value) {
      showAppBar.value = false;
    } else if (delta < -1 && !showAppBar.value) {
      showAppBar.value = true;
    }
    lastOffset.value = offset;
  }
}
