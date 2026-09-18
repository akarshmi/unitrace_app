import 'package:flutter/material.dart';

/// Single source of truth for UniTrace design system colors.
/// Master prompt specification:
/// Primary Brand: #3157D5 (Deep Indigo / Blue), Dark: #2444B0, Light: #E8EDFF
/// Neutrals: Light Bg: #F7F8FC, Surface: #FFFFFF, Elevated: #FFFFFF
/// Text: Primary: #151923, Secondary: #667085, Muted: #98A2B3
/// Borders: #E4E7EC, Divider: #EEF0F4
/// Dark Mode: Dark Bg: #0D1117, Dark Surface: #151B24, Dark Elevated: #1B2330
/// Dark Text: #F5F7FA, Dark Secondary: #AAB2BF, Dark Border: #293241
/// Semantic:
/// Success: #168A5B (Bg: #E8F7F0)
/// Warning: #B7791F (Bg: #FFF7E6)
/// Error: #D64545 (Bg: #FDECEC)
/// Info: #356AE6 (Bg: #EAF0FF)
class AppColors {
  AppColors._();

  // Primary Brand Color (Deep Indigo / Blue)
  static const Color primary = Color(0xFF3157D5);
  static const Color primaryDark = Color(0xFF2444B0);
  static const Color primaryLight = Color(0xFFE8EDFF);
  static const Color onPrimary = Color(0xFFFFFFFF);

  // Light Mode Neutrals
  static const Color backgroundLight = Color(0xFFF7F8FC);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color elevatedLight = Color(0xFFFFFFFF);
  static const Color textPrimaryLight = Color(0xFF151923);
  static const Color textSecondaryLight = Color(0xFF667085);
  static const Color textMutedLight = Color(0xFF98A2B3);
  static const Color borderLight = Color(0xFFE4E7EC);
  static const Color dividerLight = Color(0xFFEEF0F4);

  // Dark Mode Neutrals
  static const Color backgroundDark = Color(0xFF0D1117);
  static const Color surfaceDark = Color(0xFF151B24);
  static const Color elevatedDark = Color(0xFF1B2330);
  static const Color textPrimaryDark = Color(0xFFF5F7FA);
  static const Color textSecondaryDark = Color(0xFFAAB2BF);
  static const Color textMutedDark = Color(0xFF6C7789);
  static const Color borderDark = Color(0xFF293241);
  static const Color dividerDark = Color(0xFF1F2734);

  // Semantic Colors
  // Success (Verified, Returned, Completed, Item received)
  static const Color success = Color(0xFF168A5B);
  static const Color successBg = Color(0xFFE8F7F0);
  static const Color successBorder = Color(0xFFA3E2C7);

  // Warning (Pending, Awaiting verification, Awaiting Security, Attention required)
  static const Color warning = Color(0xFFB7791F);
  static const Color warningBg = Color(0xFFFFF7E6);
  static const Color warningBorder = Color(0xFFFCE1A6);

  // Error (Rejected, Failed, Invalid input, Server errors, Destructive actions)
  static const Color error = Color(0xFFD64545);
  static const Color errorBg = Color(0xFFFDECEC);
  static const Color errorBorder = Color(0xFFF8B8B8);

  // Info / Potential Match (Potential Match, Information, System updates)
  static const Color info = Color(0xFF356AE6);
  static const Color infoBg = Color(0xFFEAF0FF);
  static const Color infoBorder = Color(0xFFBFD2FE);

  // Backward compatibility getters for existing code referencing navy/amber tokens
  static const Color navyPrimary = primary;
  static const Color navySurface = primaryDark;
  static const Color accentAmber = warning;
  static const Color amberLight = warningBg;
  static const Color slateSubtle = Color(0xFFF1F3F9);
  static const Color textBody = textPrimaryLight;
  static const Color textPrimary = textPrimaryLight;
  static const Color textMuted = textSecondaryLight;
  static const Color borderDivider = borderLight;
  static const Color onNavyPrimary = onPrimary;
  static const Color onAccentAmber = Color(0xFFFFFFFF);

  // Status pills
  static const Color statusOpenBg = Color(0xFFE8F7F0);
  static const Color statusOpenText = Color(0xFF168A5B);
  static const Color statusClosedBg = Color(0xFFF1F3F9);
  static const Color statusClosedText = Color(0xFF667085);
  static const Color statusMatchedBg = Color(0xFFEAF0FF);
  static const Color statusMatchedText = Color(0xFF356AE6);
  static const Color statusClaimedBg = Color(0xFFFFF7E6);
  static const Color statusClaimedText = Color(0xFFB7791F);

  // Type Badges
  static const Color typeLostBg = Color(0xFFEAF0FF);
  static const Color typeLostText = Color(0xFF3157D5);
  static const Color typeFoundBg = Color(0xFFE8F7F0);
  static const Color typeFoundText = Color(0xFF168A5B);
}
