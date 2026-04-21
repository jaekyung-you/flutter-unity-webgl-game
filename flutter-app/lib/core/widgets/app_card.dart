import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';

class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.highlighted = false,
    this.padding = const EdgeInsets.all(AppSpacing.md),
  });

  final Widget child;
  final bool highlighted;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: highlighted ? AppColors.surface1 : AppColors.surface1,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(
          color: highlighted ? AppColors.amber.withOpacity(0.4) : Colors.white12,
          width: highlighted ? 1.5 : 1,
        ),
        boxShadow: highlighted
            ? [BoxShadow(color: AppColors.amber.withOpacity(0.15), blurRadius: 20)]
            : null,
      ),
      child: child,
    );
  }
}
