import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../bloc/game_state.dart';

class GameOverOverlay extends StatelessWidget {
  const GameOverOverlay({
    super.key,
    required this.state,
    required this.onRestart,
    required this.onHome,
  });

  final GameState state;
  final VoidCallback onRestart;
  final VoidCallback onHome;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.85),
      child: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          padding:
              const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: 40),
          decoration: BoxDecoration(
            color: AppColors.surface0,
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            border:
                Border.all(color: AppColors.danger.withOpacity(0.6), width: 2),
            boxShadow: [
              BoxShadow(
                color: AppColors.danger.withOpacity(0.15),
                blurRadius: 24,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('GAME OVER',
                  style: AppTextStyles.heading.copyWith(
                      color: AppColors.danger,
                      letterSpacing: 2,
                      shadows: [
                        Shadow(
                            color: AppColors.danger.withOpacity(0.5),
                            blurRadius: 10)
                      ])),
              const SizedBox(height: AppSpacing.xl),
              _scoreRow('생존 시간', '${state.score}초', Colors.white),
              const SizedBox(height: AppSpacing.sm),
              _scoreRow('회피 성공', '${state.dodgeCount}번', AppColors.success),
              const SizedBox(height: AppSpacing.sm),
              _scoreRow('최고 기록', '${state.bestScore}초', AppColors.amber),
              const SizedBox(height: AppSpacing.xl + AppSpacing.sm),
              AppButton.primary(
                label: '다시 도전',
                onPressed: onRestart,
                isFullWidth: true,
              ),
              const SizedBox(height: AppSpacing.sm),
              AppButton.ghost(
                label: '홈으로',
                onPressed: onHome,
                isFullWidth: true,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _scoreRow(String label, String value, Color valueColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: AppTextStyles.body.copyWith(color: AppColors.textSecondary)),
        Text(value, style: AppTextStyles.title.copyWith(color: valueColor)),
      ],
    );
  }
}
