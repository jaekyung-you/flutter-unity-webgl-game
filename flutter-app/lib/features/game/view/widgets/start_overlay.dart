import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';

class StartOverlay extends StatelessWidget {
  const StartOverlay({super.key, required this.onStart});

  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface0,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('칼퇴왕',
                style: AppTextStyles.display.copyWith(letterSpacing: 4)),
            const SizedBox(height: AppSpacing.sm),
            Text('← → 로 피하세요!',
                style:
                    AppTextStyles.body.copyWith(color: AppColors.textSecondary)),
            const SizedBox(height: AppSpacing.xl),
            AppButton.primary(
              label: '▶  START',
              onPressed: onStart,
            ),
          ],
        ),
      ),
    );
  }
}
