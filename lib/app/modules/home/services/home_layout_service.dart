// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../models/home_layout_settings.dart';

/// 首页布局设置服务
///
/// - 负责加载/保存/应用/重置首页布局设置
/// - 将 HomeController 中与布局设置相关的状态与逻辑下沉，便于控制器瘦身
class HomeLayoutService extends GetxService {
  /// 当前生效的布局设置
  final homeLayoutSettings = HomeLayoutSettings().obs;

  /// 临时布局设置（用于弹窗中实时预览）
  final tempHomeLayoutSettings = HomeLayoutSettings().obs;

  /// 加载首页布局设置
  Future<void> load() async {
    final loaded = await HomeLayoutSettings.load();
    homeLayoutSettings.value = loaded;
    tempHomeLayoutSettings.value = loaded.copy();
  }

  /// 保存首页布局设置
  Future<void> save() async {
    homeLayoutSettings.value = tempHomeLayoutSettings.value.copy();
    await homeLayoutSettings.value.save();
  }

  /// 应用临时布局设置（用于实时预览）
  void applyTemp() {
    homeLayoutSettings.value = tempHomeLayoutSettings.value.copy();
  }

  /// 重置临时布局设置为默认值
  void resetTemp() {
    tempHomeLayoutSettings.value = HomeLayoutSettings();
  }
}
