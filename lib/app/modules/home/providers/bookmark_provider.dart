import '../../../network/api_client.dart';
import '../models/bookmark.dart';
import 'package:dio/dio.dart';

/// 书签相关接口
class BookmarkProvider {
  final _api = ApiClient();

  /// 获取书签列表（默认参数）
  Future<List<Bookmark>> getBookmarks({int limit = 10, int offset = 0}) async {
    return getBookmarksWithParams({
      'limit': limit,
      'offset': offset,
      'sort': '-created',
      'read_status': 'all',
    });
  }

  /// 获取文章 HTML 内容（服务端返回 text/html）
  Future<String> getArticleHtml(String id) async {
    return _api.request<String>('/api/bookmarks/$id/article',
        options: Options(
          headers: {
            'accept': 'text/html',
          },
          responseType: ResponseType.plain,
        ),
        parser: (data) => data?.toString() ?? '');
  }

  /// 获取文章 Markdown 内容（服务端返回纯文本）
  Future<String> getArticleMarkdown(String id) async {
    return _api.request<String>('/api/bookmarks/$id/article.md',
        options: Options(
          headers: {
            'accept': 'application/epub+zip',
          },
          responseType: ResponseType.plain,
        ),
        parser: (data) => data?.toString() ?? '');
  }

  /// 更新书签状态
  ///
  /// - isMarked：收藏/取消收藏
  /// - isArchived：归档/取消归档
  Future<bool> updateBookmarkStatus(
    String id, {
    bool? isMarked,
    bool? isArchived,
  }) async {
    final data = <String, dynamic>{};
    if (isMarked != null) data['is_marked'] = isMarked;
    if (isArchived != null) data['is_archived'] = isArchived;
    await _api.request<Map<String, dynamic>?>(
      '/api/bookmarks/$id',
      method: 'PATCH',
      data: data,
      parser: (data) => data is Map<String, dynamic> ? data : null,
    );
    return true;
  }

  /// 删除书签
  Future<bool> deleteBookmark(String id) async {
    await _api.request<void>('/api/bookmarks/$id', method: 'DELETE');
    return true;
  }

  /// 新增书签
  Future<bool> addBookmark({
    required String url,
    String? title,
    DateTime? created,
  }) async {
    final data = <String, dynamic>{
      'url': url,
      'created': (created ?? DateTime.now().toUtc()).toIso8601String(),
    };
    if (title != null && title.trim().isNotEmpty) {
      data['title'] = title.trim();
    }

    await _api.request<Map<String, dynamic>?>('/api/bookmarks',
        method: 'POST',
        data: data,
        parser: (data) => data is Map<String, dynamic> ? data : null);
    return true;
  }

  /// 按自定义参数获取书签列表
  Future<List<Bookmark>> getBookmarksWithParams(
      Map<String, dynamic> params) async {
    return _api.request<List<Bookmark>>('/api/bookmarks',
        queryParameters: params, parser: (data) {
      final list = data as List<dynamic>? ?? [];
      return list.map((e) => Bookmark.fromJson(e)).toList();
    });
  }
}
