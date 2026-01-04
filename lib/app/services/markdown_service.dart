import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:extended_image/extended_image.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:markdown_widget/markdown_widget.dart';
import 'package:readaper/app/modules/reading/widgets/image_preview.dart';
import 'package:readaper/app/services/browser_service.dart';
import 'package:readaper/app/modules/reading/controllers/reading_controller.dart';
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

  static Color _codeBackgroundColor() {
    if (Get.isDarkMode) {
      return const Color(0xFF2B2B2B);
    }
    return const Color(0xFFF5F5F5);
  }

  static Color _preBackgroundColor() {
    if (Get.isDarkMode) {
      return const Color(0xFF2B2B2B);
    }
    return const Color(0xFFF5F5F5);
  }

  static Color _imagePlaceholderBackgroundColor() {
    if (Get.isDarkMode) {
      return const Color(0xFF2B2B2B);
    }
    return const Color(0xFFF3F3F3);
  }

  static Color _imagePlaceholderForegroundColor() {
    if (Get.isDarkMode) {
      return const Color(0xFFBDBDBD);
    }
    return const Color(0xFF6B6B6B);
  }

  /// 默认 Markdown 配置
  static MarkdownConfig get defaultConfig {
    return MarkdownConfig(
      configs: [
        LinkConfig(
          onTap: (url) {
            // 点击链接：使用 App 内置浏览器打开
            final link = url.trim();
            if (link.isEmpty) return;
            BrowserService.open(link, title: link);
          },
        ),
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
        CodeConfig(
          style: TextStyle(
            backgroundColor: _codeBackgroundColor(),
          ),
        ),
        PreConfig(
          decoration: BoxDecoration(
            color: _preBackgroundColor(),
            borderRadius: const BorderRadius.all(Radius.circular(4)),
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
        LinkConfig(
          onTap: (url) {
            // 点击链接：使用 App 内置浏览器打开
            final link = url.trim();
            if (link.isEmpty) return;
            BrowserService.open(link, title: link);
          },
        ),
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
        CodeConfig(
          style: TextStyle(
            backgroundColor: _codeBackgroundColor(),
          ),
        ),
        PreConfig(
          decoration: BoxDecoration(
            color: _preBackgroundColor(),
            borderRadius: const BorderRadius.all(Radius.circular(4)),
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
            // 点击图片：优先使用阅读页缓存的图片列表做预览，实现左右滑动浏览
            var urls = <String>[url];
            var initialIndex = 0;

            try {
              final controller = Get.find<ReadingController>();
              final list = controller.imageUrls.toList();
              if (list.isNotEmpty) {
                urls = list;
                final index = urls.indexOf(url);
                if (index >= 0) {
                  initialIndex = index;
                }
              }
            } catch (_) {}

            if (urls.isEmpty) {
              // 极端兜底：至少保证有一张图可预览
              urls = [url];
            }

            if (initialIndex < 0 || initialIndex >= urls.length) {
              // 极端兜底：避免初始索引越界
              initialIndex = 0;
            }

            showDialog(
              context: Get.context!,
              builder: (_) => ImagePreviewDialog(
                urls: urls,
                initialIndex: initialIndex,
              ),
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
        color: _imagePlaceholderForegroundColor(),
        size: 30,
      ),
    );
  }

  /// 图片加载失败占位
  static Widget _buildImageFailed() {
    return Container(
      color: _imagePlaceholderBackgroundColor(),
      height: _imageFailedHeight,
      alignment: Alignment.center,
      child: Icon(
        Icons.broken_image,
        size: 30,
        color: _imagePlaceholderForegroundColor(),
      ),
    );
  }
}
