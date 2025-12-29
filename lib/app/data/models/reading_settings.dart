import 'dart:convert';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class ReadingSettings {
  // 标题文本大小
  double headingFontSize;
  // 正文文本大小
  double bodyFontSize;
  // 页边距
  double pagePadding;
  // 行距
  double lineHeight;

  // 默认值
  static const double defaultHeadingFontSize = 25.0;
  static const double defaultBodyFontSize = 17.0;
  static const double defaultPagePadding = 20.0;
  static const double defaultLineHeight = 1.8;

  // 构造函数
  ReadingSettings({
    this.headingFontSize = defaultHeadingFontSize,
    this.bodyFontSize = defaultBodyFontSize,
    this.pagePadding = defaultPagePadding,
    this.lineHeight = defaultLineHeight,
  });

  // 从JSON构造
  ReadingSettings.fromJson(Map<String, dynamic> json)
      : headingFontSize = json['headingFontSize'] ?? defaultHeadingFontSize,
        bodyFontSize = json['bodyFontSize'] ?? defaultBodyFontSize,
        pagePadding = json['pagePadding'] ?? defaultPagePadding,
        lineHeight = json['lineHeight'] ?? defaultLineHeight;

  // 转换为JSON
  Map<String, dynamic> toJson() => {
        'headingFontSize': headingFontSize,
        'bodyFontSize': bodyFontSize,
        'pagePadding': pagePadding,
        'lineHeight': lineHeight,
      };

  // 保存设置到本地存储
  Future<void> save() async {
    final box = GetStorage();
    await box.write('reading_settings', jsonEncode(toJson()));
  }

  // 从本地存储加载设置
  static Future<ReadingSettings> load() async {
    try {
      final box = GetStorage();
      final String? data = box.read('reading_settings');
      if (data != null && data.isNotEmpty) {
        return ReadingSettings.fromJson(jsonDecode(data));
      }
    } catch (e) {
      Get.snackbar('错误', '加载阅读设置失败');
    }
    return ReadingSettings(); // 返回默认设置
  }

  // 创建副本
  ReadingSettings copy() {
    return ReadingSettings(
      headingFontSize: headingFontSize,
      bodyFontSize: bodyFontSize,
      pagePadding: pagePadding,
      lineHeight: lineHeight,
    );
  }
}
