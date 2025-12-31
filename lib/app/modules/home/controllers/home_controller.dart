import 'package:get/get.dart';
import 'home_list_controller.dart';
import '../controllers/sidebar_gesture_controller.dart';
import '../providers/bookmark_provider.dart';
import '../models/bookmark.dart';
import '../models/bookmark_counts.dart';
import 'package:flutter/material.dart';
import '../../../network/api_client.dart';
import '../../../services/bookmark_db_service.dart';
import '../../../services/bookmark_sync_service.dart';

/// 首页控制器
///
/// - 作为首页编排器：协调列表分页、侧边栏筛选、侧边栏手势、本地统计与同步
class HomeController extends GetxController {
  final BookmarkProvider provider;
  HomeController(this.provider);

  final BookmarkDbService _db = BookmarkDbService();

  late final SidebarGestureController _sidebar;
  late final HomeListController _list;

  /// 当前侧边栏选中项 key（用于顶部标题显示/筛选，如 all/archive/video）
  final currentSidebarKey = 'all'.obs;

  /// 侧边栏数量统计（来自本地数据库聚合）
  final counts = const BookmarkCounts().obs;

  /// 筛选 key => 请求参数映射（不包含分页/排序参数）
  static const Map<String, Map<String, dynamic>> _filterParamsMap = {
    'all': {},
    'unread': {
      'read_status': ['unread']
    },
    'archive': {'is_archived': true},
    'favorite': {'is_marked': true},
    'video': {
      'type': ['video']
    },
  };

  /// 当前筛选参数（不包含分页/排序参数）
  Map<String, dynamic> buildFilterParams() {
    return _filterParamsMap[currentSidebarKey.value] ?? const {};
  }

  // =========================
  // 对外暴露（给 View 使用）
  // =========================

  RxDouble get sidebarOpenRatio => _sidebar.openRatio;
  RxBool get isSidebarDragging => _sidebar.isDragging;
  bool get isSidebarOpen => _sidebar.isOpen;

  void openSidebar() => _sidebar.open();
  void closeSidebar() => _sidebar.close();
  void toggleSidebar() => _sidebar.toggle();
  void onSidebarHorizontalDragStart() => _sidebar.onHorizontalDragStart();
  void onSidebarHorizontalDragUpdate({
    required double deltaDx,
    required double sidebarWidth,
  }) =>
      _sidebar.onHorizontalDragUpdate(
          deltaDx: deltaDx, sidebarWidth: sidebarWidth);
  void onSidebarHorizontalDragEnd({required double velocityDx}) =>
      _sidebar.onHorizontalDragEnd(velocityDx: velocityDx);

  RxList<Bookmark> get articles => _list.items;
  RxBool get loading => _list.loading;
  RxBool get isLoadingMore => _list.isLoadingMore;
  ScrollController get scrollController => _list.scrollController;

  /// 获取侧边栏数量（使用映射表，减少 switch）
  int getCountByKey(String key) {
    final val = counts.value;
    final map = <String, int>{
      'all': val.all,
      'unread': val.unread,
      'archive': val.archived,
      'favorite': val.favorite,
      'video': val.video,
    };
    return map[key] ?? 0;
  }

  void _showError(Object e) {
    if (e is ApiException) {
      Get.snackbar('failed'.tr, e.message);
      return;
    }
    Get.snackbar('failed'.tr, e.toString());
  }

  final sidebarItems = [
    {'icon': Icons.all_inbox, 'title': 'all'},
    {'icon': Icons.mark_unread_chat_alt_outlined, 'title': 'unread'},
    {'icon': Icons.archive_outlined, 'title': 'archive'},
    {'icon': Icons.favorite_border, 'title': 'favorite'},
    {'icon': Icons.video_library_outlined, 'title': 'video'},
  ];

