import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:extended_image/extended_image.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:markdown_widget/markdown_widget.dart';
import 'package:readaper/app/modules/reading/widgets/image_preview.dart';
import '../modules/reading/models/reading_settings.dart';

/// Markdown 渲染配置服务
///
/// - 提供默认 MarkdownConfig
/// - 支持按阅读设置动态生成 MarkdownConfig
/// - 统一图片渲染（缓存、加载占位、失败占位、点击预览）
class MarkdownService {
  // 图片加载中占位高度
  static const double _imageLoadingHeight = 100;
  // 图片加载失败占位高度
  static const double _imageFailedHeight = 60;
  // 图片圆角
  static const double _imageBorderRadius = 4;

  /// 默认 Markdown 配置
  static MarkdownConfig get defaultConfig {
    return MarkdownConfig(
      configs: [
        const PConfig(
          textStyle: TextStyle(
            height: 1.8,
            fontSize: 17,
          ),
        ),
        const H1Config(
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const H2Config(
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const H3Config(
          style: TextStyle(
            fontSize: 18,
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
        _buildImageConfig(),
      ],
    );
  }

  /// 根据阅读设置生成 Markdown 配置
  static MarkdownConfig configForSettings(ReadingSettings settings) {
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
        _buildImageConfig(),
      ],
    );
  }

  /// 构建图片渲染配置
  static ImgConfig _buildImageConfig() {
    return ImgConfig(
      builder: (url, attributes) {
        return GestureDetector(
          onTap: () {
            // 点击图片预览
            showDialog(
              context: Get.context!,
              builder: (_) => ImagePreviewDialog(url: url),
            );
          },
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(_imageBorderRadius),
              child: ExtendedImage.network(
                url,
                cache: true,
                loadStateChanged: (ExtendedImageState state) {
                  if (state.extendedImageLoadState == LoadState.loading) {
                    // 图片加载中
                    return _buildImageLoading();
                  }
                  if (state.extendedImageLoadState == LoadState.failed) {
                    // 图片加载失败
                    return _buildImageFailed();
                  }
                  return null;
                },
              ),
            ),
          ),
        );
      },
    );
  }

  /// 图片加载中占位
  static Widget _buildImageLoading() {
    return Container(
      height: _imageLoadingHeight,
      alignment: Alignment.center,
      child: LoadingAnimationWidget.discreteCircle(
          color: const Color.fromARGB(255, 67, 67, 67), size: 30),
    );
  }

  /// 图片加载失败占位
  static Widget _buildImageFailed() {
    return Container(
      color: Colors.grey[200],
      height: _imageFailedHeight,
      alignment: Alignment.center,
      child: const Icon(Icons.broken_image, size: 30, color: Colors.grey),
    );
  }
}
