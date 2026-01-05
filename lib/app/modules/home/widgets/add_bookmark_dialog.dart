// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';

class AddBookmarkDialogResult {
  final String url;
  final String title;

  AddBookmarkDialogResult({required this.url, required this.title});
}

Future<AddBookmarkDialogResult?> showAddBookmarkDialog(
  BuildContext context, {
  String? initialUrl,
}) async {
  final urlController = TextEditingController(text: initialUrl ?? '');
  final titleController = TextEditingController();

  try {
    return await showDialog<AddBookmarkDialogResult>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AddBookmarkDialog(
          urlController: urlController,
          titleController: titleController,
          onConfirm: () async {
            final url = urlController.text.trim();
            final title = titleController.text.trim();
            if (url.isEmpty) {
              Get.snackbar('failed'.tr, 'fillAllFields'.tr);
              return;
            }
            Navigator.of(dialogContext).pop(
              AddBookmarkDialogResult(url: url, title: title),
            );
          },
        );
      },
    );
  } finally {
    Future.delayed(const Duration(milliseconds: 300), () {
      urlController.dispose();
      titleController.dispose();
    });
  }
}

class AddBookmarkDialog extends StatelessWidget {
  final TextEditingController urlController;
  final TextEditingController titleController;
  final Future<void> Function() onConfirm;

  const AddBookmarkDialog({
    super.key,
    required this.urlController,
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
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '新增书签',
              textAlign: TextAlign.left,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: urlController,
              decoration: InputDecoration(
                labelText: 'URL（必填）',
                hintText: 'https://example.com',
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
              keyboardType: TextInputType.url,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                labelText: '标题（可选）',
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
    );
  }
}
