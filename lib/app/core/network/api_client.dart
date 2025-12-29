import 'package:dio/dio.dart';
import 'package:get_storage/get_storage.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  late Dio dio;

  String _normalizeBaseUrl(String url) {
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

  String _resolveBaseUrl() {
    final server = GetStorage().read('server');
    if (server is String && server.trim().isNotEmpty) {
      return _normalizeBaseUrl(server);
    }
    return 'https://wyread.tocmcc.cn';
  }

  ApiClient._internal() {
    dio = Dio(BaseOptions(
      baseUrl: _resolveBaseUrl(),
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'User-Agent': 'readeck-flutter',
      },
    ));
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
