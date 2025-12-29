import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import '../modules/home/models/bookmark.dart';
import '../modules/home/models/bookmark_counts.dart';

/// 书签本地数据库服务
///
/// - 用于本地持久化书签“统计必需字段”
/// - 使用 SQL 聚合统计侧边栏数量
class BookmarkDbService {
  static final BookmarkDbService _instance = BookmarkDbService._internal();
  factory BookmarkDbService() => _instance;
  BookmarkDbService._internal();

  static const String _dbName = 'readaper.db';
  static const int _dbVersion = 1;
  static const String _tableBookmarks = 'bookmarks';

  Database? _db;

  Future<Database> _database() async {
    if (_db != null) return _db!;
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, _dbName);
    _db = await openDatabase(
      path,
      version: _dbVersion,
      onCreate: (db, version) async {
        await db.execute('''
CREATE TABLE $_tableBookmarks (
  id TEXT PRIMARY KEY,
  title TEXT,
  url TEXT,
  type TEXT,
  state INTEGER,
  loaded INTEGER,
  read_progress INTEGER,
  is_deleted INTEGER,
  is_marked INTEGER,
  is_archived INTEGER,
  updated TEXT
)
''');
        await db.execute(
            'CREATE INDEX idx_bookmarks_state ON $_tableBookmarks(state)');
        await db.execute(
            'CREATE INDEX idx_bookmarks_flags ON $_tableBookmarks(is_deleted, is_archived, is_marked)');
        await db.execute(
            'CREATE INDEX idx_bookmarks_type ON $_tableBookmarks(type)');
      },
    );
    return _db!;
  }

  /// 批量写入/更新书签
  ///
  /// - 使用事务提升写入效率
  Future<void> upsertBookmarks(List<Bookmark> bookmarks) async {
    if (bookmarks.isEmpty) return;
    final db = await _database();
    await db.transaction((txn) async {
      final batch = txn.batch();
      for (final b in bookmarks) {
        if (b.id == null || b.id!.isEmpty) continue;
        batch.insert(
          _tableBookmarks,
          {
            'id': b.id,
            'title': b.title,
            'url': b.url,
            'type': b.type,
            'state': b.state,
            'loaded': b.loaded ? 1 : 0,
            'read_progress': b.readProgress,
            'is_deleted': b.isDeleted ? 1 : 0,
            'is_marked': b.isMarked ? 1 : 0,
            'is_archived': b.isArchived ? 1 : 0,
            'updated': b.updated,
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
      await batch.commit(noResult: true);
    });
  }

  /// 更新书签状态（收藏/归档/阅读进度等）
  Future<void> updateBookmark(
    String id, {
    bool? isMarked,
    bool? isArchived,
    bool? isDeleted,
    int? readProgress,
    String? type,
    int? state,
    bool? loaded,
    String? updated,
  }) async {
    final db = await _database();
    final values = <String, Object?>{};
    if (isMarked != null) values['is_marked'] = isMarked ? 1 : 0;
    if (isArchived != null) values['is_archived'] = isArchived ? 1 : 0;
    if (isDeleted != null) values['is_deleted'] = isDeleted ? 1 : 0;
    if (readProgress != null) values['read_progress'] = readProgress;
    if (type != null) values['type'] = type;
    if (state != null) values['state'] = state;
    if (loaded != null) values['loaded'] = loaded ? 1 : 0;
    if (updated != null) values['updated'] = updated;
    if (values.isEmpty) return;

    await db.update(
      _tableBookmarks,
      values,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// 删除书签（物理删除）
  Future<void> deleteBookmark(String id) async {
    final db = await _database();
    await db.delete(_tableBookmarks, where: 'id = ?', whereArgs: [id]);
  }

  /// 统计侧边栏数量
  ///
  /// 统计规则（对齐 ReadeckApp 的思路）：
  /// - 只统计未删除（is_deleted = 0）
  /// - state = 0 代表正常（与服务端字段一致）
  /// - unread：read_progress < 100
  Future<BookmarkCounts> getCounts() async {
    final db = await _database();
    final rows = await db.rawQuery('''
SELECT
  (SELECT COUNT(*) FROM $_tableBookmarks WHERE is_deleted = 0 AND state = 0) AS all_count,
  (SELECT COUNT(*) FROM $_tableBookmarks WHERE is_deleted = 0 AND state = 0 AND read_progress < 100) AS unread_count,
  (SELECT COUNT(*) FROM $_tableBookmarks WHERE is_deleted = 0 AND state = 0 AND is_archived = 1) AS archived_count,
  (SELECT COUNT(*) FROM $_tableBookmarks WHERE is_deleted = 0 AND state = 0 AND is_marked = 1) AS favorite_count,
  (SELECT COUNT(*) FROM $_tableBookmarks WHERE is_deleted = 0 AND state = 0 AND type = 'video') AS video_count
FROM $_tableBookmarks
LIMIT 1
''');

    if (rows.isEmpty) return const BookmarkCounts();
    final row = rows.first;
    return BookmarkCounts(
      all: (row['all_count'] as int?) ?? 0,
      unread: (row['unread_count'] as int?) ?? 0,
      archived: (row['archived_count'] as int?) ?? 0,
      favorite: (row['favorite_count'] as int?) ?? 0,
      video: (row['video_count'] as int?) ?? 0,
    );
  }
}
