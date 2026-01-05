// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import 'package:readaper/app/config/env.dart';
import 'package:readaper/app/modules/login/services/auth_storage_service.dart';
import 'package:readaper/app/routes/app_pages.dart';
import '../../../network/api_client.dart';
import '../repositories/auth_repository.dart';

class LoginController extends GetxController {
  final AuthRepository repository;
  LoginController(this.repository);

  final serverController = TextEditingController();
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final AuthStorageService _authStorage = Get.find<AuthStorageService>();

  @override
  void onInit() {
    super.onInit();

    final savedServer = _authStorage.server;
    final savedUsername = _authStorage.username;

    serverController.text = savedServer.isNotEmpty ? savedServer : env.host;
    usernameController.text =
        savedUsername.isNotEmpty ? savedUsername : env.user;
    // 密码不做持久化，每次进入登录页都清空
    passwordController.clear();
  }

  /// 执行登录
  ///
  /// - 会将服务器地址写入本地存储
  /// - 登录成功后写入 token，并跳转到首页
  void login() async {
    try {
      final username = usernameController.text.trim();
      final password = passwordController.text;
      final server = ApiClient.normalizeBaseUrl(serverController.text);

      final error = await repository.login(
        server: server,
        username: username,
        password: password,
      );

      if (error == null) {
        // 登录成功后清空密码，避免返回登录页时残留
        passwordController.clear();
        Get.offAllNamed(Routes.HOME);
        return;
      }

      final knownKeys = <String>{'fillAllFields', 'invalidResponse'};
      final message = knownKeys.contains(error) ? error.tr : error;
      Get.snackbar('loginFailed'.tr, message);
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
