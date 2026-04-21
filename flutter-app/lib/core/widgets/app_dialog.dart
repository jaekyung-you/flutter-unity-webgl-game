import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../constants/app_text_styles.dart';
import 'app_button.dart';

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
        backgroundColor: AppColors.dialogSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          side: BorderSide(
            color: isDangerous
                ? AppColors.danger.withOpacity(0.5)
                : AppColors.amber.withOpacity(0.3),
            width: 1.5,
          ),
        ),
        title: Text(
          title,
          style: AppTextStyles.title.copyWith(color: AppColors.amber),
        ),
        content: Text(
          message,
          style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(
            AppSpacing.md, 0, AppSpacing.md, AppSpacing.md),
        actions: [
          AppButton.ghost(
            label: cancelLabel,
            onPressed: () => Navigator.of(context).pop(false),
            isFullWidth: false,
          ),
          const SizedBox(width: AppSpacing.sm),
          isDangerous
              ? AppButton.danger(
                  label: confirmLabel,
                  onPressed: () => Navigator.of(context).pop(true),
                )
              : AppButton.primary(
                  label: confirmLabel,
                  onPressed: () => Navigator.of(context).pop(true),
                ),
        ],
      ),
    );
  }
}
