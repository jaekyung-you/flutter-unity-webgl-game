import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_text_styles.dart';

class HudCircleButton extends StatefulWidget {
  const HudCircleButton({super.key, required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  State<HudCircleButton> createState() => _HudCircleButtonState();
}

class _HudCircleButtonState extends State<HudCircleButton> {
  bool _pressing = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressing = true),
      onTapUp: (_) {
        setState(() => _pressing = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressing = false),
      child: AnimatedScale(
        scale: _pressing ? 0.88 : 1.0,
        duration: const Duration(milliseconds: 80),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: AppColors.surface2,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.divider, width: 1.5),
          ),
          child: Text(
            widget.label,
            style: AppTextStyles.title.copyWith(color: AppColors.textPrimary),
          ),
        ),
      ),
    );
  }
}
