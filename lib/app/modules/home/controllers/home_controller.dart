import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import '../providers/bookmark_provider.dart';
import '../models/bookmark.dart';
import '../models/bookmark_counts.dart';
import 'package:flutter/material.dart';
import '../../../network/api_client.dart';
import '../../../services/bookmark_db_service.dart';

/// 首页控制器
///
/// - 负责书签列表加载/刷新/分页
/// - 负责侧边栏筛选逻辑
/// - 负责列表滚动触底时自动加载更多
class HomeController extends GetxController {
  final BookmarkProvider provider;
  HomeController(this.provider);

  // 分页大小
  static const int _pageLimit = 10;
  // 触底加载更多阈值（距离底部多少像素触发）
  static const double _loadMoreThreshold = 100;

  final articles = <Bookmark>[].obs;
  final loading = false.obs;
  final ScrollController scrollController = ScrollController();
  int _offset = 0;
  bool _hasMore = true;
  final isLoadingMore = false.obs;
  final drawerOpen = false.obs;
  final isSidebarOpen = false.obs;

  final BookmarkDbService _db = BookmarkDbService();
  final counts = const BookmarkCounts().obs;

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

  // 筛选条件
  List<String>? filterIsRead;
  bool? filterIsArchived;
  bool? filterIsMarked;
  List<String>? filterType;

  @override
  void onInit() {
    super.onInit();
    // 监听滚动，触底自动加载更多
    scrollController.addListener(_handleScroll);
    fetchArticles();

    // 首帧后启动本地统计刷新与全量同步（避免阻塞页面首屏渲染）
    WidgetsBinding.instance.addPostFrameCallback((_) {
      refreshCounts();
      syncAllBookmarks();
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

  /// 全量同步书签到本地数据库
  ///
  /// - 由于后端没有提供统计接口，本地统计需要尽可能全量的数据
  /// - 使用分页拉取，避免一次性请求过大
  Future<void> syncAllBookmarks() async {
    const int limit = 50;
    int offset = 0;
    try {
      while (true) {
        final params = <String, dynamic>{
          'limit': limit,
          'offset': offset,
          'sort': '-created',
        };
        final list = await provider.getBookmarksWithParams(params);
        if (list.isEmpty) break;
        await _db.upsertBookmarks(list);
        offset += limit;
        if (list.length < limit) break;
      }
    } catch (_) {
      // 同步失败不影响当前页面展示
    } finally {
      await refreshCounts();
    }
  }

  int getCountByKey(String key) {
    final val = counts.value;
    switch (key) {
      case 'all':
        return val.all;
      case 'unread':
        return val.unread;
      case 'archive':
        return val.archived;
      case 'favorite':
        return val.favorite;
      case 'video':
        return val.video;
      default:
        return 0;
    }
  }

  @override
  void onClose() {
    scrollController.removeListener(_handleScroll);
    scrollController.dispose();
    super.onClose();
  }

  void _handleScroll() {
    if (scrollController.position.pixels >=
        scrollController.position.maxScrollExtent - _loadMoreThreshold) {
      if (!isLoadingMore.value && !loading.value) {
        loadMore();
      }
    }
  }

  /// 获取书签列表
  ///
  /// - refresh=true：下拉刷新，重置 offset
  /// - refresh=false：分页加载更多
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
        'limit': _pageLimit,
        'offset': _offset,
        'sort': '-created',
      };
      if (filterIsRead != null) params['read_status'] = filterIsRead;
      if (filterIsArchived != null) params['is_archived'] = filterIsArchived;
      if (filterIsMarked != null) params['is_marked'] = filterIsMarked;
      if (filterType != null) params['type'] = filterType;
      final newList = await provider.getBookmarksWithParams(params);
      // 写入本地数据库，用于侧边栏数量统计
      await _db.upsertBookmarks(newList);
      if (refresh) {
        articles.assignAll(newList);
      } else {
        articles.addAll(newList);
      }
      if (newList.length < _pageLimit) {
        _hasMore = false;
      } else {
        _offset += _pageLimit;
      }
      await refreshCounts();
    } catch (e) {
      _showError(e);
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
      Get.snackbar('success'.tr, value ? 'favorited'.tr : 'unfavorited'.tr);

      final id = bookmark.id;
      if (id != null && id.isNotEmpty) {
        await _db.updateBookmark(id, isMarked: value);
        await refreshCounts();
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
      Get.snackbar('success'.tr, value ? 'archived'.tr : 'unarchived'.tr);

      final id = bookmark.id;
      if (id != null && id.isNotEmpty) {
        await _db.updateBookmark(id, isArchived: value);
        await refreshCounts();
      }
    } catch (e) {
      _showError(e);
    }
  }

  /// 删除书签
  Future<void> deleteBookmark(Bookmark bookmark) async {
    try {
      await provider.deleteBookmark(bookmark.id ?? '');
      articles.removeWhere((b) => b.id == bookmark.id);
      articles.refresh();
      Get.snackbar('success'.tr, 'deleted'.tr);

      final id = bookmark.id;
      if (id != null && id.isNotEmpty) {
        await _db.deleteBookmark(id);
        await refreshCounts();
      }
    } catch (e) {
      _showError(e);
    }
  }

  /// 加载下一页
  void loadMore() => fetchArticles();

  /// 侧边栏点击筛选逻辑
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
