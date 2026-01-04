import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:markdown_widget/markdown_widget.dart';
import 'package:readaper/app/services/markdown_service.dart';
import 'package:readaper/app/modules/reading/widgets/reading_settings_dialog.dart';
import 'package:readaper/app/modules/reading/widgets/reading_appbar_popup.dart';
import '../controllers/reading_controller.dart';

/// 阅读页
///
/// - 展示文章 Markdown 内容
/// - 支持下拉刷新
/// - 支持收藏/归档/打开阅读设置
class ReadingView extends GetView<ReadingController> {
  const ReadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  /// 构建顶部栏（根据滚动状态显示/隐藏）
  PreferredSizeWidget _buildAppBar() {
    return PreferredSize(
      preferredSize:
          Size.fromHeight(controller.showAppBar.value ? kToolbarHeight : 0),
      child: Obx(() => AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, animation) => SizeTransition(
              sizeFactor: animation,
              axis: Axis.vertical,
              child: child,
            ),
            child: controller.showAppBar.value
                ? AppBar(
                    key: const ValueKey('appbar'),
                    actions: [
                      Obx(() => IconButton(
                            icon: controller.article.value.isMarked
                                ? const Icon(Icons.favorite)
                                : const Icon(Icons.favorite_border_outlined),
                            color: controller.article.value.isMarked
                                ? const Color(0xFFE53935)
                                : null,
                            onPressed: controller.clickFavorite,
                          )),
                      Obx(() => IconButton(
                            icon: controller.article.value.isArchived
                                ? const Icon(Icons.archive)
                                : const Icon(Icons.archive_outlined),
                            color: controller.article.value.isArchived
                                ? const Color(0xFFFF9800)
                                : null,
                            onPressed: controller.clickArchive,
                          )),
                      IconButton(
                          onPressed: () {
                            Get.bottomSheet(
                              Container(
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 20),
                                decoration: BoxDecoration(
                                  color: Theme.of(Get.context!)
                                      .scaffoldBackgroundColor,
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(15),
                                    topRight: Radius.circular(15),
                                  ),
                                ),
                                child: ReadingSettingsDialog(
                                    controller: controller),
                              ),
                              backgroundColor: Colors.transparent,
                              clipBehavior: Clip.antiAlias,
                              isScrollControlled: true,
                            );
                          },
                          icon: const Icon(Icons.text_format_outlined)),
                      Builder(
                        builder: (context) {
                          final theme = Theme.of(context);
                          final appBarTheme = AppBarTheme.of(context);
                          final baseColor = appBarTheme.backgroundColor ??
                              (theme.useMaterial3
                                  ? theme.colorScheme.surface
                                  : theme.primaryColor);
                          final elevation = appBarTheme.elevation ?? 0;

                          final backgroundColor = theme.useMaterial3
                              ? ElevationOverlay.applySurfaceTint(
                                  baseColor,
                                  appBarTheme.surfaceTintColor ??
                                      theme.colorScheme.surfaceTint,
                                  elevation,
                                )
                              : ElevationOverlay.applyOverlay(
                                  context,
                                  baseColor,
                                  elevation,
                                );
                          return ReadingAppBarPopup(
                            backgroundColor: backgroundColor,
                            onShare: controller.shareArticle,
                            onOpenSource: controller.openSource,
                          );
                        },
                      ),
                      const SizedBox(width: 10),
                    ],
                  )
                : const SizedBox.shrink(key: ValueKey('empty')),
          )),
    );
  }

  /// 构建主体内容（加载态/内容态）
  Widget _buildBody() {
    return Obx(() {
      if (controller.loading.value && !controller.isReady.value) {
        final theme = Theme.of(Get.context!);
        return Center(
          child: LoadingAnimationWidget.discreteCircle(
            color: theme.textTheme.bodyMedium?.color ?? theme.hintColor,
            size: 40,
          ),
        );
      }
      return RefreshIndicator(
        onRefresh: controller.fetchMarkdown,
        child: NotificationListener<ScrollNotification>(
          onNotification: (ScrollNotification notification) {
            if (notification is ScrollUpdateNotification &&
                notification.dragDetails != null) {
              controller.handleScroll(notification.metrics.pixels);
            }
            return false;
          },
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: controller.isReady.value
                ? SafeArea(
                    key: const ValueKey('content'),
                    top: controller.showAppBar.value,
                    bottom: false,
                    child: _buildMarkdown(),
                  )
                : const SizedBox.shrink(key: ValueKey('empty')),
          ),
        ),
      );
    });
  }

  /// 构建 Markdown 渲染区域
  ///
  /// - 根据设置配置 Markdown 渲染样式
  /// - 渲染 Markdown 内容
  Widget _buildMarkdown() {
    return Obx(() {
      final config =
          MarkdownService.configForSettings(controller.settings.value);
      final padding = EdgeInsets.fromLTRB(
        controller.settings.value.pagePadding,
        0,
        controller.settings.value.pagePadding,
        15,
      );

      return MarkdownWidget(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: padding,
        data: controller.markdown.value,
        config: config,
      );
    });
  }
}
