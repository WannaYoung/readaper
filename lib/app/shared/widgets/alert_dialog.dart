import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomAlertDialog extends StatelessWidget {
  final String title;
  final String description;
  final String confirmButtonText;
  final Color confirmButtonColor;
  final VoidCallback? onConfirm;

  const CustomAlertDialog({
    super.key,
    required this.title,
    required this.description,
    required this.confirmButtonText,
    required this.confirmButtonColor,
    this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      elevation: 8.0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              description,
              style: TextStyle(
                fontSize: 15,
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
                      border: Border.all(
                          color: const Color.fromARGB(186, 137, 137, 137)),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Center(
                      child: Text(
                        'cancel'.tr,
                      ),
                    ),
                  ),
                )),
                const SizedBox(width: 8),
                Expanded(
                    child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop();
                    if (onConfirm != null) onConfirm!();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: confirmButtonColor,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Center(
                      child: Text(
                        confirmButtonText,
                      ),
                    ),
                  ),
                )),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
