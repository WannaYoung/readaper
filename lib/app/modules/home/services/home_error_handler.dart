// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../../../network/api_client.dart';

/// 首页错误处理器
///
/// - 统一封装 try-catch 逻辑
/// - 默认异常提示走 Snackbar
/// - 允许调用方传入自定义 onError/onFinally
class HomeErrorHandler extends GetxService {
  /// 展示错误提示
  void showError(Object e) {
    if (e is ApiException) {
      Get.snackbar('failed'.tr, e.message);
      return;
    }
    Get.snackbar('failed'.tr, e.toString());
  }

  /// 统一异常捕获包装
  Future<T?> guard<T>(
    Future<T> Function() action, {
    void Function(Object e)? onError,
    Future<void> Function()? onFinally,
  }) async {
    try {
      return await action();
    } catch (e) {
      if (onError != null) {
        onError(e);
      } else {
        showError(e);
      }
      return null;
    } finally {
      if (onFinally != null) {
        await onFinally();
      }
    }
  }
}
