import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_text_styles.dart';

class GameMoveButton extends StatefulWidget {
  const GameMoveButton({
    super.key,
    required this.label,
    required this.onDown,
    required this.onUp,
  });

  final String label;
  final VoidCallback onDown;
  final VoidCallback onUp;

  @override
  State<GameMoveButton> createState() => _GameMoveButtonState();
}

class _GameMoveButtonState extends State<GameMoveButton> {
  bool _pressing = false;

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (_) {
        setState(() => _pressing = true);
        widget.onDown();
      },
      onPointerUp: (_) {
        setState(() => _pressing = false);
        widget.onUp();
      },
      onPointerCancel: (_) {
        setState(() => _pressing = false);
        widget.onUp();
      },
      child: AnimatedScale(
        scale: _pressing ? 0.92 : 1.0,
        duration: const Duration(milliseconds: 60),
        child: Container(
          width: 96,
          height: 64,
          decoration: BoxDecoration(
            color: _pressing
                ? AppColors.amber.withOpacity(0.2)
                : AppColors.surface1,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            border: Border.all(
              color:
                  _pressing ? AppColors.amber.withOpacity(0.6) : AppColors.divider,
              width: 1.5,
            ),
          ),
          child: Center(
            child: Text(
              widget.label,
              style: AppTextStyles.title.copyWith(
                color: AppColors.textPrimary,
                fontSize: 24,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
