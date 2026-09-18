import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Centralized Typography tokens for UniTrace.
/// Master prompt specifications:
/// - Display / Hero: 32-48px, Weight: 700 (Landing page only)
/// - Page Title: 28px, Weight: 700, Line height: 1.2
/// - Section Title: 22px, Weight: 650-700
/// - Card Title: 17-18px, Weight: 600
/// - Body: 14-16px, Weight: 400, Line height: 1.5
/// - Secondary: 13-14px, Weight: 400
/// - Caption: 11-12px, Weight: 500 (timestamps, metadata, small labels)
/// - Button: 14-15px, Weight: 600
class AppTypography {
  AppTypography._();

  static const String fontFamily = 'Inter';

  // Hero Display (32-48px, 700)
  static const TextStyle heroDisplay = TextStyle(
    fontFamily: fontFamily,
    fontSize: 36,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.8,
    height: 1.15,
    color: AppColors.textPrimaryLight,
  );

  // Page Title (28px, 700, height 1.2)
  static const TextStyle pageTitle = TextStyle(
    fontFamily: fontFamily,
    fontSize: 28,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
    height: 1.2,
    color: AppColors.textPrimaryLight,
  );

  // Section Title (22px, 650/700)
  static const TextStyle sectionTitle = TextStyle(
    fontFamily: fontFamily,
    fontSize: 22,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.3,
    height: 1.25,
    color: AppColors.textPrimaryLight,
  );

  // Card Title (17-18px, 600)
  static const TextStyle cardTitle = TextStyle(
    fontFamily: fontFamily,
    fontSize: 17,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.2,
    height: 1.3,
    color: AppColors.textPrimaryLight,
  );

  // Body (14-16px, 400, height 1.5)
  static const TextStyle body = TextStyle(
    fontFamily: fontFamily,
    fontSize: 15,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    height: 1.5,
    color: AppColors.textPrimaryLight,
  );

  static const TextStyle bodySmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    height: 1.45,
    color: AppColors.textPrimaryLight,
  );

  // Secondary Text (13-14px, 400)
  static const TextStyle secondary = TextStyle(
    fontFamily: fontFamily,
    fontSize: 13,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    height: 1.4,
    color: AppColors.textSecondaryLight,
  );

  // Caption (11-12px, 500)
  static const TextStyle caption = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.2,
    height: 1.35,
    color: AppColors.textSecondaryLight,
  );

  // Button (14-15px, 600)
  static const TextStyle button = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
    height: 1.2,
    color: Colors.white,
  );
}
