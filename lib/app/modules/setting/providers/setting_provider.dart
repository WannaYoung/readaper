import '../../../network/api_client.dart';
import '../models/user_profile.dart';

/// 设置模块相关接口
class SettingProvider {
  final _api = ApiClient();

  /// 获取用户信息
  Future<UserProfile> getUserProfile() async {
    return _api.request<UserProfile>('/api/profile', parser: (data) {
      return UserProfile.fromJson(data as Map<String, dynamic>);
    });
  }
}
