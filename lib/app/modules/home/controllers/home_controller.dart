// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

// Project imports:
import 'package:readaper/app/modules/bookmark/bookmark.dart';
import '../../../services/share_intent_service.dart';
import '../../login/services/auth_storage_service.dart';
import '../constants/home_constants.dart';
import '../models/home_layout_settings.dart';
import '../services/services.dart';
import 'home_list_controller.dart';

/// 首页控制器
///
/// - 作为首页编排器：协调列表分页、侧边栏筛选、侧边栏手势、本地统计与同步
class HomeController extends GetxController {
  final BookmarkProvider provider;
  final BookmarkRepository repository;
  HomeController(this.provider, [BookmarkRepository? repository])
      : repository = repository ?? Get.find<BookmarkRepository>();
  final AuthStorageService _authStorage = Get.find<AuthStorageService>();

  late final HomeListController _list;

  late final HomeDialogsService _dialogs;
  late final HomeActionsService _actions;

  late final HomeLayoutService _layout;
  late final HomeSidebarService _sidebarService;
  late final HomeErrorHandler _error;

  /// 当前侧边栏选中项 key（用于顶部标题显示/筛选，如 all/archive/video）
  final currentSidebarKey = 'all'.obs;

  /// 侧边栏数量统计（来自本地数据库聚合）
  final counts = const BookmarkCounts().obs;

  final RxBool _isAddBookmarkDialogOpen = false.obs;

  /// 当前生效的首页布局设置
  Rx<HomeLayoutSettings> get homeLayoutSettings => _layout.homeLayoutSettings;

  /// 临时首页布局设置（用于弹窗实时预览）
  Rx<HomeLayoutSettings> get tempHomeLayoutSettings =>
      _layout.tempHomeLayoutSettings;

  /// 加载首页布局设置
  Future<void> loadHomeLayoutSettings() async {
    await _layout.load();
  }

  /// 保存首页布局设置
  Future<void> saveHomeLayoutSettings() async {
    await _layout.save();
  }

  /// 应用临时布局设置（用于实时预览）
  void applyTempHomeLayoutSettings() {
    _layout.applyTemp();
  }

  /// 重置临时布局设置为默认值
  void resetHomeLayoutSettings() {
    _layout.resetTemp();
  }

  /// 当前筛选参数（不包含分页/排序参数）
  Map<String, dynamic> buildFilterParams() {
    return HomeConstants.filterParamsMap[currentSidebarKey.value] ?? const {};
  }

  /// 对外暴露（给 View 使用）

  /// 侧边栏打开比例（0=关闭，1=打开）
  RxDouble get sidebarOpenRatio => _sidebarService.openRatio;

  /// 是否正在拖拽侧边栏
  RxBool get isSidebarDragging => _sidebarService.isDragging;

  /// 侧边栏是否处于打开状态
  bool get isSidebarOpen => _sidebarService.isOpen;

  /// 打开侧边栏
  void openSidebar() => _sidebarService.open();

  /// 关闭侧边栏
  void closeSidebar() => _sidebarService.close();

  /// 切换侧边栏开关
  void toggleSidebar() => _sidebarService.toggle();

  /// 侧边栏手势开始
  void onSidebarHorizontalDragStart() =>
      _sidebarService.onHorizontalDragStart();
  void onSidebarHorizontalDragUpdate({
    required double deltaDx,
    required double sidebarWidth,
  }) =>
      _sidebarService.onHorizontalDragUpdate(
          deltaDx: deltaDx, sidebarWidth: sidebarWidth);
  void onSidebarHorizontalDragEnd({required double velocityDx}) =>
      _sidebarService.onHorizontalDragEnd(velocityDx: velocityDx);

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

  /// 统一异常捕获包装
  Future<T?> _guard<T>(
    Future<T> Function() action, {
    void Function(Object e)? onError,
    Future<void> Function()? onFinally,
  }) {
    return _error.guard(
      action,
      onError: onError,
      onFinally: onFinally,
    );
  }

  /// 侧边栏菜单项
  final sidebarItems = HomeConstants.sidebarItems;

  /// 将侧边栏选中项切回 all
  void _setSidebarAll() {
    currentSidebarKey.value = 'all';
  }

