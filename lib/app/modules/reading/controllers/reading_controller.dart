import 'package:get/get.dart';
import 'package:readaper/app/modules/home/models/bookmark.dart';
import 'package:readaper/app/modules/reading/models/reading_settings.dart';
import 'package:readaper/app/modules/home/controllers/home_controller.dart';
import 'package:readaper/app/services/browser_service.dart';
import 'package:share_plus/share_plus.dart';
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

  final imageUrls = <String>[].obs;

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

  String _removeFirstImageAfterFirstH1(String text) {
    final matchH1 = RegExp(r'^#\s+.+$', multiLine: true).firstMatch(text);
    if (matchH1 == null) return text;

    final start = matchH1.end;
    if (start < 0 || start >= text.length) return text;

    final after = text.substring(start);
    final matchImage = RegExp(
      r'^\s*(?:\r?\n)+\s*!\[[^\]]*\]\(\s*(?:<[^>]+>|[^)\s]+)(?:\s+"[^"]*")?\s*\)\s*(?:\r?\n+)?',
    ).firstMatch(after);
    if (matchImage == null) return text;

    return text.substring(0, start) +
        after.replaceRange(matchImage.start, matchImage.end, '\n');
  }

  /// 加载阅读设置
  Future<void> loadSettings() async {
    final loadedSettings = await ReadingSettings.load();
    settings.value = loadedSettings;
    tempSettings.value = loadedSettings.copy();
  }

  /// 保存阅读设置
  Future<void> saveSettings({bool showToast = true}) async {
    settings.value = tempSettings.value.copy();
    await settings.value.save();
    if (showToast) {
      Get.snackbar('success'.tr, 'settingsSaved'.tr);
    }
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

      processedContent = _removeFirstImageAfterFirstH1(processedContent);

      if (processedContent.trim().isEmpty) {
        processedContent = 'loadFailed'.tr;
      }

      // 更新内容
      markdown.value = processedContent;

      imageUrls.value = _extractImageUrlsFromMarkdown(processedContent);

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

  List<String> _extractImageUrlsFromMarkdown(String text) {
    final urls = <String>[];
    final seen = <String>{};

    final matches = RegExp(r'!\[[^\]]*\]\(([^)\s]+)').allMatches(text);
    for (final m in matches) {
      final raw = (m.group(1) ?? '').trim();
      if (raw.isEmpty) continue;
      final url = raw.startsWith('<') && raw.endsWith('>')
          ? raw.substring(1, raw.length - 1)
          : raw;
      if (url.isEmpty) continue;
      if (seen.add(url)) {
        urls.add(url);
      }
    }
    return urls;
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

  /// 分享文章
  ///
  /// - 分享标题 + 链接
  /// - 若链接为空则不执行
  void shareArticle() {
    final title = (article.value.title ?? '').trim();
    final url = (article.value.url ?? '').trim();
    if (url.isEmpty) return;

    final text = title.isEmpty ? url : '$title\n$url';
    Share.share(text);
  }

  /// 打开来源
  ///
  /// - 优先 labels.url，回退 article.url
  void openSource() {
    final url = _firstLabelUrl(article.value).trim();
    if (url.isEmpty) return;

    BrowserService.open(url, title: article.value.title);
  }

  /// 获取“来源链接”
  ///
  /// - 优先 labels.url，回退 bookmark.url
  String _firstLabelUrl(Bookmark bookmark) {
    try {
      final labels = bookmark.labels;
      if (labels == null) {
        return (bookmark.url ?? '').trim();
      }

      for (final item in labels) {
        if (item is Map) {
          final raw = item['url'];
          final url = (raw ?? '').toString().trim();
          if (url.isNotEmpty) return url;
        }
      }
      return (bookmark.url ?? '').trim();
    } catch (_) {
      return '';
    }
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
