import 'package:dio/dio.dart';
import '../../core/network/api_client.dart';

class AuthProvider {
  final _client = ApiClient().dio;

  Future<Map<String, dynamic>?> login({
    String application = 'readear',
    required String username,
    required String password,
    List<String>? roles,
  }) async {
    final res = await _client.post(
      '/api/auth',
      data: {
        'application': application,
        'username': username,
        'password': password,
        if (roles != null) 'roles': roles,
      },
      options: Options(
        headers: {
          'accept': 'application/json',
          'content-type': 'application/json',
        },
        validateStatus: (_) => true,
      ),
    );
    return res.data;
  }
}
