import 'dart:async';

import 'package:get_storage/get_storage.dart';

import '../modules/home/providers/bookmark_provider.dart';
import 'bookmark_db_service.dart';

/// 书签同步服务（前台定时）
///
/// - 参考 ReadeckApp：支持手动同步、自动同步开关、同步频率
/// - Flutter 侧不引入后台任务插件时，只能在应用前台运行时定时触发
/// - 同步内容：分页拉取书签列表并写入本地 sqflite，用于侧边栏统计
class BookmarkSyncService {
  static final BookmarkSyncService _instance = BookmarkSyncService._internal();
  factory BookmarkSyncService() => _instance;
  BookmarkSyncService._internal();

  static const String _keyAutoSyncEnabled = 'sync_auto_enabled';
  static const String _keyAutoSyncMinutes = 'sync_auto_minutes';
  static const String _keyLastSyncAtMs = 'sync_last_at_ms';
  static const String _keyNextSyncAtMs = 'sync_next_at_ms';

  final GetStorage _box = GetStorage();
  final BookmarkProvider _provider = BookmarkProvider();
  final BookmarkDbService _db = BookmarkDbService();

  Timer? _timer;
  bool _running = false;

  /// 初始化（建议在 main() 调用）
  void init() {
    _restartTimerIfNeeded();
  }

  bool get autoSyncEnabled => _box.read(_keyAutoSyncEnabled) == true;

  int get autoSyncMinutes {
    final val = _box.read(_keyAutoSyncMinutes);
    if (val is int && val > 0) return val;
    return 0;
  }

  DateTime? get lastSyncAt {
    final val = _box.read(_keyLastSyncAtMs);
    if (val is int && val > 0) {
      return DateTime.fromMillisecondsSinceEpoch(val);
    }
    return null;
  }

  DateTime? get nextSyncAt {
    final val = _box.read(_keyNextSyncAtMs);
    if (val is int && val > 0) {
      return DateTime.fromMillisecondsSinceEpoch(val);
    }
    return null;
  }

  void setAutoSyncEnabled(bool enabled) {
    _box.write(_keyAutoSyncEnabled, enabled);
    _restartTimerIfNeeded();
  }

  void setAutoSyncMinutes(int minutes) {
    if (minutes < 0) minutes = 0;
    _box.write(_keyAutoSyncMinutes, minutes);
    _restartTimerIfNeeded();
  }

  /// 立即执行一次全量同步
  Future<void> syncNow() async {
    if (_running) return;
    _running = true;
    try {
      await _performFullSync();
      _box.write(_keyLastSyncAtMs, DateTime.now().millisecondsSinceEpoch);
    } finally {
      _running = false;
      _restartTimerIfNeeded();
    }
  }

  /// 执行全量同步：分页拉取并写入本地数据库
  Future<void> _performFullSync() async {
    const int limit = 50;
    int offset = 0;
    while (true) {
      final params = <String, dynamic>{
        'limit': limit,
        'offset': offset,
        'sort': '-created',
      };
      final list = await _provider.getBookmarksWithParams(params);
      if (list.isEmpty) break;
      await _db.upsertBookmarks(list);
      offset += limit;
      if (list.length < limit) break;
    }
  }

  void _restartTimerIfNeeded() {
    _timer?.cancel();
    _timer = null;

    if (!autoSyncEnabled) {
      _box.write(_keyNextSyncAtMs, null);
      return;
    }

    final minutes = autoSyncMinutes;
    if (minutes <= 0) {
      // 开启自动同步但未设置频率：不定时，仅保留开关
      _box.write(_keyNextSyncAtMs, null);
      return;
    }

    final next = DateTime.now().add(Duration(minutes: minutes));
    _box.write(_keyNextSyncAtMs, next.millisecondsSinceEpoch);

    _timer = Timer(Duration(minutes: minutes), () async {
      await syncNow();
    });
  }

  void dispose() {
    _timer?.cancel();
    _timer = null;
  }

  /// UI 下拉选项（分钟）
  static const List<int> timeframeOptionsMinutes = [
    0, // 手动
    60,
    360,
    720
  ];
}
