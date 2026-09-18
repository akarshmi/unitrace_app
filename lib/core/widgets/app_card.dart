import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Standardized card container with 16px radius, thin border, and subtle elevation.
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final Border? border;

  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.md),
    this.onTap,
    this.backgroundColor,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    final customColors = context.appColors;

    final cardContent = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor ?? customColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: border ?? Border.all(color: customColors.border, width: 1),
        boxShadow: AppShadows.card,
      ),
      child: child,
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.card),
          child: cardContent,
        ),
      );
    }

    return cardContent;
  }
}
