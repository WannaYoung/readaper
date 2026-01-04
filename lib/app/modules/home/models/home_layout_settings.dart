import 'package:get_storage/get_storage.dart';

class HomeLayoutSettings {
  static const String _keyLayoutType = 'home_layout_type';
  static const String _keyShowPreviewImage = 'home_show_preview_image';
  static const String _keyShowSummary = 'home_show_summary';
  static const String _keyTitleFontSize = 'home_title_font_size';

  static const String layoutTypeList = 'list';
  static const String layoutTypeWaterfall = 'waterfall';

  String layoutType;
  bool showPreviewImage;
  bool showSummary;
  double titleFontSize;

  HomeLayoutSettings({
    this.layoutType = layoutTypeList,
    this.showPreviewImage = true,
    this.showSummary = true,
    this.titleFontSize = 17,
  });

  static Future<HomeLayoutSettings> load() async {
    final box = GetStorage();
    final rawLayoutType = box.read(_keyLayoutType);
    final rawShowPreview = box.read(_keyShowPreviewImage);
    final rawShowSummary = box.read(_keyShowSummary);
    final rawTitleFontSize = box.read(_keyTitleFontSize);

    final layoutType = (rawLayoutType is String && rawLayoutType.isNotEmpty)
        ? rawLayoutType
        : layoutTypeList;

    return HomeLayoutSettings(
      layoutType: layoutType,
      showPreviewImage: rawShowPreview is bool ? rawShowPreview : true,
      showSummary: rawShowSummary is bool ? rawShowSummary : true,
      titleFontSize: rawTitleFontSize is num ? rawTitleFontSize.toDouble() : 17,
    );
  }

  Future<void> save() async {
    final box = GetStorage();
    await box.write(_keyLayoutType, layoutType);
    await box.write(_keyShowPreviewImage, showPreviewImage);
    await box.write(_keyShowSummary, showSummary);
    await box.write(_keyTitleFontSize, titleFontSize);
  }

  HomeLayoutSettings copy() {
    return HomeLayoutSettings(
      layoutType: layoutType,
      showPreviewImage: showPreviewImage,
      showSummary: showSummary,
      titleFontSize: titleFontSize,
    );
  }
}
