import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/login_controller.dart';

class LoginView extends GetView<LoginController> {
  const LoginView({super.key});
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text('Readaper'.tr,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 28)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 32),
              _buildTextField(
                controller: controller.serverController,
                label: '服务器地址'.tr,
                theme: theme,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: controller.usernameController,
                label: '用户名'.tr,
                theme: theme,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: controller.passwordController,
                label: '密码'.tr,
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
        fillColor: Colors.white,
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

  Widget _buildLoginButton(ThemeData theme) {
    return SizedBox(
      height: 48,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5),
          ),
          elevation: 0,
        ),
        onPressed: controller.login,
        child: Text('登录'.tr,
            style: const TextStyle(fontSize: 18, color: Colors.white)),
      ),
    );
  }
}
