import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class ThemeService extends GetxService {
  static const _key = 'themeIndex';
  final _box = GetStorage();

  // 主题色列表
  static final themes = [
    ThemeData(
      brightness: Brightness.light,
      fontFamily: 'NotoSerifSC',
      primaryColor: const Color(0xFF000000),
      scaffoldBackgroundColor: const Color(0xFFFBFBFB),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFFFBFBFB),
        foregroundColor: Colors.black,
        elevation: 0.5,
      ),
      colorScheme: ColorScheme.fromSeed(seedColor: Color(0xFF000000)),
    ),
    ThemeData(
      brightness: Brightness.light,
      fontFamily: 'NotoSerifSC',
      primaryColor: const Color(0xFFF7B045),
      scaffoldBackgroundColor: const Color(0xFFFFF9EA),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFFFFF9EA),
        foregroundColor: Colors.black,
        elevation: 0.5,
      ),
      colorScheme: ColorScheme.fromSeed(seedColor: Color(0xFFF7B045)),
    ),
    ThemeData(
      brightness: Brightness.dark,
      fontFamily: 'NotoSerifSC',
      primaryColor: const Color(0xFF323232),
      scaffoldBackgroundColor: const Color(0xFF232323),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF232323),
        foregroundColor: Colors.white,
        elevation: 0.5,
      ),
      colorScheme: ColorScheme.fromSeed(
          seedColor: Color(0xFF323232), brightness: Brightness.dark),
    ),
  ];

  int get themeIndex => _box.read(_key) ?? 0;

  ThemeData get currentTheme => themes[themeIndex];

  void saveTheme(int index) {
    _box.write(_key, index);
    Get.changeTheme(themes[index]);
  }
}
