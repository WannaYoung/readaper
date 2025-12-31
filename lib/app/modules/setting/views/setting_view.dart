import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/setting_controller.dart';

/// 设置页
///
/// - 语言选择
/// - 主题选择
/// - 展示账号信息
/// - 退出登录
class SettingView extends GetView<SettingController> {
  const SettingView({super.key});

  Widget _buildSection({
    required String title,
    double? titleBottomPadding,
    required Widget child,
    Widget? trailing,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                title,
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
              ),
            ),
            if (trailing != null) trailing,
          ],
        ),
        SizedBox(height: titleBottomPadding ?? 10),
        child,
        _divider(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('settings'.tr, style: TextStyle(fontSize: 20)),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLanguageSelector(theme),
              _buildThemeSelector(theme),
              _buildSyncSettings(theme),
              _buildAccountInfo(),
              _buildAboutVersion(),
              _buildLogoutButton(),
            ],
          ),
        ),
      ),
    );
  }

  /// 同步设置
  Widget _buildSyncSettings(ThemeData theme) {
    return _buildSection(
      title: 'syncSettings'.tr,
      titleBottomPadding: 8,
      trailing: Obx(() {
        return IconButton(
          tooltip: 'syncNow'.tr,
          onPressed:
              controller.syncRunning.value ? null : () => controller.syncNow(),
          icon: controller.syncRunning.value
              ? const SizedBox(
                  width: 15,
                  height: 15,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.sync, size: 20),
        );
      }),
      child: Obx(() {
        final selectedIndex = controller.selectedSyncTimeframeIndex.value;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(
                  SettingController.syncTimeframeMinutes.length, (index) {
                final isSelected = selectedIndex == index;
                final minutes = SettingController.syncTimeframeMinutes[index];
                final labelKey =
                    controller.getSyncTimeframeLabelKeyByMinutes(minutes);
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4),
                    child: GestureDetector(
                      onTap: () => controller.updateSyncTimeframeIndex(index),
                      child: Container(
                        height: 35,
                        decoration: BoxDecoration(
                          color: theme.cardColor,
                          border: isSelected
                              ? Border.all(
                                  color: theme.colorScheme.primary,
                                  width: 1.5,
                                )
                              : Border.all(color: Colors.transparent),
                          borderRadius: BorderRadius.circular(3),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          labelKey.tr,
                          style: TextStyle(
                            fontSize: 13,
                            color: isSelected
                                ? theme.textTheme.bodyMedium?.color
                                : theme.textTheme.bodyMedium?.color
                                    ?.withAlpha(160),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${'lastSync'.tr}：${controller.lastSyncText.value}',
                    style: const TextStyle(fontSize: 13),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${'nextSync'.tr}：${controller.nextSyncText.value}',
                    style: const TextStyle(fontSize: 13),
                  ),
                ),
              ],
            ),
          ],
        );
      }),
    );
  }

  /// 分割线
  Widget _divider() {
    return Column(
      children: [
        const SizedBox(height: 10),
        Divider(
          color: Color.fromARGB(80, 180, 180, 180),
          height: 1,
          thickness: 0.8,
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  /// 语言选择控件
  Widget _buildLanguageSelector(ThemeData theme) {
    return _buildSection(
      title: 'language'.tr,
      titleBottomPadding: 12,
      child: Obx(() {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children:
              List.generate(SettingController.languageOptions.length, (index) {
            final isSelected = controller.selectedLanguageIndex.value == index;
            return Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 4),
                child: GestureDetector(
                  onTap: () => controller.updateLanguageIndex(index),
                  child: Container(
                    height: 35,
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      border: isSelected
                          ? Border.all(
                              color: theme.colorScheme.primary,
                              width: 1.5,
                            )
                          : Border.all(color: Colors.transparent),
                      borderRadius: BorderRadius.circular(3),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      SettingController.languageOptions[index],
                      style: TextStyle(
                        fontSize: 15,
                        color: isSelected
                            ? theme.textTheme.bodyLarge?.color
                            : theme.textTheme.bodyLarge?.color?.withAlpha(140),
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
        );
      }),
    );
  }

  /// 主题选择控件
  Widget _buildThemeSelector(ThemeData theme) {
    return _buildSection(
      title: 'theme'.tr,
      titleBottomPadding: 12,
      child: Obx(() {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children:
              List.generate(SettingController.themeColors.length, (index) {
            final isSelected = controller.selectedThemeIndex.value == index;
            return Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 4),
                child: GestureDetector(
                  onTap: () => controller.updateThemeIndex(index),
                  child: Container(
                    height: 30,
                    decoration: BoxDecoration(
                      color: SettingController.themeColors[index],
                      border: isSelected
                          ? Border.all(
                              color: theme.colorScheme.primary,
                              width: 1.5,
                            )
                          : Border.all(color: Colors.transparent),
                      borderRadius: BorderRadius.circular(3),
                    ),
                    alignment: Alignment.center,
                  ),
                ),
              ),
            );
          }),
        );
      }),
    );
  }

  /// 账号信息展示控件
  Widget _buildAccountInfo() {
    return _buildSection(
      title: 'account'.tr,
      child: Obx(() {
        final user = controller.userProfile.value?.user;
        if (user == null) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Text(
              'loading'.tr,
              style: TextStyle(
                color: (Theme.of(Get.context!).textTheme.bodyMedium?.color ??
                        Theme.of(Get.context!).hintColor)
                    .withAlpha(170),
              ),
            ),
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Text('${'user'.tr}：${user.username}',
                  style: TextStyle(fontSize: 15)),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Text('${'email'.tr}：${user.email}',
                  style: TextStyle(fontSize: 15)),
            ),
          ],
        );
      }),
    );
  }

  /// 关于版本展示控件
  Widget _buildAboutVersion() {
    return _buildSection(
      title: 'about'.tr,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Text('${'version'.tr}：0.0.1-202505221',
            style: TextStyle(fontSize: 15)),
      ),
    );
  }

  /// 退出登录按钮控件
  Widget _buildLogoutButton() {
    return GestureDetector(
      onTap: () => controller.logout(),
      child: Text(
        'logout'.tr,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.red,
        ),
      ),
    );
  }
}
