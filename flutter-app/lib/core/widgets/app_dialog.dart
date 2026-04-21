import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';

class AppDialog {
  static Future<bool?> show({
    required BuildContext context,
    required String title,
    required String message,
    String confirmLabel = '확인',
    String cancelLabel = '취소',
    bool isDangerous = false,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          side: const BorderSide(color: Colors.white24),
        ),
        title: Text(
          title,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        content: Text(
          message,
          style: const TextStyle(color: Colors.white70, fontSize: 15),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(cancelLabel, style: const TextStyle(color: Colors.white54, fontSize: 15)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: isDangerous ? AppColors.danger : AppColors.amber,
              foregroundColor: isDangerous ? Colors.white : AppColors.background,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              ),
              elevation: 0,
            ),
            child: Text(confirmLabel, style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
