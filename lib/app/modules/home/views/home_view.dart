import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:pie_menu/pie_menu.dart';
import 'package:readaper/app/routes/app_pages.dart';
import 'package:readaper/app/shared/widgets/alert_dialog.dart';
import '../controllers/home_controller.dart';
import '../models/home_layout_settings.dart';
import '../widgets/article_card.dart';
import '../widgets/home_layout_dialog.dart';

/// 首页
///
/// - 展示书签列表
/// - 支持下拉刷新与触底加载更多
/// - 支持侧边栏筛选
class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final sidebarWidth = screenWidth * 0.7;

    return PieCanvas(
      theme: PieTheme(
        brightness: theme.brightness,
      ),
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: _buildAppBar(theme),
        floatingActionButton: FloatingActionButton(
          onPressed: () => controller.showAddBookmarkDialog(),
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: theme.colorScheme.onPrimary,
          shape: const CircleBorder(),
          child: const Icon(Icons.add),
        ),
        body: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onHorizontalDragStart: (_) =>
              controller.onSidebarHorizontalDragStart(),
          onHorizontalDragUpdate: (details) =>
              controller.onSidebarHorizontalDragUpdate(
            deltaDx: details.delta.dx,
            sidebarWidth: sidebarWidth,
          ),
          onHorizontalDragEnd: (details) =>
              controller.onSidebarHorizontalDragEnd(
            velocityDx: details.velocity.pixelsPerSecond.dx,
          ),
          child: Stack(
            children: [
              _buildArticleList(),
              _buildSidebarMask(context),
              _buildSidebar(sidebarWidth, context),
            ],
          ),
        ),
      ),
    );
  }

  /// 顶部栏
  PreferredSizeWidget _buildAppBar(ThemeData theme) {
    return AppBar(
      titleSpacing: 5,
      leading: Obx(() => IconButton(
            icon: Icon(
              controller.isSidebarOpen ? Icons.close : Icons.menu,
              color: theme.iconTheme.color,
            ),
            onPressed: controller.toggleSidebar,
          )),
      title: Obx(() => Text(
            controller.currentSidebarKey.value.tr,
            style: theme.textTheme.titleLarge?.copyWith(
              color: theme.textTheme.titleLarge?.color ?? theme.primaryColor,
              fontWeight: FontWeight.bold,
              fontSize: 23,
            ),
          )),
      centerTitle: false,
      iconTheme: theme.iconTheme,
      actions: [
        IconButton(
          icon: Icon(Icons.dashboard_customize, color: theme.iconTheme.color),
          onPressed: () {
            controller.tempHomeLayoutSettings.value =
                controller.homeLayoutSettings.value.copy();
            Get.bottomSheet(
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: Theme.of(Get.context!).scaffoldBackgroundColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(15),
                    topRight: Radius.circular(15),
                  ),
                ),
                child: HomeLayoutDialog(controller: controller),
              ),
              backgroundColor: Colors.transparent,
              clipBehavior: Clip.antiAlias,
              isScrollControlled: true,
            );
          },
        ),
        IconButton(
          icon: Icon(Icons.more_vert, color: theme.iconTheme.color),
          onPressed: () => Get.toNamed(Routes.SETTING),
        ),
      ],
    );
  }

  /// 文章列表
  Widget _buildArticleList() {
    return Obx(() {
      if (controller.loading.value && controller.articles.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }

      final settings = controller.homeLayoutSettings.value;
      final isWaterfall =
          settings.layoutType == HomeLayoutSettings.layoutTypeWaterfall;

      return RefreshIndicator(
        onRefresh: () => controller.fetchArticles(refresh: true),
        child: isWaterfall
            ? MasonryGridView.count(
                controller: controller.scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 20),
                crossAxisCount: 2,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                itemCount: controller.articles.length + 1,
                itemBuilder: (context, index) {
                  if (index == controller.articles.length) {
                    if (controller.isLoadingMore.value) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Center(
                          child: LoadingAnimationWidget.discreteCircle(
                            color: const Color.fromARGB(255, 67, 67, 67),
                            size: 30,
                          ),
                        ),
                      );
                    } else {
                      return const SizedBox.shrink();
                    }
                  }
                  final bookmark = controller.articles[index];
                  return ArticleGridCard(
                    bookmark: bookmark,
                    titleFontSize: settings.titleFontSize,
                    showPreviewImage: settings.showPreviewImage,
                    showSummary: settings.showSummary,
                    onTap: () async {
                      await controller.markAsReadIfNeeded(bookmark);
                      Get.toNamed(Routes.READING,
                          arguments: {'bookmark': bookmark});
                    },
                    onPieAction: (actionIndex) =>
                        _onPieAction(actionIndex, bookmark, context),
                  );
                },
              )
            : ListView.separated(
                controller: controller.scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.only(top: 8, bottom: 20),
                itemCount: controller.articles.length + 1,
                separatorBuilder: (_, __) => Divider(
                  color: Color.fromARGB(80, 180, 180, 180),
                  height: 1,
                  thickness: 0.8,
                  indent: 20,
                  endIndent: 20,
                ),
                itemBuilder: (context, index) {
                  if (index == controller.articles.length) {
                    if (controller.isLoadingMore.value) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Center(
                          child: LoadingAnimationWidget.discreteCircle(
                            color: const Color.fromARGB(255, 67, 67, 67),
                            size: 30,
                          ),
                        ),
                      );
                    } else {
                      return const SizedBox.shrink();
                    }
                  }
                  final bookmark = controller.articles[index];
                  return ArticleListCard(
                    bookmark: bookmark,
                    titleFontSize: settings.titleFontSize,
                    showPreviewImage: settings.showPreviewImage,
                    showSummary: settings.showSummary,
                    onTap: () async {
                      await controller.markAsReadIfNeeded(bookmark);
                      Get.toNamed(Routes.READING,
                          arguments: {'bookmark': bookmark});
                    },
                    onPieAction: (actionIndex) =>
                        _onPieAction(actionIndex, bookmark, context),
                  );
                },
              ),
      );
    });
  }

  /// PieMenu 操作
  void _onPieAction(int actionIndex, bookmark, BuildContext context) {
    switch (actionIndex) {
      case 0:
        controller.editBookmarkTitle(bookmark);
        break;
      case 1:
        controller.toggleReadStatus(bookmark);
        break;
      case 2:
        controller.markBookmark(bookmark, !bookmark.isMarked);
        break;
      case 3:
        controller.archiveBookmark(bookmark, !bookmark.isArchived);
        break;
      case 4:
        _showDeleteConfirmDialog(context, bookmark);
        break;
    }
  }

  void _showDeleteConfirmDialog(BuildContext context, bookmark) {
    showDialog(
      context: context,
      builder: (context) => CustomAlertDialog(
        title: 'confirmDelete'.tr,
        description: 'deleteIrreversible'.tr,
        confirmButtonText: 'delete'.tr,
        confirmButtonColor: const Color.fromARGB(255, 239, 72, 60),
        onConfirm: () => controller.deleteBookmark(bookmark),
      ),
    );
  }

  /// 侧边栏遮罩
  Widget _buildSidebarMask(BuildContext context) {
    final theme = Theme.of(context);
    return Obx(() {
      final ratio = controller.sidebarOpenRatio.value;
      return IgnorePointer(
        ignoring: ratio <= 0,
        child: GestureDetector(
          onTap: controller.closeSidebar,
          child: Container(
            color: theme.colorScheme.onSurface.withAlpha((70 * ratio).round()),
            width: double.infinity,
            height: double.infinity,
          ),
        ),
      );
    });
  }

  /// 侧边栏
  Widget _buildSidebar(double sidebarWidth, BuildContext context) {
    final theme = Theme.of(context);
    return Obx(() {
      final ratio = controller.sidebarOpenRatio.value;
      return AnimatedPositioned(
        duration: controller.isSidebarDragging.value
            ? Duration.zero
            : const Duration(milliseconds: 300),
        curve: Curves.ease,
        top: 0,
        left: -sidebarWidth * (1 - ratio),
        width: sidebarWidth,
        height: MediaQuery.of(context).size.height,
        child: Material(
          elevation: 8,
          color: theme.appBarTheme.backgroundColor ??
              theme.scaffoldBackgroundColor,
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              for (var i = 0; i < controller.sidebarItems.length; i++) ...[
                _sidebarTile(
                  i,
                  controller.sidebarItems[i]['icon'] as IconData,
                  (controller.sidebarItems[i]['title'] as String).tr,
                  controller.getCountByKey(
                      controller.sidebarItems[i]['title'] as String),
                  controller.onSidebarTap,
                ),
                if (i != controller.sidebarItems.length - 1)
                  Divider(color: theme.dividerColor.withAlpha(80)),
              ],
            ],
          ),
        ),
      );
    });
  }

  /// 侧边栏单项
  Widget _sidebarTile(int index, IconData icon, String text, int count,
      Function(int, String) onTap) {
    return SizedBox(
      height: 50,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onTap(index, text),
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          child: Row(
            children: [
              const SizedBox(width: 20),
              Icon(icon),
              const SizedBox(width: 20),
              Expanded(
                child: Text(
                  text,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
              if (count > 0)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(40, 0, 0, 0),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    count.toString(),
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              const SizedBox(width: 12),
            ],
          ),
        ),
      ),
    );
  }
}
