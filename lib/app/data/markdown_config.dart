import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:markdown_widget/markdown_widget.dart';
import 'package:extended_image/extended_image.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:readeck/app/widgets/image_preview.dart';

final defaultMarkdownConfig = MarkdownConfig(
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
