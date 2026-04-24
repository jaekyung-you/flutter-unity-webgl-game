import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_text_styles.dart';

class PauseOverlay extends StatelessWidget {
  const PauseOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl, vertical: AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.surface0,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          border: Border.all(color: AppColors.amber.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('⏸  일시정지',
                style: AppTextStyles.title.copyWith(color: AppColors.amber)),
            const SizedBox(height: AppSpacing.sm),
            Text('계속하려면 ▶ 를 누르세요',
                style:
                    AppTextStyles.caption.copyWith(color: AppColors.textMuted)),
          ],
        ),
      ),
    );
  }
}