  @override
  void onInit() {
    super.onInit();

    _list = Get.find<HomeListController>();

    _dialogs = Get.find<HomeDialogsService>();

    // 下沉服务
    _layout = Get.find<HomeLayoutService>();
    _sidebarService = Get.find<HomeSidebarService>();
    _error = Get.find<HomeErrorHandler>();
    _actions = HomeActionsService(
      list: _list,
      repository: repository,
      currentSidebarKey: currentSidebarKey,
      counts: counts,
      refreshCounts: refreshCounts,
    );

    loadHomeLayoutSettings();

    // 首次加载
    fetchArticles(refresh: true);

    // 首帧后刷新统计与全量同步（避免阻塞首屏）
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await refreshCounts();
      await BookmarkSyncService().syncNow();
      await refreshCounts();

      // 首帧后尝试消费分享进来的 URL（例如从其它 App 分享链接打开）
      if (Get.isRegistered<ShareIntentService>()) {
        ShareIntentService.to.consumePendingUrlIfAny();
      }
    });
  }

  /// 打开“新增书签”弹窗（可传入初始 URL）
  Future<void> openAddBookmarkDialog({String? initialUrl}) async {
    final context = Get.context;
    if (context == null) return;
    if (_isAddBookmarkDialogOpen.value) return;
    _isAddBookmarkDialogOpen.value = true;

    try {
      final result = await _dialogs.openAddBookmarkDialog(
        context,
        initialUrl: initialUrl,
      );
      if (result == null) return;

      await addBookmark(
        url: result.url,
        title: result.title.isEmpty ? null : result.title,
      );
    } finally {
      _isAddBookmarkDialogOpen.value = false;
    }
  }

  /// 若当前项未读，则标记为已读
  Future<void> markAsReadIfNeeded(Bookmark bookmark) async {
    await _guard(() async {
      await _actions.markAsReadIfNeeded(
        bookmark: bookmark,
        filterParams: buildFilterParams(),
      );
    });
  }

  /// 若剪贴板存在 URL，则引导打开“新增书签”弹窗
  Future<void> consumeClipboardUrlIfAny() async {
    final box = GetStorage();
    if (!_authStorage.hasToken) return;

    if (_isAddBookmarkDialogOpen.value) return;

    await _guard(
      () async {
        final data = await Clipboard.getData('text/plain');
        final url = _extractFirstUrl(data?.text);
        if (url == null) return;

        final lastUrl = box.read('last_clipboard_url');
        if (lastUrl == url) return;

        box.write('last_clipboard_url', url);
        await openAddBookmarkDialog(initialUrl: url);
      },
      onError: (_) {},
    );
  }

  String? _extractFirstUrl(String? text) {
    if (text == null) return null;
    final trimmed = text.trim();
    if (trimmed.isEmpty) return null;

    final reg = RegExp(r'(https?:\/\/[^\s]+)', caseSensitive: false);
    final match = reg.firstMatch(trimmed);
    final url = match?.group(0);
    if (url == null || url.trim().isEmpty) return null;
    return url.trim();
  }

  /// 刷新侧边栏分类数量
  Future<void> refreshCounts() async {
    await _guard(
      () async {
        counts.value = await repository.getCounts();
      },
      onError: (_) {},
    );
  }

  /// 获取书签列表
  ///
  /// - refresh=true：下拉刷新，重置 offset
  /// - refresh=false：分页加载更多
  Future<void> fetchArticles({bool refresh = false}) async {
    await _guard(
      () async {
        if (refresh) {
          await _list.refreshList(baseParams: buildFilterParams());
        } else {
          await _list.fetch(refresh: false, baseParams: buildFilterParams());
        }
        await refreshCounts();
      },
      onError: (_) {},
    );
  }

  /// 打开“编辑标题”弹窗并提交更新
  Future<void> editBookmarkTitle(Bookmark bookmark) async {
    final context = Get.context;
    if (context == null) return;
    final id = bookmark.id ?? '';
    if (id.isEmpty) return;

    final newTitle = await _dialogs.openEditTitleDialog(
      context,
      initialTitle: (bookmark.title ?? '').trim(),
    );
    if (newTitle == null) return;

    await _guard(() async {
      await _actions.updateTitle(
        id: id,
        title: newTitle,
        filterParams: buildFilterParams(),
      );
    });
  }

  /// 切换已读/未读
  Future<void> toggleReadStatus(Bookmark bookmark) async {
    await _guard(() async {
      await _actions.toggleReadStatus(
        bookmark: bookmark,
        filterParams: buildFilterParams(),
      );
    });
  }

  /// 收藏/取消收藏
  Future<void> markBookmark(Bookmark bookmark, bool value) async {
    await _guard(() async {
      await _actions.markBookmark(bookmark: bookmark, value: value);
    });
  }

  /// 归档/取消归档
  Future<void> archiveBookmark(Bookmark bookmark, bool value) async {
    await _guard(() async {
      await _actions.archiveBookmark(bookmark: bookmark, value: value);
    });
  }

  /// 删除书签
  Future<void> deleteBookmark(Bookmark bookmark) async {
    await _guard(() async {
      await _actions.deleteBookmark(bookmark: bookmark);
    });
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

  /// 新增书签
  Future<bool> addBookmark({
    required String url,
    String? title,
  }) async {
    final ok = await _guard<bool>(() async {
      return await _actions.addBookmark(
        url: url,
        title: title,
        filterParams: buildFilterParams(),
        setSidebarAll: _setSidebarAll,
      );
    });
    return ok ?? false;
  }
}
