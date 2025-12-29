import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';

class LocalizationService extends GetxService {
  static final langs = [
    '简体中文',
    '繁体中文',
    'English',
  ];

  static final locales = [
    const Locale('zh', 'CN'),
    const Locale('zh', 'TW'),
    const Locale('en', 'US'),
  ];

  final _box = GetStorage();
  final _key = 'locale';

  /// 获取当前Locale
  Locale getCurrentLocale() {
    String? code = _box.read(_key);
    if (code == 'zh_CN') return const Locale('zh', 'CN');
    if (code == 'zh_TW') return const Locale('zh', 'TW');
    if (code == 'en_US') return const Locale('en', 'US');
    return _getLocaleFromDevice();
  }

  /// 根据设备语言自动匹配
  Locale _getLocaleFromDevice() {
    final deviceLocale = Get.deviceLocale;
    if (deviceLocale == null) return const Locale('en', 'US');
    if (deviceLocale.languageCode == 'zh') {
      if (deviceLocale.countryCode == 'TW' ||
          deviceLocale.scriptCode == 'Hant') {
        return const Locale('zh', 'TW');
      }
      return const Locale('zh', 'CN');
    }
    return const Locale('en', 'US');
  }

  /// 切换语言并持久化
  void changeLocale(String lang) {
    Locale locale;
    switch (lang) {
      case '简体中文':
        locale = const Locale('zh', 'CN');
        _box.write(_key, 'zh_CN');
        break;
      case '繁体中文':
        locale = const Locale('zh', 'TW');
        _box.write(_key, 'zh_TW');
        break;
      case 'English':
      default:
        locale = const Locale('en', 'US');
        _box.write(_key, 'en_US');
        break;
    }
    Get.updateLocale(locale);
  }
}
