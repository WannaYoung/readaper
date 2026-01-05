// Project imports:
import 'package:readaper/app/modules/login/services/auth_storage_service.dart';
import '../../../network/api_client.dart';
import '../providers/auth_provider.dart';

class AuthRepository {
  final AuthProvider provider;
  final AuthStorageService storage;

  AuthRepository({required this.provider, required this.storage});

  Future<String?> login({
    required String server,
    required String username,
    required String password,
  }) async {
    final normalizedServer = ApiClient.normalizeBaseUrl(server);
    if (normalizedServer.isEmpty ||
        username.trim().isEmpty ||
        password.isEmpty) {
      return 'fillAllFields';
    }

    storage.saveServer(normalizedServer);

    Map<String, dynamic>? res;
    try {
      res = await provider.login(
        username: username.trim(),
        password: password,
      );
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: e.toString(), raw: e);
    }

    final token = res?['token'];
    final id = res?['id'];
    if (token == null || id == null) {
      final message = (res?['message'] ??
              res?['error'] ??
              res?['detail'] ??
              'invalidResponse')
          .toString();
      return message.toString();
    }

    storage.saveToken(token.toString());
    storage.saveUserId(id.toString());
    storage.saveUsername(username.trim());
    return null;
  }
}
