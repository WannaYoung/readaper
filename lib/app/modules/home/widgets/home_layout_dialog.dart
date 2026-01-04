import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/home_controller.dart';
import '../models/home_layout_settings.dart';

class HomeLayoutDialog extends StatelessWidget {
  final HomeController controller;

  const HomeLayoutDialog({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.fromLTRB(30, 8, 30, 24),
      child: PopScope(
        onPopInvoked: (_) {
          controller.saveHomeLayoutSettings();
        },
        child: Obx(() {
          final selectedLayoutType =
              controller.tempHomeLayoutSettings.value.layoutType;
          final showPreviewImage =
              controller.tempHomeLayoutSettings.value.showPreviewImage;
          final showSummary =
              controller.tempHomeLayoutSettings.value.showSummary;
          final titleFontSize =
              controller.tempHomeLayoutSettings.value.titleFontSize;

          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 顶部拖拽条
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
              Text(
                'layoutStyle'.tr,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: theme.textTheme.titleLarge?.color,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(2, (index) {
                  final type = index == 0
                      ? HomeLayoutSettings.layoutTypeList
                      : HomeLayoutSettings.layoutTypeWaterfall;
                  final textKey = index == 0 ? 'layoutList' : 'layoutWaterfall';
                  final isSelected = selectedLayoutType == type;

                  return Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4),
                      child: GestureDetector(
                        onTap: () {
                          controller.tempHomeLayoutSettings.update((val) {
                            if (val == null) return;
                            val.layoutType = type;
                          });
                          controller.applyTempHomeLayoutSettings();
                        },
                        child: Container(
                          height: 35,
                          decoration: BoxDecoration(
                            color: theme.cardColor,
                            border: isSelected
                                ? Border.all(
                                    color: theme.colorScheme.primary,
                                    width: 1.5,
                                  )
                                : Border.all(color: Colors.transparent),
                            borderRadius: BorderRadius.circular(3),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            index == 0 ? textKey.tr : 'layoutGrid'.tr,
                            style: TextStyle(
                              fontSize: 15,
                              color: isSelected
                                  ? theme.textTheme.bodyLarge?.color
                                  : theme.textTheme.bodyLarge?.color
                                      ?.withAlpha(140),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 18),
              _buildSliderRow(
                title: 'homeTitleSize'.tr,
                value: titleFontSize,
                min: 12,
                max: 20,
                step: 1,
                theme: theme,
                onChanged: (val) {
                  // 实时更新并预览
                  controller.tempHomeLayoutSettings.update((s) {
                    if (s == null) return;
                    s.titleFontSize = val;
                  });
                  controller.applyTempHomeLayoutSettings();
                },
              ),
              const SizedBox(height: 18),
              _buildSwitchRow(
                title: 'previewImage'.tr,
                value: showPreviewImage,
                onChanged: (val) {
                  controller.tempHomeLayoutSettings.update((s) {
                    if (s == null) return;
                    s.showPreviewImage = val;
                  });
                  controller.applyTempHomeLayoutSettings();
                },
              ),
              const SizedBox(height: 8),
              _buildSwitchRow(
                title: 'summary'.tr,
                value: showSummary,
                onChanged: (val) {
                  controller.tempHomeLayoutSettings.update((s) {
                    if (s == null) return;
                    s.showSummary = val;
                  });
                  controller.applyTempHomeLayoutSettings();
                },
              ),
              const SizedBox(height: 5),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildSwitchRow({
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildSliderRow({
    required String title,
    required double value,
    required double min,
    required double max,
    required double step,
    required ThemeData theme,
    required ValueChanged<double> onChanged,
  }) {
    final divisions = ((max - min) / step).round();

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
                  // 使用当前页面主题色，避免依赖全局 context
                  activeTrackColor: theme.colorScheme.primary,
                  inactiveTrackColor: theme.dividerColor.withAlpha(120),
                  thumbColor: theme.colorScheme.primary,
                  overlayColor: theme.colorScheme.primary.withAlpha(40),
                ),
                child: Slider(
                  value: value.clamp(min, max),
                  min: min,
                  max: max,
                  divisions: divisions,
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
