import 'package:flutter/material.dart';
import 'package:extended_image/extended_image.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';

/// 图片预览弹窗
///
/// - 支持单击关闭
/// - 支持双击缩放、手势缩放与拖拽
class ImagePreviewDialog extends StatefulWidget {
  final List<String> urls;
  final int initialIndex;

  const ImagePreviewDialog({
    super.key,
    required this.urls,
    this.initialIndex = 0,
  });

  @override
  State<ImagePreviewDialog> createState() => _ImagePreviewDialogState();
}

class _ImagePreviewDialogState extends State<ImagePreviewDialog> {
  late final ExtendedPageController _pageController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex.clamp(0, widget.urls.length - 1);
    _pageController = ExtendedPageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      child: Container(
        color: Colors.black26,
        alignment: Alignment.center,
        child: Stack(
          children: [
            ExtendedImageGesturePageView.builder(
              controller: _pageController,
              itemCount: widget.urls.length,
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              itemBuilder: (context, index) {
                final url = widget.urls[index];
                return GestureDetector(
                  onLongPress: () async {
                    await _saveImage(url);
                  },
                  child: ExtendedImage.network(
                    url,
                    cache: true,
                    fit: BoxFit.contain,
                    mode: ExtendedImageMode.gesture,
                    initGestureConfigHandler: (_) => GestureConfig(
                      minScale: 1.0,
                      animationMinScale: 0.8,
                      maxScale: 5.0,
                      animationMaxScale: 6.0,
                      speed: 1.0,
                      inertialSpeed: 100.0,
                      initialScale: 1.0,
                      inPageView: true,
                      initialAlignment: InitialAlignment.center,
                    ),
                    onDoubleTap: (state) {
                      final pointerDownPosition = state.pointerDownPosition;
                      final double? begin = state.gestureDetails?.totalScale;
                      final end = (begin ?? 1) == 1 ? 2.0 : 1.0;
                      state.handleDoubleTap(
                        scale: end,
                        doubleTapPosition: pointerDownPosition,
                      );
                    },
                  ),
                );
              },
            ),
            Positioned(
              top: MediaQuery.of(context).padding.top + 12,
              right: 12,
              child: IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close, color: Colors.white),
              ),
            ),
            Positioned(
              top: MediaQuery.of(context).padding.top + 18,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black.withAlpha(120),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '${_currentIndex + 1}/${widget.urls.length}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveImage(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode != 200) {
        Get.snackbar('error'.tr, 'downloadFailed'.tr);
        return;
      }

      final tempDir = await getTemporaryDirectory();
      final fileName = 'readaper_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final file = await File('${tempDir.path}/$fileName')
          .writeAsBytes(response.bodyBytes);

      await Share.shareXFiles([XFile(file.path)], subject: 'imageSaved'.tr);
    } catch (e) {
      Get.snackbar('error'.tr, e.toString());
    }
  }
}
