// Dart imports:
import 'dart:developer' as developer;

// Package imports:
import 'package:dio/dio.dart';

/// 网络请求调试拦截器
///
/// - 仅用于开发调试，建议结合 `kDebugMode` 控制启用
/// - 在控制台输出 host、path、query、request、response、耗时等信息
/// - 为避免泄露敏感信息：不输出任何 headers
class ApiDebug extends Interceptor {
  final bool enabled;

  /// 是否启用日志输出
  ApiDebug({required this.enabled});

  /// 截断过长内容，避免日志刷屏
  String _truncate(Object? value, {int max = 2000}) {
    final text = value?.toString() ?? '';
    if (text.length <= max) return text;
    return '${text.substring(0, max)}...(truncated ${text.length - max} chars)';
  }

  /// 构建完整请求 URI（用于提取 host/path/query 展示）
  Uri _buildUri(RequestOptions options) {
    try {
      final base = Uri.parse(options.baseUrl);
      return base.replace(
        path: '${base.path}${options.path}',
        queryParameters: options.queryParameters.isEmpty
            ? null
            : options.queryParameters.map((k, v) => MapEntry(k, v?.toString())),
      );
    } catch (_) {
      return Uri.parse('${options.baseUrl}${options.path}');
    }
  }

  void _log(String message) {
    developer.log(message, name: 'NETWORK');
  }

  /// 格式化单行字段：`• key: value`
  String _formatLine(String key, Object? value) {
    return '• $key: ${_truncate(value)}';
  }

  @override

  /// 请求发出前：记录 request（不包含 headers）
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (!enabled) {
      handler.next(options);
      return;
    }
    options.extra['__startAtMs'] = DateTime.now().millisecondsSinceEpoch;

    final uri = _buildUri(options);

    _log(
      '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n'
      '🚀 请求  ${options.method} ${uri.host}${uri.path}\n'
      '${_formatLine('host', uri.host)}\n'
      '${_formatLine('path', uri.path)}\n'
      '${_formatLine('query', options.queryParameters)}\n'
      '${_formatLine('request', options.data)}\n'
      '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━',
    );

    handler.next(options);
  }

  @override

  /// 响应返回：记录 status、耗时与 response
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (!enabled) {
      handler.next(response);
      return;
    }

    final options = response.requestOptions;
    final uri = _buildUri(options);
    final startAtMs = options.extra['__startAtMs'];
    final costMs = startAtMs is int
        ? (DateTime.now().millisecondsSinceEpoch - startAtMs)
        : null;

    _log(
      '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n'
      '✅ 响应  ${options.method} ${uri.host}${uri.path}\n'
      '${_formatLine('status', response.statusCode)}\n'
      '${_formatLine('cost', costMs == null ? '-' : '${costMs}ms')}\n'
      '${_formatLine('response', response.data)}\n'
      '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━',
    );

    handler.next(response);
  }

  @override

  /// 异常：记录错误类型、状态码、耗时与服务端返回（如果有）
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (!enabled) {
      handler.next(err);
      return;
    }

    final options = err.requestOptions;
    final uri = _buildUri(options);
    final startAtMs = options.extra['__startAtMs'];
    final costMs = startAtMs is int
        ? (DateTime.now().millisecondsSinceEpoch - startAtMs)
        : null;

    _log(
      '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n'
      '❌ 错误  ${options.method} ${uri.host}${uri.path}\n'
      '${_formatLine('type', err.type)}\n'
      '${_formatLine('status', err.response?.statusCode)}\n'
      '${_formatLine('cost', costMs == null ? '-' : '${costMs}ms')}\n'
      '${_formatLine('message', err.message)}\n'
      '${_formatLine('response', err.response?.data)}\n'
      '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━',
    );

    handler.next(err);
  }
}
