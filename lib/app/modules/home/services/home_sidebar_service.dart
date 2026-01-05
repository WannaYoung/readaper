// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../controllers/sidebar_gesture_controller.dart';

/// 首页侧边栏服务
///
/// - 负责侧边栏开合状态与拖拽手势的代理
/// - 将 HomeController 中大量“转发方法”下沉，减少控制器行数
class HomeSidebarService extends GetxService {
  final SidebarGestureController sidebar;

  HomeSidebarService({required this.sidebar});

  /// 侧边栏打开比例：0=关闭，1=打开
  RxDouble get openRatio => sidebar.openRatio;

  /// 是否正在拖拽
  RxBool get isDragging => sidebar.isDragging;

  /// 是否处于打开状态
  bool get isOpen => sidebar.isOpen;

  /// 打开侧边栏
  void open() => sidebar.open();

  /// 关闭侧边栏
  void close() => sidebar.close();

  /// 切换侧边栏开关
  void toggle() => sidebar.toggle();

  /// 手势开始
  void onHorizontalDragStart() => sidebar.onHorizontalDragStart();

  /// 手势更新
  void onHorizontalDragUpdate({
    required double deltaDx,
    required double sidebarWidth,
  }) {
    sidebar.onHorizontalDragUpdate(
        deltaDx: deltaDx, sidebarWidth: sidebarWidth);
  }

  /// 手势结束
  void onHorizontalDragEnd({required double velocityDx}) {
    sidebar.onHorizontalDragEnd(velocityDx: velocityDx);
  }
}
