import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../bloc/game_state.dart';
import 'game_move_button.dart';
import 'hud_circle_button.dart';
import 'pause_overlay.dart';

class GameHud extends StatelessWidget {
  const GameHud({
    super.key,
    required this.state,
    required this.onExit,
    required this.onTogglePause,
    required this.onMoveLeftDown,
    required this.onMoveLeftUp,
    required this.onMoveRightDown,
    required this.onMoveRightUp,
  });

  final GameState state;
  final VoidCallback onExit;
  final VoidCallback onTogglePause;
  final VoidCallback onMoveLeftDown;
  final VoidCallback onMoveLeftUp;
  final VoidCallback onMoveRightDown;
  final VoidCallback onMoveRightUp;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    HudCircleButton(label: '←', onTap: onExit),
                    const SizedBox(width: AppSpacing.sm),
                    _buildTimerWidget(state.score),
                  ],
                ),
                _buildLivesDisplay(state.burnoutCurrent, state.burnoutMax),
                HudCircleButton(
                  label: state.isPaused ? '▶' : '⏸',
                  onTap: onTogglePause,
                ),
              ],
            ),
          ),
          if (state.isPaused) const Expanded(child: PauseOverlay()),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg, vertical: AppSpacing.md),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GameMoveButton(
                  label: '◄',
                  onDown: onMoveLeftDown,
                  onUp: onMoveLeftUp,
                ),
                GameMoveButton(
                  label: '►',
                  onDown: onMoveRightDown,
                  onUp: onMoveRightUp,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimerWidget(int seconds) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.surface2,
        borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
        border: Border.all(color: AppColors.amber.withOpacity(0.7), width: 1.5),
        boxShadow: [
          BoxShadow(color: AppColors.amber.withOpacity(0.2), blurRadius: 8),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('$seconds',
              style:
                  AppTextStyles.title.copyWith(fontWeight: FontWeight.w900)),
          Text(' 초',
              style: AppTextStyles.caption
                  .copyWith(color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  Widget _buildLivesDisplay(int current, int max) {
    final livesLeft = max - current;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(max, (index) {
        final isAlive = index < livesLeft;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: Icon(
            isAlive ? Icons.favorite : Icons.favorite_border,
            color: isAlive ? AppColors.danger : AppColors.textMuted,
            size: 22,
          ),
        );
      }),
    );
  }
}
