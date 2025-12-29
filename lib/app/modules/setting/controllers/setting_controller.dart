import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:readaper/app/routes/app_pages.dart';
import 'package:readaper/app/shared/widgets/alert_dialog.dart';
import '../providers/setting_provider.dart';
import '../models/user_profile.dart';
import '../../../services/localization_service.dart';
import '../../../services/theme_service.dart';
import '../../../network/api_client.dart';
import '../../../services/bookmark_sync_service.dart';

/// 设置页控制器
///
/// - 负责主题/语言选择
/// - 负责拉取用户信息
/// - 负责退出登录
class SettingController extends GetxController {
  // 主题和语言选项
  static const themeColors = [
    Color(0xFFFBFBFB),
    Color(0xFFFFF9EA),
    Color(0xFF323232),
  ];
  static const languageOptions = ['简体中文', '繁体中文', 'English'];

  final selectedThemeIndex = 0.obs;
  final selectedLanguageIndex = 0.obs;
  final userProfile = Rxn<UserProfile>();
  final SettingProvider provider = SettingProvider();
  final LocalizationService localizationService = LocalizationService();
  final ThemeService themeService = ThemeService();

  // 同步设置
  static const syncTimeframeMinutes =
      BookmarkSyncService.timeframeOptionsMinutes;
  final autoSyncEnabled = false.obs;
  final selectedSyncTimeframeIndex = 0.obs;
  final lastSyncText = ''.obs;
  final nextSyncText = ''.obs;
  final syncRunning = false.obs;

  final BookmarkSyncService _syncService = BookmarkSyncService();

  @override
  void onInit() {
    super.onInit();
    selectedThemeIndex.value = themeService.themeIndex;
    // 初始化语言选中项
    _initSelectedLanguageIndex();
    // 拉取用户信息
    fetchUserProfile();

    // 初始化同步设置
    _initSyncSettings();
  }

  void _initSyncSettings() {
    final minutes = _syncService.autoSyncMinutes;
    autoSyncEnabled.value = minutes > 0;
    final index = syncTimeframeMinutes.indexOf(minutes);
    selectedSyncTimeframeIndex.value = index >= 0 ? index : 0;
    _refreshSyncTimeText();
  }

  /// 将分钟数映射为翻译 key
  ///
  /// - 用于同步频率选项展示
  String getSyncTimeframeLabelKeyByMinutes(int minutes) {
    switch (minutes) {
      case 0:
        return 'manual';
      case 60:
        return 'hour1';
      case 360:
        return 'hour6';
      case 720:
        return 'hour12';
      case 1440:
        return 'day1';
      default:
        return 'manual';
    }
  }

  void _refreshSyncTimeText() {
    lastSyncText.value = _formatDateTime(_syncService.lastSyncAt);
    nextSyncText.value = _formatDateTime(_syncService.nextSyncAt);
  }

  String _formatDateTime(DateTime? value) {
    if (value == null) return '-';
    final dt = value.toLocal();
    String two(int n) => n.toString().padLeft(2, '0');
    return '${dt.year}-${two(dt.month)}-${two(dt.day)} ${two(dt.hour)}:${two(dt.minute)}';
  }

  void updateSyncTimeframeIndex(int index) {
    if (index < 0 || index >= syncTimeframeMinutes.length) return;
    selectedSyncTimeframeIndex.value = index;
    final minutes = syncTimeframeMinutes[index];
    if (minutes <= 0) {
      // 选择“手动”：关闭自动同步
      autoSyncEnabled.value = false;
      _syncService.setAutoSyncEnabled(false);
      _syncService.setAutoSyncMinutes(0);
    } else {
      // 选择“非手动”：视为开启自动同步
      autoSyncEnabled.value = true;
      _syncService.setAutoSyncEnabled(true);
      _syncService.setAutoSyncMinutes(minutes);
    }
    _refreshSyncTimeText();
  }

  Future<void> syncNow() async {
    if (syncRunning.value) return;
    syncRunning.value = true;
    try {
      await _syncService.syncNow();
      _refreshSyncTimeText();
      Get.snackbar('success'.tr, 'syncCompleted'.tr);
    } catch (e) {
      Get.snackbar('failed'.tr, e.toString());
    } finally {
      syncRunning.value = false;
    }
  }

  void _initSelectedLanguageIndex() {
    Locale locale = Get.locale ?? localizationService.getCurrentLocale();
    if (locale.languageCode == 'zh' && locale.countryCode == 'CN') {
      selectedLanguageIndex.value = 0; // 简体中文
    } else if (locale.languageCode == 'zh' && locale.countryCode == 'TW') {
      selectedLanguageIndex.value = 1; // 繁体中文
    } else {
      selectedLanguageIndex.value = 2; // English
    }
  }

  void updateThemeIndex(int index) {
    selectedThemeIndex.value = index;
    // 持久化主题设置
    themeService.saveTheme(index);
  }

  /// 更新语言
  void updateLanguageIndex(int index) {
    selectedLanguageIndex.value = index;
    localizationService.changeLocale(SettingController.languageOptions[index]);
  }

  /// 拉取用户信息
  Future<void> fetchUserProfile() async {
    try {
      userProfile.value = await provider.getUserProfile();
    } on ApiException catch (e) {
      Get.snackbar('failed'.tr, e.message);
    } catch (e) {
      Get.snackbar('failed'.tr, e.toString());
    }
  }

  /// 退出登录
  Future<void> logout() async {
    showDialog(
      context: Get.context!,
      builder: (context) => CustomAlertDialog(
        title: 'confirmLogout'.tr,
        description: 'logoutNeedRelogin'.tr,
        confirmButtonText: 'exit'.tr,
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