  @override
  void onInit() {
    super.onInit();

    _sidebar = Get.find<SidebarGestureController>();
    _list = Get.find<HomeListController>();

    // 首次加载
    fetchArticles(refresh: true);

    // 首帧后刷新统计与全量同步（避免阻塞首屏）
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await refreshCounts();
      await BookmarkSyncService().syncNow();
      await refreshCounts();
    });
  }

  /// 刷新侧边栏分类数量
  Future<void> refreshCounts() async {
    try {
      counts.value = await _db.getCounts();
    } catch (_) {
      // 统计失败时不影响主流程
    }
  }

  /// 获取书签列表
  ///
  /// - refresh=true：下拉刷新，重置 offset
  /// - refresh=false：分页加载更多
  Future<void> fetchArticles({bool refresh = false}) async {
    try {
      if (refresh) {
        await _list.refreshList(baseParams: buildFilterParams());
      } else {
        await _list.fetch(refresh: false, baseParams: buildFilterParams());
      }
      await refreshCounts();
    } catch (_) {
      // 交由各子 controller 处理错误提示
    }
  }

  Future<void> markBookmark(Bookmark bookmark, bool value) async {
    try {
      await provider.updateBookmarkStatus(bookmark.id ?? '', isMarked: value);

      // 如果在收藏列表中取消收藏，直接移除
      if (currentSidebarKey.value == 'favorite' && !value) {
        _list.items.removeWhere((b) => b.id == bookmark.id);
      } else {
        // 否则更新状态
        final index = _list.items.indexWhere((b) => b.id == bookmark.id);
        if (index != -1) {
          _list.items[index] = _list.items[index].copyWith(isMarked: value);
        }
      }
      _list.items.refresh();
      Get.snackbar('success'.tr, value ? 'favorited'.tr : 'unfavorited'.tr);

      final id = bookmark.id;
      if (id != null && id.isNotEmpty) {
        final newCounts =
            await _db.updateBookmarkAndGetCounts(id, isMarked: value);
        counts.value = newCounts;
      }
    } catch (e) {
      _showError(e);
    }
  }

  /// 归档/取消归档
  Future<void> archiveBookmark(Bookmark bookmark, bool value) async {
    try {
      await provider.updateBookmarkStatus(bookmark.id ?? '', isArchived: value);

      // 如果在归档列表中取消归档，直接移除
      if (currentSidebarKey.value == 'archive' && !value) {
        _list.items.removeWhere((b) => b.id == bookmark.id);
      } else {
        // 否则更新状态
        final index = _list.items.indexWhere((b) => b.id == bookmark.id);
        if (index != -1) {
          _list.items[index] = _list.items[index].copyWith(isArchived: value);
        }
      }
      _list.items.refresh();
      Get.snackbar('success'.tr, value ? 'archived'.tr : 'unarchived'.tr);

      final id = bookmark.id;
      if (id != null && id.isNotEmpty) {
        final newCounts =
            await _db.updateBookmarkAndGetCounts(id, isArchived: value);
        counts.value = newCounts;
      }
    } catch (e) {
      _showError(e);
    }
  }

  /// 删除书签
  Future<void> deleteBookmark(Bookmark bookmark) async {
    try {
      await provider.deleteBookmark(bookmark.id ?? '');
      _list.items.removeWhere((b) => b.id == bookmark.id);
      _list.items.refresh();
      Get.snackbar('success'.tr, 'deleted'.tr);

      final id = bookmark.id;
      if (id != null && id.isNotEmpty) {
        final newCounts = await _db.deleteBookmarkAndGetCounts(id);
        counts.value = newCounts;
      }
    } catch (e) {
      _showError(e);
    }
  }

  /// 加载下一页
  void loadMore() => fetchArticles(refresh: false);

  /// 侧边栏点击筛选逻辑
  void onSidebarTap(int index, String title) {
    closeSidebar();

    // 同步当前侧边栏选中项（用于顶部标题展示/筛选）
    currentSidebarKey.value = sidebarItems[index]['title'] as String;
    fetchArticles(refresh: true);
  }
}
