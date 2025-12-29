import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:readaper/app/config/env.dart';
import 'package:readaper/app/routes/app_pages.dart';
import '../providers/auth_provider.dart';
import '../../../network/api_client.dart';
import 'package:get_storage/get_storage.dart';

class LoginController extends GetxController {
  final AuthProvider provider;
  LoginController(this.provider);

  final serverController = TextEditingController(text: env.host);
  final usernameController = TextEditingController(text: env.user);
  final passwordController = TextEditingController(text: env.password);
  final box = GetStorage();

  /// 执行登录
  ///
  /// - 会将服务器地址写入本地存储
  /// - 登录成功后写入 token，并跳转到首页
  void login() async {
    final server = ApiClient.normalizeBaseUrl(serverController.text);
    final username = usernameController.text.trim();
    final password = passwordController.text;
    if (server.isEmpty || username.isEmpty || password.isEmpty) {
      Get.snackbar('error'.tr, 'fillAllFields'.tr);
      return;
    }
    box.write('server', server);
    try {
      final res = await provider.login(
        username: username,
        password: password,
      );
      if (res != null && res['token'] != null && res['id'] != null) {
        box.write('token', res['token']);
        box.write('id', res['id']);
        Get.offAllNamed(Routes.HOME);
      } else {
        final message = res is Map<String, dynamic>
            ? (res['message'] ??
                res['error'] ??
                res['detail'] ??
                'invalidResponse'.tr)
            : 'invalidResponse'.tr;
        Get.snackbar('loginFailed'.tr, message.toString());
      }
    } on ApiException catch (e) {
      Get.snackbar('loginFailed'.tr, e.message);
    } catch (e) {
      Get.snackbar('loginFailed'.tr, e.toString());
    }
  }

  @override
  void onClose() {
    // 释放输入框控制器，避免内存泄漏
    serverController.dispose();
    usernameController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
