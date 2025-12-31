import 'package:get/get.dart';

/// 侧边栏手势控制器
///
/// - 只负责侧边栏开合比例与手势拖拽逻辑
/// - 不包含任何业务筛选逻辑，避免与 HomeController 耦合
class SidebarGestureController extends GetxController {
  /// 侧边栏打开比例：0=完全关闭，1=完全打开
  final openRatio = 0.0.obs;

  /// 是否正在拖拽
  final isDragging = false.obs;

  /// 是否处于“打开状态”（由 openRatio 推导）
  bool get isOpen => openRatio.value > 0;

  void open() {
    isDragging.value = false;
    openRatio.value = 1.0;
  }

  void close() {
    isDragging.value = false;
    openRatio.value = 0.0;
  }

  void toggle() {
    if (isOpen) {
      close();
      return;
    }
    open();
  }

  void onHorizontalDragStart() {
    // 开始拖拽：禁用吸附动画，侧边栏位置完全跟随手势
    isDragging.value = true;
  }

  void onHorizontalDragUpdate({
    required double deltaDx,
    required double sidebarWidth,
  }) {
    if (sidebarWidth <= 0) return;

    // deltaDx > 0 右滑打开；deltaDx < 0 左滑关闭
    final next =
        (openRatio.value + (deltaDx / sidebarWidth)).clamp(0.0, 1.0).toDouble();
    openRatio.value = next;
  }

  void onHorizontalDragEnd({
    required double velocityDx,
  }) {
    // 结束拖拽：根据速度/比例吸附到全开或全关
    isDragging.value = false;

    const double flingVelocity = 500;
    if (velocityDx > flingVelocity) {
      open();
      return;
    }
    if (velocityDx < -flingVelocity) {
      close();
      return;
    }

    if (openRatio.value >= 0.5) {
      open();
    } else {
      close();
    }
  }
}
