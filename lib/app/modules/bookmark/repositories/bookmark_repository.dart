// Project imports:
import '../../../network/api_client.dart';
import '../models/bookmark.dart';
import '../models/bookmark_counts.dart';
import '../providers/bookmark_provider.dart';
import '../services/bookmark_db_service.dart';

/// 书签仓库
///
/// - 统一封装书签相关的数据操作（网络请求 + 本地数据库）
/// - 对外屏蔽 provider/db 细节，便于控制器与服务层调用
class BookmarkRepository {
  final BookmarkProvider provider;
  final BookmarkDbService db;

  BookmarkRepository({required this.provider, required this.db});

  /// 按参数拉取书签列表，并写入本地数据库
  Future<List<Bookmark>> fetchBookmarksWithParams(
      Map<String, dynamic> params) async {
    try {
      final list = await provider.getBookmarksWithParams(params);
      await db.upsertBookmarks(list);
      return list;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: e.toString(), raw: e);
    }
  }

  /// 获取本地统计数量（如总数/未读/归档/收藏/视频等）
  Future<BookmarkCounts> getCounts() async {
    try {
      return await db.getCounts();
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: e.toString(), raw: e);
    }
  }

  /// 收藏/取消收藏，并返回最新统计数据
  Future<BookmarkCounts> toggleMarked(String id, {required bool value}) async {
    try {
      await provider.updateBookmarkStatus(id, isMarked: value);
      return await db.updateBookmarkAndGetCounts(id, isMarked: value);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: e.toString(), raw: e);
    }
  }

  /// 归档/取消归档，并返回最新统计数据
  Future<BookmarkCounts> toggleArchived(String id,
      {required bool value}) async {
    try {
      await provider.updateBookmarkStatus(id, isArchived: value);
      return await db.updateBookmarkAndGetCounts(id, isArchived: value);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: e.toString(), raw: e);
    }
  }

  /// 更新阅读进度，并返回最新统计数据
  Future<BookmarkCounts> updateReadProgress(
    String id, {
    required int readProgress,
  }) async {
    try {
      await provider.updateBookmarkStatus(id, readProgress: readProgress);
      return await db.updateBookmarkAndGetCounts(
        id,
        readProgress: readProgress,
      );
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: e.toString(), raw: e);
    }
  }

  /// 更新书签标题（网络 + 本地）
  Future<void> updateTitle(String id, {required String title}) async {
    try {
      await provider.updateBookmarkStatus(id, title: title);
      await db.updateBookmark(id, title: title);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: e.toString(), raw: e);
    }
  }

  /// 删除书签，并返回最新统计数据
  Future<BookmarkCounts> deleteBookmark(String id) async {
    try {
      await provider.deleteBookmark(id);
      return await db.deleteBookmarkAndGetCounts(id);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: e.toString(), raw: e);
    }
  }

  /// 新增书签
  Future<void> addBookmark({
    required String url,
    String? title,
    DateTime? created,
  }) async {
    try {
      await provider.addBookmark(
        url: url,
        title: title,
        created: created,
      );
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: e.toString(), raw: e);
    }
  }
}
