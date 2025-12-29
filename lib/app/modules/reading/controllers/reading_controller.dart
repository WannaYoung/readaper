import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:markdown_widget/markdown_widget.dart';
import 'package:readaper/app/data/models/bookmark.dart';
import 'package:readaper/app/data/models/reading_settings.dart';
import 'package:readaper/app/modules/home/controllers/home_controller.dart';
import '../../../data/providers/bookmark_provider.dart';

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

  late String articleId;

  @override
  void onInit() {
    super.onInit();
    article.value = Get.arguments['bookmark'] as Bookmark;
    articleId = article.value.id ?? '';

    // 加载设置
    loadSettings();

    if (articleId.isNotEmpty) {
      // 延迟一帧再加载，让页面先显示出来
      Future.microtask(() => fetchMarkdown());
    }
  }

  // 加载设置
  Future<void> loadSettings() async {
    final loadedSettings = await ReadingSettings.load();
    settings.value = loadedSettings;
    tempSettings.value = loadedSettings.copy();
  }

  // 保存设置
  Future<void> saveSettings() async {
    settings.value = tempSettings.value.copy();
    await settings.value.save();
    Get.snackbar('成功', '设置已保存');
  }

  // 重置设置为默认值
  void resetSettings() {
    tempSettings.value = ReadingSettings();
  }

  // 应用临时设置
  void applyTempSettings() {
    settings.value = tempSettings.value.copy();
  }

  Future<void> fetchMarkdown() async {
    if (loading.value) return;
    loading.value = true;
    try {
      // 先显示加载动画
      isReady.value = false;

      // 异步加载内容
      final content = await provider.getArticleMarkdown(articleId);

      // 处理内容
      String processedContent = content
          .replaceAll('http://', 'https://')
          .replaceFirst(RegExp(r'^---[\s\S]*?---\s*'), '')
          .replaceAll('。**', '**');

      if (processedContent.trim().isEmpty) {
        processedContent = '加载失败';
      }

      // 更新内容
      markdown.value = processedContent;

      // 延迟一帧再显示内容，让过渡更平滑
      await Future.delayed(const Duration(milliseconds: 50));
      isReady.value = true;
    } catch (e) {
      markdown.value = '加载失败';
      isReady.value = true;
    } finally {
      loading.value = false;
    }
  }

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

  // 获取Markdown配置
  MarkdownConfig getMarkdownConfig() {
    return MarkdownConfig(
      configs: [
        PConfig(
          textStyle: TextStyle(
            height: settings.value.lineHeight,
            fontSize: settings.value.bodyFontSize,
          ),
        ),
        H1Config(
          style: TextStyle(
            fontSize: settings.value.headingFontSize,
            fontWeight: FontWeight.bold,
          ),
        ),
        H2Config(
          style: TextStyle(
            fontSize: settings.value.headingFontSize - 4,
            fontWeight: FontWeight.bold,
          ),
        ),
        H3Config(
          style: TextStyle(
            fontSize: settings.value.headingFontSize - 6,
            fontWeight: FontWeight.bold,
          ),
        ),
        const CodeConfig(
          style: TextStyle(
            backgroundColor: Color(0xFFF5F5F5),
          ),
        ),
        const PreConfig(
          decoration: BoxDecoration(
            color: Color(0xFFF5F5F5),
            borderRadius: BorderRadius.all(Radius.circular(4)),
          ),
        ),
        ImgConfig(
          builder: (url, attributes) {
            return GestureDetector(
              onTap: () {
                Get.dialog(
                  Dialog(
                    backgroundColor: Colors.transparent,
                    insetPadding: const EdgeInsets.all(20),
                    child: Image.network(url),
                  ),
                );
              },
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: Image.network(
                    url,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        height: 100,
                        alignment: Alignment.center,
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[200],
                        height: 60,
                        alignment: Alignment.center,
                        child: const Icon(Icons.broken_image,
                            size: 30, color: Colors.grey),
                      );
                    },
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
