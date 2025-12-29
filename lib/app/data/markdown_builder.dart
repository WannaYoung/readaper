import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:markdown_widget/markdown_widget.dart';
import 'package:get/get.dart';
import 'package:readaper/app/widgets/image_preview.dart';
import '../data/models/reading_settings.dart';

/// 根据阅读设置构建Markdown配置
class MarkdownBuilder {
  /// 获取Markdown配置
  static MarkdownConfig getMarkdownConfig(ReadingSettings settings) {
    return MarkdownConfig(
      configs: [
        PConfig(
          textStyle: TextStyle(
            height: settings.lineHeight,
            fontSize: settings.bodyFontSize,
          ),
        ),
        H1Config(
          style: TextStyle(
            fontSize: settings.headingFontSize,
            fontWeight: FontWeight.bold,
          ),
        ),
        H2Config(
          style: TextStyle(
            fontSize: settings.headingFontSize - 4,
            fontWeight: FontWeight.bold,
          ),
        ),
        H3Config(
          style: TextStyle(
            fontSize: settings.headingFontSize - 6,
            fontWeight: FontWeight.bold,
          ),
        ),
        const CodeConfig(
          style: TextStyle(
            backgroundColor: Color(0xFFF5F5F5),
          ),
        ),
        const PreConfig(
          decoration: BoxDecoration(
            color: Color(0xFFF5F5F5),
            borderRadius: BorderRadius.all(Radius.circular(4)),
          ),
        ),
        ImgConfig(
          builder: (url, attributes) {
            return GestureDetector(
              onTap: () {
                showDialog(
                  context: Get.context!,
                  builder: (_) => ImagePreviewDialog(url: url),
                );
              },
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: ExtendedImage.network(
                    url,
                    cache: true,
                    loadStateChanged: (ExtendedImageState state) {
                      if (state.extendedImageLoadState == LoadState.loading) {
                        return Container(
                          height: 100,
                          alignment: Alignment.center,
                          child: LoadingAnimationWidget.discreteCircle(
                              color: const Color.fromARGB(255, 67, 67, 67),
                              size: 30),
                        );
                      }
                      if (state.extendedImageLoadState == LoadState.failed) {
                        return Container(
                          color: Colors.grey[200],
                          height: 60,
                          alignment: Alignment.center,
                          child: const Icon(Icons.broken_image,
                              size: 30, color: Colors.grey),
                        );
                      }
                      return null;
                    },
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
