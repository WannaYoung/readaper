import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/reading_controller.dart';

class ReadingSettingsDialog extends StatelessWidget {
  final ReadingController controller;

  const ReadingSettingsDialog({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(30, 8, 30, 24),
      child: Obx(() => Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 顶部拖动条
              Center(
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              // 标题
              Text(
                '阅读设置'.tr,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              _buildSettingItem(
                title: '标题文本'.tr,
                value: controller.tempSettings.value.headingFontSize,
                min: 18,
                max: 30,
                step: 1.0,
                onChanged: (value) {
                  controller.tempSettings.update((val) {
                    val?.headingFontSize = value;
                  });
                  controller.applyTempSettings();
                },
              ),
              _buildSettingItem(
                title: '正文文本'.tr,
                value: controller.tempSettings.value.bodyFontSize,
                min: 12,
                max: 24,
                step: 1.0,
                onChanged: (value) {
                  controller.tempSettings.update((val) {
                    val?.bodyFontSize = value;
                  });
                  controller.applyTempSettings();
                },
              ),
              _buildSettingItem(
                title: '页边距'.tr,
                value: controller.tempSettings.value.pagePadding,
                min: 10,
                max: 40,
                step: 2.0,
                onChanged: (value) {
                  controller.tempSettings.update((val) {
                    val?.pagePadding = value;
                  });
                  controller.applyTempSettings();
                },
              ),
              _buildSettingItem(
                title: '行距'.tr,
                value: controller.tempSettings.value.lineHeight,
                min: 1.2,
                max: 2.4,
                step: 0.1,
                onChanged: (value) {
                  controller.tempSettings.update((val) {
                    val?.lineHeight = value;
                  });
                  controller.applyTempSettings();
                },
              ),
              const SizedBox(height: 5),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () {
                      controller.resetSettings();
                      controller.applyTempSettings();
                    },
                    child: Text('重置'.tr),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      controller.saveSettings();
                      Get.back();
                    },
                    child: Text('保存'.tr),
                  ),
                ],
              ),
            ],
          )),
    );
  }

  Widget _buildSettingItem({
    required String title,
    required double value,
    required double min,
    required double max,
    required Function(double) onChanged,
    double step = 0.5,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 3),
        Row(
          children: [
            Expanded(
              child: SliderTheme(
                data: SliderThemeData(
                  trackHeight: 4,
                  thumbShape: const RoundSliderThumbShape(
                    enabledThumbRadius: 8,
                    elevation: 0,
                  ),
                  overlayShape: const RoundSliderOverlayShape(
                    overlayRadius: 20,
                  ),
                  trackShape: CustomTrackShape(),
                ),
                child: Slider(
                  value: value,
                  min: min,
                  max: max,
                  divisions: ((max - min) / step).round(),
                  onChanged: onChanged,
                ),
              ),
            ),
            const SizedBox(width: 15),
            Text(
              value.toStringAsFixed(step < 1 ? 1 : 0),
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(width: 8),
          ],
        ),
        const SizedBox(height: 10),
      ],
    );
  }
}

class CustomTrackShape extends RoundedRectSliderTrackShape {
  @override
  Rect getPreferredRect({
    required RenderBox parentBox,
    Offset offset = Offset.zero,
    required SliderThemeData sliderTheme,
    bool isEnabled = false,
    bool isDiscrete = false,
  }) {
    final double trackHeight = sliderTheme.trackHeight ?? 2;
    final double trackLeft = offset.dx;
    final double trackTop =
        offset.dy + (parentBox.size.height - trackHeight) / 2;
    final double trackWidth = parentBox.size.width;
    return Rect.fromLTWH(trackLeft, trackTop, trackWidth, trackHeight);
  }
}
