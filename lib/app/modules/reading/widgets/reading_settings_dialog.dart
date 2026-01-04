import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/reading_controller.dart';

/// 阅读设置弹窗
///
/// - 支持调整标题/正文/页边距/行距
/// - 支持重置与保存
class ReadingSettingsDialog extends StatelessWidget {
  final ReadingController controller;

  const ReadingSettingsDialog({super.key, required this.controller});

  List<_ReadingSettingItem> _buildItems() {
    return [
      _ReadingSettingItem(
        title: 'titleText'.tr,
        min: 18,
        max: 30,
        step: 1.0,
        getValue: () => controller.tempSettings.value.headingFontSize,
        setValue: (value) {
          controller.tempSettings.update((val) {
            val?.headingFontSize = value;
          });
        },
      ),
      _ReadingSettingItem(
        title: 'bodyText'.tr,
        min: 12,
        max: 24,
        step: 1.0,
        getValue: () => controller.tempSettings.value.bodyFontSize,
        setValue: (value) {
          controller.tempSettings.update((val) {
            val?.bodyFontSize = value;
          });
        },
      ),
      _ReadingSettingItem(
        title: 'pageMargin'.tr,
        min: 10,
        max: 40,
        step: 2.0,
        getValue: () => controller.tempSettings.value.pagePadding,
        setValue: (value) {
          controller.tempSettings.update((val) {
            val?.pagePadding = value;
          });
        },
      ),
      _ReadingSettingItem(
        title: 'lineSpacing'.tr,
        min: 1.2,
        max: 2.4,
        step: 0.1,
        getValue: () => controller.tempSettings.value.lineHeight,
        setValue: (value) {
          controller.tempSettings.update((val) {
            val?.lineHeight = value;
          });
        },
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.fromLTRB(30, 8, 30, 24),
      child: PopScope(
        onPopInvoked: (_) {
          controller.saveSettings(showToast: false);
        },
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
                      color: theme.dividerColor.withAlpha(140),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                // 标题 + 重置
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'readingSettings'.tr,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: theme.textTheme.titleLarge?.color,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        controller.resetSettings();
                        controller.applyTempSettings();
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: theme.colorScheme.primary,
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(40, 30),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text('reset'.tr),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                for (final item in _buildItems())
                  _buildSettingItem(
                    title: item.title,
                    value: item.getValue(),
                    min: item.min,
                    max: item.max,
                    step: item.step,
                    onChanged: (value) {
                      item.setValue(value);
                      controller.applyTempSettings();
                    },
                  ),
                const SizedBox(height: 5),
              ],
            )),
      ),
    );
  }

  /// 构建单个设置项（标题 + Slider）
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
                  activeTrackColor: Theme.of(Get.context!).colorScheme.primary,
                  inactiveTrackColor:
                      Theme.of(Get.context!).dividerColor.withAlpha(120),
                  thumbColor: Theme.of(Get.context!).colorScheme.primary,
                  overlayColor:
                      Theme.of(Get.context!).colorScheme.primary.withAlpha(40),
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

class _ReadingSettingItem {
  final String title;
  final double min;
  final double max;
  final double step;
  final double Function() getValue;
  final void Function(double value) setValue;

  _ReadingSettingItem({
    required this.title,
    required this.min,
    required this.max,
    required this.step,
    required this.getValue,
    required this.setValue,
  });
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
