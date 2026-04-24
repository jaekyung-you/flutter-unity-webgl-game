import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_text_styles.dart';

class LoadingOverlay extends StatelessWidget {
  const LoadingOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset('assets/images/game_background.png', fit: BoxFit.cover),
        Container(color: Colors.black.withOpacity(0.6)),
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(color: AppColors.amber),
              const SizedBox(height: AppSpacing.md),
              Text('출근 중...', style: AppTextStyles.body),
            ],
          ),
        ),
      ],
    );
  }
}
