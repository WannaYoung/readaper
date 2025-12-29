import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:readeck/app/config/env.dart';
import '../../../data/providers/auth_provider.dart';
import 'package:get_storage/get_storage.dart';

class LoginController extends GetxController {
  final AuthProvider provider;
  LoginController(this.provider);

  final serverController = TextEditingController(text: env.host);
  final usernameController = TextEditingController(text: env.user);
  final passwordController = TextEditingController(text: env.password);
  final box = GetStorage();

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

  void login() async {
    final server = _normalizeBaseUrl(serverController.text);
    final username = usernameController.text.trim();
    final password = passwordController.text;
    if (server.isEmpty || username.isEmpty || password.isEmpty) {
      Get.snackbar('错误'.tr, '请填写完整信息'.tr);
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
        Get.offAllNamed('/home');
      } else {
        final message = res is Map<String, dynamic>
            ? (res['message'] ?? res['error'] ?? res['detail'] ?? '无效响应'.tr)
            : '无效响应'.tr;
        Get.snackbar('登录失败'.tr, message.toString());
      }
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode;
      final data = e.response?.data;
      String message = e.message ?? '请求失败'.tr;
      if (data is Map<String, dynamic>) {
        message =
            (data['message'] ?? data['error'] ?? data['detail'] ?? message)
                .toString();
      } else if (data != null) {
        message = data.toString();
      }
      if (statusCode != null) {
        message = 'HTTP $statusCode: $message';
      }
      Get.snackbar('登录失败'.tr, message);
    } catch (e) {
      Get.snackbar('登录失败'.tr, e.toString());
    }
  }

  @override
  void onClose() {
    serverController.dispose();
    usernameController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
