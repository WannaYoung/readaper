import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import '../../../data/providers/bookmark_provider.dart';
import '../../../data/models/bookmark.dart';
import 'package:flutter/material.dart';

class HomeController extends GetxController {
  final BookmarkProvider provider;
  HomeController(this.provider);

  final articles = <Bookmark>[].obs;
  final loading = false.obs;
  int _offset = 0;
  final int _limit = 10;
  bool _hasMore = true;
  final isLoadingMore = false.obs;
  final drawerOpen = false.obs;
  final isSidebarOpen = false.obs;

  final sidebarItems = [
    {'icon': Icons.all_inbox, 'title': '全部'},
    {'icon': Icons.mark_unread_chat_alt_outlined, 'title': '未读'},
    {'icon': Icons.archive_outlined, 'title': '归档'},
    {'icon': Icons.favorite_border, 'title': '收藏'},
    {'icon': Icons.video_library_outlined, 'title': '视频'},
  ];

  // 筛选条件
  List<String>? filterIsRead;
  bool? filterIsArchived;
  bool? filterIsMarked;
  List<String>? filterType;

  @override
  void onInit() {
    super.onInit();
    fetchArticles();
  }

  Future<void> fetchArticles({bool refresh = false}) async {
    if (loading.value || isLoadingMore.value) return;
    if (refresh) {
      _offset = 0;
      _hasMore = true;
    }
    if (!_hasMore) return;
    if (refresh) {
      loading.value = true;
    } else {
      isLoadingMore.value = true;
    }
    try {
      EasyLoading.show();
      // 构建筛选参数
      Map<String, dynamic> params = {
        'limit': _limit,
        'offset': _offset,
        'sort': '-created',
      };
      if (filterIsRead != null) params['read_status'] = filterIsRead;
      if (filterIsArchived != null) params['is_archived'] = filterIsArchived;
      if (filterIsMarked != null) params['is_marked'] = filterIsMarked;
      if (filterType != null) params['type'] = filterType;
      final newList = await provider.getBookmarksWithParams(params);
      if (refresh) {
        articles.assignAll(newList);
      } else {
        articles.addAll(newList);
      }
      if (newList.length < _limit) {
        _hasMore = false;
      } else {
        _offset += _limit;
      }
    } catch (e) {
      // 错误处理
    } finally {
      EasyLoading.dismiss();
      loading.value = false;
      isLoadingMore.value = false;
    }
  }

  Future<void> markBookmark(Bookmark bookmark, bool value) async {
    try {
      await provider.updateBookmarkStatus(bookmark.id ?? '', isMarked: value);

      // 如果在收藏列表中取消收藏，直接移除
      if (filterIsMarked == true && !value) {
        articles.removeWhere((b) => b.id == bookmark.id);
      } else {
        // 否则更新状态
        final index = articles.indexWhere((b) => b.id == bookmark.id);
        if (index != -1) {
          articles[index] = articles[index].copyWith(isMarked: value);
        }
      }
      articles.refresh();
      Get.snackbar('成功'.tr, value ? '已收藏'.tr : '已取消收藏'.tr);
    } catch (e) {
      Get.snackbar('失败'.tr, '操作失败'.tr);
    }
  }

  Future<void> archiveBookmark(Bookmark bookmark, bool value) async {
    try {
      await provider.updateBookmarkStatus(bookmark.id ?? '', isArchived: value);

      // 如果在归档列表中取消归档，直接移除
      if (filterIsArchived == true && !value) {
        articles.removeWhere((b) => b.id == bookmark.id);
      } else {
        // 否则更新状态
        final index = articles.indexWhere((b) => b.id == bookmark.id);
        if (index != -1) {
          articles[index] = articles[index].copyWith(isArchived: value);
        }
      }
      articles.refresh();
      Get.snackbar('成功'.tr, value ? '已归档'.tr : '已取消归档'.tr);
    } catch (e) {
      Get.snackbar('失败'.tr, '操作失败'.tr);
    }
  }

  Future<void> deleteBookmark(Bookmark bookmark) async {
    try {
      await provider.deleteBookmark(bookmark.id ?? '');
      articles.removeWhere((b) => b.id == bookmark.id);
      articles.refresh();
      Get.snackbar('成功'.tr, '已删除'.tr);
    } catch (e) {
      Get.snackbar('失败'.tr, '删除失败'.tr);
    }
  }

  void loadMore() => fetchArticles();

  // 侧边栏点击筛选逻辑
  void onSidebarTap(int index, String title) {
    isSidebarOpen.value = false;
    // 重置筛选条件
    filterIsRead = null;
    filterIsArchived = null;
    filterIsMarked = null;
    filterType = null;
    switch (index) {
      case 0: // 全部
        // 不需要筛选
        break;
      case 1: // 未读
        filterIsRead = ['unread'];
        break;
      case 2: // 归档
        filterIsArchived = true;
        break;
      case 3: // 收藏
        filterIsMarked = true;
        break;
      case 4: // 视频
        filterType = ['video'];
        break;
    }
    fetchArticles(refresh: true);
  }
}
