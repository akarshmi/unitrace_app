import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Standardized AppTextField with persistent top label and 48-52px height.
/// Master prompt specifications:
/// - Label above input field (not floating everywhere)
/// - 48-52px height
/// - 10px radius
/// - Clear border
/// - Strong focus state (#3157D5)
/// - Visible error state (#D64545)
class AppTextField extends StatelessWidget {
  final String label;
  final String? hintText;
  final String? helperText;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final bool obscureText;
  final TextInputType keyboardType;
  final int maxLines;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool enabled;
  final ValueChanged<String>? onChanged;
  final TextInputAction? textInputAction;

  final bool? alignLabelWithHint;

  const AppTextField({
    super.key,
    required this.label,
    this.hintText,
    this.helperText,
    this.controller,
    this.validator,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
    this.prefixIcon,
    this.suffixIcon,
    this.enabled = true,
    this.onChanged,
    this.textInputAction,
    this.alignLabelWithHint,
  });

  @override
  Widget build(BuildContext context) {
    final customColors = context.appColors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: AppTypography.fontFamily,
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: customColors.textPrimary,
            letterSpacing: -0.1,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        TextFormField(
          controller: controller,
          validator: validator,
          obscureText: obscureText,
          keyboardType: keyboardType,
          maxLines: maxLines,
          enabled: enabled,
          onChanged: onChanged,
          textInputAction: textInputAction,
          style: AppTypography.body.copyWith(color: customColors.textPrimary),
          decoration: InputDecoration(
            alignLabelWithHint: alignLabelWithHint,
            hintText: hintText,
            helperText: helperText,
            helperStyle: AppTypography.caption.copyWith(color: customColors.textMuted),
            prefixIcon: prefixIcon,
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: enabled ? customColors.surface : customColors.background,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.input),
              borderSide: BorderSide(color: customColors.border, width: 1),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.input),
              borderSide: BorderSide(color: customColors.border, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.input),
              borderSide: BorderSide(color: customColors.primary, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.input),
              borderSide: BorderSide(color: customColors.error, width: 1.2),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.input),
              borderSide: BorderSide(color: customColors.error, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}
