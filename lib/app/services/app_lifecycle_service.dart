import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../modules/home/controllers/home_controller.dart';
import 'share_intent_service.dart';

class AppLifecycleService extends GetxService with WidgetsBindingObserver {
  Timer? _resumeDebounce;

  void init() {
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    _resumeDebounce?.cancel();
    _resumeDebounce = null;
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) return;

    // 避免短时间内多次触发（例如系统弹窗/权限弹窗）
    _resumeDebounce?.cancel();
    _resumeDebounce = Timer(const Duration(milliseconds: 300), () async {
      // 先消费分享进来的 URL
      if (Get.isRegistered<ShareIntentService>()) {
        ShareIntentService.to.consumePendingUrlIfAny();
      }

      // 再消费剪贴板 URL
      if (Get.isRegistered<HomeController>()) {
        await Get.find<HomeController>().consumeClipboardUrlIfAny();
      }
    });
  }
}
