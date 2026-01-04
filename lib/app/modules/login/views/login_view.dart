import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/login_controller.dart';

/// 登录页
///
/// - 输入服务器地址/用户名/密码
/// - 点击按钮触发登录
class LoginView extends GetView<LoginController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 80),
              Text('readaper'.tr,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 28)),
              const SizedBox(height: 32),
              _buildTextField(
                controller: controller.serverController,
                label: 'serverAddress'.tr,
                theme: theme,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: controller.usernameController,
                label: 'username'.tr,
                theme: theme,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: controller.passwordController,
                label: 'password'.tr,
                theme: theme,
                obscure: true,
              ),
              const SizedBox(height: 32),
              _buildLoginButton(theme),
            ],
          ),
        ),
      ),
    );
  }

  /// 构建输入框
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required ThemeData theme,
    bool obscure = false,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: theme.cardColor,
        contentPadding:
            const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5),
          borderSide: BorderSide(color: theme.primaryColor),
        ),
        suffixIcon: ValueListenableBuilder<TextEditingValue>(
          valueListenable: controller,
          builder: (context, value, child) {
            return value.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear, size: 20),
                    onPressed: () => controller.clear(),
                  )
                : const SizedBox.shrink();
          },
        ),
      ),
      obscureText: obscure,
    );
  }

  /// 构建登录按钮
  Widget _buildLoginButton(ThemeData theme) {
    return SizedBox(
      height: 48,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5),
          ),
          elevation: 0,
        ),
        onPressed: controller.login,
        child: Text(
          'login'.tr,
          style: TextStyle(fontSize: 18, color: theme.colorScheme.onPrimary),
        ),
      ),
    );
  }
}
