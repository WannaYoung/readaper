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

  final GetStorage _box;

  /// 存储服务
  AuthStorageService({GetStorage? box}) : _box = box ?? GetStorage();

  /// 服务器地址
  String get server => (_box.read(_keyServer) ?? '').toString().trim();

  /// 用户名
  String get username => (_box.read(_keyUsername) ?? '').toString().trim();

  /// 保存服务器地址
  void saveServer(String server) {
    _box.write(_keyServer, server);
  }

  /// 保存用户名
  void saveUsername(String username) {
    _box.write(_keyUsername, username);
  }
}
