import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';

import '../../../network/api_client.dart';
import '../../../services/bookmark_db_service.dart';
import '../models/bookmark.dart';
import '../providers/bookmark_provider.dart';

/// 书签列表控制器（分页）
///
/// - 负责列表加载/刷新/分页
/// - 负责滚动触底自动加载更多
/// - 不负责“筛选规则”，由外部传入 queryParameters
class HomeListController extends GetxController {
  HomeListController(this._provider);

  final BookmarkProvider _provider;
  final BookmarkDbService _db = BookmarkDbService();

  // 分页大小
  static const int _pageLimit = 10;
  // 触底加载更多阈值（距离底部多少像素触发）
  static const double _loadMoreThreshold = 100;

  final items = <Bookmark>[].obs;
  final loading = false.obs;
  final isLoadingMore = false.obs;

  final ScrollController scrollController = ScrollController();

  int _offset = 0;
  bool _hasMore = true;

  @override
  void onInit() {
    super.onInit();
    scrollController.addListener(_handleScroll);
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

  void _showError(Object e) {
    if (e is ApiException) {
      Get.snackbar('failed'.tr, e.message);
      return;
    }
    Get.snackbar('failed'.tr, e.toString());
  }

  Future<void> refreshList({required Map<String, dynamic> baseParams}) async {
    await fetch(refresh: true, baseParams: baseParams);
  }

  void loadMore({Map<String, dynamic>? baseParams}) {
    fetch(refresh: false, baseParams: baseParams ?? const {});
  }

  /// 拉取列表
  ///
  /// - baseParams：外部传入的筛选参数
  Future<void> fetch({
    required bool refresh,
    required Map<String, dynamic> baseParams,
    bool showLoading = true,
  }) async {
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
      if (showLoading) {
        EasyLoading.show();
      }

      final params = <String, dynamic>{
        'limit': _pageLimit,
        'offset': _offset,
        'sort': '-created',
        ...baseParams,
      };

      final list = await _provider.getBookmarksWithParams(params);

      await _db.upsertBookmarks(list);

      if (refresh) {
        items.assignAll(list);
      } else {
        items.addAll(list);
      }

      if (list.length < _pageLimit) {
        _hasMore = false;
      } else {
        _offset += _pageLimit;
      }
    } catch (e) {
      _showError(e);
    } finally {
      if (showLoading) {
        EasyLoading.dismiss();
      }
      loading.value = false;
      isLoadingMore.value = false;
    }
  }
}
