import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

enum AppButtonVariant {
  primary,
  secondary,
  tertiary,
  danger,
}

/// Standardized AppButton adhering to the UniTrace Design System.
/// Master prompt specifications:
/// - Primary: Filled primary color (#3157D5)
/// - Secondary: Outlined with border (#E4E7EC)
/// - Tertiary: Text button
/// - Danger: Semantic error color (#D64545)
/// - Minimum 48px comfortable touch target
/// - Radius 10-12px
/// - Clear loading state (no double submission)
class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final AppButtonVariant variant;
  final IconData? icon;
  final double? width;
  final double height;

  // Backward-compatibility constructors/fields
  final bool isSecondary;
  final bool isAccent;

  const AppButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.variant = AppButtonVariant.primary,
    this.isSecondary = false,
    this.isAccent = false,
    this.icon,
    this.width,
    this.height = 48,
  });

  const AppButton.secondary({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
    this.width,
    this.height = 48,
  })  : variant = AppButtonVariant.secondary,
        isSecondary = true,
        isAccent = false;

  const AppButton.danger({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
    this.width,
    this.height = 48,
  })  : variant = AppButtonVariant.danger,
        isSecondary = false,
        isAccent = false;

  const AppButton.tertiary({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
    this.width,
    this.height = 44,
  })  : variant = AppButtonVariant.tertiary,
        isSecondary = false,
        isAccent = false;

  AppButtonVariant get _resolvedVariant {
    if (isSecondary) return AppButtonVariant.secondary;
    return variant;
  }

  @override
  Widget build(BuildContext context) {
    final customColors = context.appColors;

    final resolved = _resolvedVariant;

    Widget buttonWidget;

    switch (resolved) {
      case AppButtonVariant.secondary:
        buttonWidget = OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: customColors.primary,
            side: BorderSide(color: customColors.border, width: 1.2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.button),
            ),
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          ),
          child: _buildContent(customColors.primary),
        );
        break;

      case AppButtonVariant.tertiary:
        buttonWidget = TextButton(
          onPressed: isLoading ? null : onPressed,
          style: TextButton.styleFrom(
            foregroundColor: customColors.primary,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
          ),
          child: _buildContent(customColors.primary),
        );
        break;

      case AppButtonVariant.danger:
        buttonWidget = ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: customColors.error,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.button),
            ),
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          ),
          child: _buildContent(Colors.white),
        );
        break;

      case AppButtonVariant.primary:
      default:
        buttonWidget = ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: customColors.primary,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.button),
            ),
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          ),
          child: _buildContent(Colors.white),
        );
        break;
    }

    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: buttonWidget,
    );
  }

  Widget _buildContent(Color foregroundColor) {
    if (isLoading) {
      return SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(foregroundColor),
        ),
      );
    }

    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 18, color: foregroundColor),
          const SizedBox(width: AppSpacing.xs),
          Text(
            text,
            style: AppTypography.button.copyWith(color: foregroundColor),
          ),
        ],
      );
    }

    return Text(
      text,
      style: AppTypography.button.copyWith(color: foregroundColor),
    );
  }
}
