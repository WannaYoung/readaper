import '../../../network/api_client.dart';

/// 认证相关接口
class AuthProvider {
  final _api = ApiClient();

  /// 登录
  ///
  /// - 成功时返回服务端响应 JSON（通常包含 token/id 等字段）
  /// - 失败时交给 Dio 抛出异常，由上层统一捕获并提示
  Future<Map<String, dynamic>?> login({
    String application = 'readaper',
    required String username,
    required String password,
    List<String>? roles,
  }) async {
    return _api
        .request<Map<String, dynamic>?>('/api/auth', method: 'POST', data: {
      'application': application,
      'username': username,
      'password': password,
      if (roles != null) 'roles': roles,
    }, parser: (data) {
      return data is Map<String, dynamic> ? data : null;
    });
  }
}
