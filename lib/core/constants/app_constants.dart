import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

export '../theme/app_theme.dart';

/// Application-wide constants
class AppConstants {
  AppConstants._();

  static const String appName = 'UniTrace';
  static const String appTagline = 'Campus Lost & Found Platform';
  static const String defaultBaseUrl = 'http://localhost:8081';

  // Quick preset URLs for testing
  static const String presetLocalhost = 'http://localhost:8081';
  static const String presetAndroidEmulator = 'http://10.0.2.2:8081';
  static const String presetLan = 'http://192.168.1.100:8081';
}

// Global convenience aliases
const String kDefaultBaseUrl = AppConstants.defaultBaseUrl;

const Color kPrimaryNavy = AppColors.navyPrimary;
const Color kNavySurface = AppColors.navySurface;
const Color kAccentAmber = AppColors.accentAmber;
const Color kAmberLight = AppColors.amberLight;
const Color kBackgroundLight = AppColors.backgroundLight;
const Color kSurfaceLight = AppColors.surfaceLight;
const Color kTextPrimary = AppColors.textPrimary;
const Color kTextBody = AppColors.textBody;
const Color kTextMuted = AppColors.textMuted;
const Color kBorderColor = AppColors.borderDivider;
const Color kSuccessGreen = AppColors.success;
const Color kErrorRed = AppColors.error;
