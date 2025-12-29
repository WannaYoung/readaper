import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:readaper/app/routes/app_pages.dart';
import 'package:readaper/app/widgets/alert_dialog.dart';
import '../../../data/providers/setting_provider.dart';
import '../../../data/models/user_profile.dart';
import '../../../data/localization_service.dart';
import '../../../data/theme_service.dart';

class SettingController extends GetxController {
  // 主题和语言选项
  static const themeColors = [
    Color(0xFFFBFBFB),
    Color(0xFFFFF9EA),
    Color(0xFF323232),
  ];
  static const languageOptions = ['简体中文', '繁体中文', 'English'];

  int selectedThemeIndex = 0;
  int selectedLanguageIndex = 0;
  UserProfile? userProfile;
  final SettingProvider provider = SettingProvider();
  final LocalizationService localizationService = LocalizationService();
  final ThemeService themeService = ThemeService();

  @override
  void onInit() {
    super.onInit();
    selectedThemeIndex = themeService.themeIndex;
    // 初始化语言选中项
    _initSelectedLanguageIndex();
    fetchUserProfile();
  }

  void _initSelectedLanguageIndex() {
    Locale locale = Get.locale ?? localizationService.getCurrentLocale();
    if (locale.languageCode == 'zh' && locale.countryCode == 'CN') {
      selectedLanguageIndex = 0; // 简体中文
    } else if (locale.languageCode == 'zh' && locale.countryCode == 'TW') {
      selectedLanguageIndex = 1; // 繁体中文
    } else {
      selectedLanguageIndex = 2; // English
    }
    update();
  }

  void updateThemeIndex(int index) {
    selectedThemeIndex = index;
    update();
    themeService.saveTheme(index);
  }

  void updateLanguageIndex(int index) {
    selectedLanguageIndex = index;
    update();
    localizationService.changeLocale(SettingController.languageOptions[index]);
  }

  Future<void> fetchUserProfile() async {
    try {
      userProfile = await provider.getUserProfile();
      update();
    } catch (e) {
      // 可加错误提示
    }
  }

  Future<void> logout() async {
    showDialog(
      context: Get.context!,
      builder: (context) => CustomAlertDialog(
        title: '确认退出'.tr,
        description: '退出后需要重新登录'.tr,
        confirmButtonText: '退出'.tr,
        confirmButtonColor: const Color.fromARGB(255, 239, 72, 60),
        onConfirm: () {
          final box = GetStorage();
          if (box.hasData('token')) {
            box.remove('token');
            Get.offAllNamed(Routes.LOGIN);
          }
        },
      ),
    );
  }
}
