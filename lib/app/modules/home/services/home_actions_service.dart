// Package imports:
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';

// Project imports:
import 'package:readaper/app/modules/bookmark/bookmark.dart';
import '../controllers/home_list_controller.dart';

/// 首页操作服务
///
/// - 封装首页列表项的常用操作（已读/收藏/归档/删除/编辑标题/新增）
/// - 统一维护：列表数据与侧边栏统计数据的同步刷新
class HomeActionsService {
  final HomeListController list;
  final BookmarkRepository repository;
  final RxString currentSidebarKey;
  final Rx<BookmarkCounts> counts;
  final Future<void> Function() refreshCounts;

  HomeActionsService({
    required this.list,
    required this.repository,
    required this.currentSidebarKey,
    required this.counts,
    required this.refreshCounts,
  });

  /// 获取书签 id（做 trim 后返回）
  String _bookmarkId(Bookmark bookmark) => (bookmark.id ?? '').trim();

  /// 更新列表中的单个项，或根据条件将其从列表移除
  void _updateOrRemoveItem({
    required Bookmark bookmark,
    required bool shouldRemove,
    required Bookmark Function(Bookmark current) update,
  }) {
    if (shouldRemove) {
      list.items.removeWhere((b) => b.id == bookmark.id);
      list.items.refresh();
      return;
    }

    final index = list.items.indexWhere((b) => b.id == bookmark.id);
    if (index != -1) {
      list.items[index] = update(list.items[index]);
      list.items.refresh();
    }
  }

  /// 刷新列表与侧边栏统计
  Future<void> refreshListAndCounts({
    required Map<String, dynamic> filterParams,
  }) async {
    await list.fetch(
      refresh: true,
      baseParams: filterParams,
      showLoading: false,
    );
    await refreshCounts();
  }

  /// 若当前项未读，则标记为已读并刷新列表与统计
  Future<void> markAsReadIfNeeded({
    required Bookmark bookmark,
    required Map<String, dynamic> filterParams,
  }) async {
    final id = _bookmarkId(bookmark);
    if (id.isEmpty) return;

    final isRead = bookmark.readProgress >= 100;
    if (isRead) return;

    const nextProgress = 100;
    counts.value =
        await repository.updateReadProgress(id, readProgress: nextProgress);
    await refreshListAndCounts(filterParams: filterParams);
  }

  /// 切换已读/未读状态，并刷新列表与统计
  Future<void> toggleReadStatus({
    required Bookmark bookmark,
    required Map<String, dynamic> filterParams,
  }) async {
    final id = _bookmarkId(bookmark);
    if (id.isEmpty) return;

    final isRead = bookmark.readProgress >= 100;
    final nextProgress = isRead ? 0 : 100;

    counts.value =
        await repository.updateReadProgress(id, readProgress: nextProgress);
    await refreshListAndCounts(filterParams: filterParams);
    Get.snackbar('success'.tr, 'success'.tr);
  }

  /// 收藏/取消收藏
  Future<void> markBookmark({
    required Bookmark bookmark,
    required bool value,
  }) async {
    final id = _bookmarkId(bookmark);
    if (id.isEmpty) return;

    counts.value = await repository.toggleMarked(id, value: value);

    _updateOrRemoveItem(
      bookmark: bookmark,
      shouldRemove: currentSidebarKey.value == 'favorite' && !value,
      update: (current) => current.copyWith(isMarked: value),
    );

    Get.snackbar('success'.tr, value ? 'favorited'.tr : 'unfavorited'.tr);
  }

  /// 归档/取消归档
  Future<void> archiveBookmark({
    required Bookmark bookmark,
    required bool value,
  }) async {
    final id = _bookmarkId(bookmark);
    if (id.isEmpty) return;

    counts.value = await repository.toggleArchived(id, value: value);

    _updateOrRemoveItem(
      bookmark: bookmark,
      shouldRemove: currentSidebarKey.value == 'archive' && !value,
      update: (current) => current.copyWith(isArchived: value),
    );

    Get.snackbar('success'.tr, value ? 'archived'.tr : 'unarchived'.tr);
  }

  /// 删除书签
  Future<void> deleteBookmark({required Bookmark bookmark}) async {
    final id = _bookmarkId(bookmark);
    if (id.isEmpty) return;

    counts.value = await repository.deleteBookmark(id);
    _updateOrRemoveItem(
      bookmark: bookmark,
      shouldRemove: true,
      update: (current) => current,
    );

    Get.snackbar('success'.tr, 'deleted'.tr);
  }

  /// 更新书签标题，并刷新列表与统计
  Future<void> updateTitle({
    required String id,
    required String title,
    required Map<String, dynamic> filterParams,
  }) async {
    EasyLoading.show();
    try {
      await repository.updateTitle(id, title: title);
      await refreshListAndCounts(filterParams: filterParams);
      Get.snackbar('success'.tr, 'success'.tr);
    } finally {
      EasyLoading.dismiss();
    }
  }

  /// 新增书签（成功后切换到 all 并刷新列表与统计）
  Future<bool> addBookmark({
    required String url,
    String? title,
    required Map<String, dynamic> filterParams,
    required void Function() setSidebarAll,
  }) async {
    final trimmedUrl = url.trim();
    if (trimmedUrl.isEmpty) {
      Get.snackbar('failed'.tr, 'fillAllFields'.tr);
      return false;
    }

    EasyLoading.show();
    try {
      await repository.addBookmark(
        url: trimmedUrl,
        title: title,
        created: DateTime.now().toUtc(),
      );

      await Future.delayed(const Duration(seconds: 2));
      Get.snackbar('success'.tr, 'success'.tr);

      setSidebarAll();
      await refreshListAndCounts(filterParams: filterParams);
      return true;
    } finally {
      EasyLoading.dismiss();
    }
  }
}
