import 'dart:async';

import 'package:get/get.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';

import '../routes/app_pages.dart';
import '../modules/home/controllers/home_controller.dart';

class ShareIntentService extends GetxService {
  static ShareIntentService get to => Get.find<ShareIntentService>();

  final RxnString pendingUrl = RxnString(null);

  StreamSubscription<List<SharedMediaFile>>? _mediaSubscription;

  void init() {
    _initTextStream();
    _loadInitialText();
  }

  void dispose() {
    _mediaSubscription?.cancel();
    _mediaSubscription = null;
  }

  void _initTextStream() {
    _mediaSubscription = ReceiveSharingIntent.instance.getMediaStream().listen(
      (files) {
        _handleIncomingMedia(files);
      },
      onError: (_) {},
    );
  }

  Future<void> _loadInitialText() async {
    try {
      final files = await ReceiveSharingIntent.instance.getInitialMedia();
      _handleIncomingMedia(files);
    } catch (_) {}
  }

  void _handleIncomingMedia(List<SharedMediaFile>? files) {
    if (files == null || files.isEmpty) return;

    for (final file in files) {
      final candidate = file.message ?? file.path;
      final url = _extractFirstUrl(candidate);
      if (url == null) continue;

      pendingUrl.value = url;
      _consumeAndShowIfPossible();
      break;
    }

    // 避免同一条分享在下次启动时再次触发
    ReceiveSharingIntent.instance.reset();
  }

  void _consumeAndShowIfPossible() {
    final url = pendingUrl.value;
    if (url == null || url.trim().isEmpty) return;

    if (Get.context == null) return;

    // 如果首页控制器还没注册，说明还没进入 Home 页面（可能在登录页）
    if (!Get.isRegistered<HomeController>()) {
      return;
    }

    final controller = Get.find<HomeController>();

    // 如果不在首页路由，先跳转到首页，再弹窗
    if (Get.currentRoute != Routes.HOME) {
      Get.offAllNamed(Routes.HOME);
      Future.delayed(const Duration(milliseconds: 250), () {
        if (pendingUrl.value != null) {
          _consumeAndShowIfPossible();
        }
      });
      return;
    }

    pendingUrl.value = null;
    controller.showAddBookmarkDialog(initialUrl: url);
  }

  /// HomeController 首帧后可调用一次，确保登录后也能弹出
  void consumePendingUrlIfAny() {
    _consumeAndShowIfPossible();
  }

  String? _extractFirstUrl(String? text) {
    if (text == null) return null;
    final trimmed = text.trim();
    if (trimmed.isEmpty) return null;

    final reg = RegExp(r'(https?:\/\/[^\s]+)', caseSensitive: false);
    final match = reg.firstMatch(trimmed);
    if (match == null) return null;

    final url = match.group(0);
    if (url == null || url.trim().isEmpty) return null;
    return url.trim();
  }
}
