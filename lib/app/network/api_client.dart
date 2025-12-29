import 'api_debug.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get_storage/get_storage.dart';

/// 统一的网络异常
///
/// - message：可直接展示给用户的错误信息
/// - statusCode：HTTP 状态码（如果可用）
/// - raw：原始异常（用于日志或调试）
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final Object? raw;

  ApiException({required this.message, this.statusCode, this.raw});

  @override
  String toString() => message;
}

/// Dio 客户端单例
///
/// - 统一 baseUrl、超时、默认请求头
/// - 自动注入 token（如果本地存在）
/// - 支持从本地存储动态切换服务器地址
class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  final Dio dio;

  /// 统一请求入口
  ///
  /// - method：GET/POST/PATCH/DELETE 等
  /// - parser：将 response.data 转为目标类型（可选）
  /// - 出错时统一抛 ApiException，UI 层无需关心 DioException 细节
  Future<T> request<T>(
    String path, {
    String method = 'GET',
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    T Function(dynamic data)? parser,
  }) async {
    try {
      final res = await dio.request(
        path,
        data: data,
        queryParameters: queryParameters,
        options: (options ?? Options()).copyWith(method: method),
      );

      final responseData = res.data;
      if (parser != null) {
        return parser(responseData);
      }
      return responseData as T;
    } on DioException catch (e) {
      throw ApiException(
        message: extractErrorMessage(e),
        statusCode: e.response?.statusCode,
        raw: e,
      );
    } catch (e) {
      throw ApiException(message: e.toString(), raw: e);
    }
  }

  /// 规范化服务端地址
  ///
  /// - 去除首尾空格
  /// - 去除多余的尾部斜杠
  /// - 如果用户输入了 /api 结尾，则自动剔除
  static String normalizeBaseUrl(String url) {
    var value = url.trim();
    while (value.endsWith('/')) {
      value = value.substring(0, value.length - 1);
    }
    if (value.endsWith('/api')) {
      value = value.substring(0, value.length - 4);
    }
    while (value.endsWith('/')) {
      value = value.substring(0, value.length - 1);
    }
    return value;
  }

  static String _resolveBaseUrl() {
    final server = GetStorage().read('server');
    if (server is String && server.trim().isNotEmpty) {
      return normalizeBaseUrl(server);
    }
    return 'https://wyread.tocmcc.cn';
  }

  /// 从 DioException 中提取可展示给用户的错误信息
  ///
  /// - 优先读取服务端返回的 message/error/detail
  /// - 兜底使用 Dio 自身的 message
  /// - 如果包含 statusCode，则拼接在前面便于定位
  static String extractErrorMessage(DioException e) {
    final statusCode = e.response?.statusCode;
    final data = e.response?.data;
    String message = e.message ?? '请求失败';
    if (data is Map<String, dynamic>) {
      message = (data['message'] ?? data['error'] ?? data['detail'] ?? message)
          .toString();
    } else if (data != null) {
      message = data.toString();
    }
    if (statusCode != null) {
      message = 'HTTP $statusCode: $message';
    }
    return message;
  }

  ApiClient._internal()
      : dio = Dio(BaseOptions(
          baseUrl: _resolveBaseUrl(),
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'User-Agent': 'readaper-flutter',
          },
        )) {
    dio.interceptors.add(ApiDebug(enabled: kDebugMode));
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        options.baseUrl = _resolveBaseUrl();
        options.headers.putIfAbsent('Accept', () => 'application/json');
        final token = GetStorage().read('token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
    ));
  }
}
