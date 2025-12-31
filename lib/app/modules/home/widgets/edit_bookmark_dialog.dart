import 'package:flutter/material.dart';
import 'package:get/get.dart';

class EditBookmarkDialog extends StatelessWidget {
  final TextEditingController titleController;
  final Future<void> Function() onConfirm;

  const EditBookmarkDialog({
    super.key,
    required this.titleController,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      backgroundColor:
          theme.appBarTheme.backgroundColor ?? theme.scaffoldBackgroundColor,
      surfaceTintColor: Colors.transparent,
      elevation: 8.0,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'editTitle'.tr,
                textAlign: TextAlign.left,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  labelText: 'title'.tr,
                  filled: true,
                  fillColor: theme.cardColor,
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          border: Border.all(color: theme.primaryColor),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Center(
                          child: Text('cancel'.tr),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: GestureDetector(
                      onTap: onConfirm,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Center(
                          child: Text(
                            'confirm'.tr,
                            style: TextStyle(
                              color: theme.colorScheme.onPrimary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
