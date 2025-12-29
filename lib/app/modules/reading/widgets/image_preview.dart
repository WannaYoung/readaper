import 'package:flutter/material.dart';
import 'package:extended_image/extended_image.dart';

/// 图片预览弹窗
///
/// - 支持单击关闭
/// - 支持双击缩放、手势缩放与拖拽
class ImagePreviewDialog extends StatelessWidget {
  final String url;

  const ImagePreviewDialog({super.key, required this.url});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      child: Container(
        color: Colors.black26,
        alignment: Alignment.center,
        child: InteractiveViewer(
          minScale: 1.0,
          maxScale: 5.0,
          child: Center(
            child: ExtendedImage.network(
              url,
              fit: BoxFit.fitWidth,
              width: screenSize.width,
              height: screenSize.height,
              mode: ExtendedImageMode.gesture,
              initGestureConfigHandler: (_) => GestureConfig(
                minScale: 1.0,
                animationMinScale: 0.8,
                maxScale: 5.0,
                animationMaxScale: 6.0,
                speed: 1.0,
                inertialSpeed: 100.0,
                initialScale: 1.0,
                inPageView: false,
                initialAlignment: InitialAlignment.center,
              ),
              onDoubleTap: (state) {
                final pointerDownPosition = state.pointerDownPosition;
                final double? begin = state.gestureDetails?.totalScale;
                double end;
                if (begin == 1) {
                  end = 2.0;
                } else {
                  end = 1;
                }
                state.handleDoubleTap(
                  scale: end,
                  doubleTapPosition: pointerDownPosition,
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
