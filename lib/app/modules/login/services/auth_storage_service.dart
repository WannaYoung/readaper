// Package imports:
import 'package:get_storage/get_storage.dart';

/// 登录信息本地存储服务
///
/// - 统一管理服务器地址/用户名的读写
/// - 避免散落字符串 key
class AuthStorageService {
  /// 服务器地址 key
  static const _keyServer = 'server';

  /// 用户名 key
  static const _keyUsername = 'username';

  static const _keyToken = 'token';
  static const _keyUserId = 'id';

  final GetStorage _box;

  /// 存储服务
  AuthStorageService({GetStorage? box}) : _box = box ?? GetStorage();

  /// 服务器地址
  String get server => (_box.read(_keyServer) ?? '').toString().trim();

  /// 用户名
  String get username => (_box.read(_keyUsername) ?? '').toString().trim();

  String get token => (_box.read(_keyToken) ?? '').toString().trim();

  String get userId => (_box.read(_keyUserId) ?? '').toString().trim();

  bool get hasToken => token.isNotEmpty;

  /// 保存服务器地址
  void saveServer(String server) {
    _box.write(_keyServer, server);
  }

  /// 保存用户名
  void saveUsername(String username) {
    _box.write(_keyUsername, username);
  }

  void saveToken(String token) {
    _box.write(_keyToken, token);
  }

  void saveUserId(String id) {
    _box.write(_keyUserId, id);
  }

  void clearAuth() {
    _box.remove(_keyToken);
    _box.remove(_keyUserId);
  }
}
