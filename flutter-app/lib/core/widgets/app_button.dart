import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';

class AppButton extends StatelessWidget {
  const AppButton._({
    required this.label,
    required this.onPressed,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.borderColor,
    this.isFullWidth = false,
  });

  factory AppButton.primary({
    required String label,
    required VoidCallback onPressed,
    bool isFullWidth = false,
  }) =>
      AppButton._(
        label: label,
        onPressed: onPressed,
        backgroundColor: AppColors.amber,
        foregroundColor: AppColors.background,
        borderColor: Colors.transparent,
        isFullWidth: isFullWidth,
      );

  factory AppButton.ghost({
    required String label,
    required VoidCallback onPressed,
    bool isFullWidth = false,
  }) =>
      AppButton._(
        label: label,
        onPressed: onPressed,
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.amber,
        borderColor: AppColors.amber,
        isFullWidth: isFullWidth,
      );

  factory AppButton.danger({
    required String label,
    required VoidCallback onPressed,
    bool isFullWidth = false,
  }) =>
      AppButton._(
        label: label,
        onPressed: onPressed,
        backgroundColor: AppColors.danger,
        foregroundColor: Colors.white,
        borderColor: Colors.transparent,
        isFullWidth: isFullWidth,
      );

  final String label;
  final VoidCallback onPressed;
  final Color backgroundColor;
  final Color foregroundColor;
  final Color borderColor;
  final bool isFullWidth;

  @override
  Widget build(BuildContext context) {
    final btn = ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
          side: BorderSide(color: borderColor, width: borderColor == Colors.transparent ? 0 : 1.5),
        ),
        elevation: backgroundColor == Colors.transparent ? 0 : 6,
        shadowColor: backgroundColor == Colors.transparent
            ? Colors.transparent
            : backgroundColor.withOpacity(0.4),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, letterSpacing: 1),
      ),
    );

    if (isFullWidth) {
      return SizedBox(width: double.infinity, child: btn);
    }
    return btn;
  }
}
