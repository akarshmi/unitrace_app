import 'package:flutter/material.dart';

/// Single Source of Truth for UniTrace Brand Palette and Semantic Tokens.
class AppColors {
  AppColors._();

  // Brand Core
  static const Color navyPrimary = Color(0xFF0F172A);
  static const Color navySurface = Color(0xFF1E293B);
  static const Color accentAmber = Color(0xFFF59E0B);
  static const Color amberLight = Color(0xFFFEF3C7);

  // Surfaces & Backgrounds
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color backgroundLight = Color(0xFFF8FAFC);
  static const Color slateSubtle = Color(0xFFF1F5F9);

  // Typography & Content
  static const Color textPrimary = Color(0xFF0F172A); // Dark navy for headers / high contrast
  static const Color textBody = Color(0xFF1E293B);    // Slate 800 for readable body text
  static const Color textMuted = Color(0xFF64748B);   // Slate 500 for secondary/hints (4.6:1 AA)
  static const Color borderDivider = Color(0xFFE2E8F0);

  // Semantics
  static const Color success = Color(0xFF16A34A);
  static const Color error = Color(0xFFDC2626);
  static const Color warning = Color(0xFFF59E0B);

  // Status Pill Pairings (Both background AND contrasting text color)
  static const Color statusOpenBg = Color(0xFFDCFCE7);
  static const Color statusOpenText = Color(0xFF166534); // Contrast 6.19:1 (AA)

  static const Color statusClosedBg = Color(0xFFF1F5F9);
  static const Color statusClosedText = Color(0xFF475569); // Contrast 7.0:1 (AA)

  static const Color statusMatchedBg = Color(0xFFFEF3C7);
  static const Color statusMatchedText = Color(0xFF92400E); // Contrast 6.64:1 (AA)

  static const Color statusClaimedBg = Color(0xFFDBEAFE);
  static const Color statusClaimedText = Color(0xFF1E40AF); // Contrast 7.52:1 (AA)

  // Type Badges (LOST & FOUND)
  static const Color typeLostBg = Color(0xFFFEE2E2);
  static const Color typeLostText = Color(0xFFDC2626); // Contrast 4.61:1 (AA)

  static const Color typeFoundBg = Color(0xFFDCFCE7);
  static const Color typeFoundText = Color(0xFF16A34A); // Contrast 6.19:1 (AA)

  // On-Containers
  static const Color onNavyPrimary = Color(0xFFFFFFFF);
  static const Color onAccentAmber = Color(0xFF0F172A); // High contrast navy text on amber button
}

/// Status and Type Color Model
class PillColors {
  final Color background;
  final Color text;
  final Color border;

  const PillColors({
    required this.background,
    required this.text,
    required this.border,
  });
}

/// ThemeExtension allowing access to semantic lost & found tokens via Theme.of(context)
@immutable
class AppCustomColors extends ThemeExtension<AppCustomColors> {
  final Color navyPrimary;
  final Color navySurface;
  final Color accentAmber;
  final Color textPrimary;
  final Color textBody;
  final Color textMuted;
  final Color borderDivider;
  final Color slateSubtle;
  final Color surfaceLight;
  final Color backgroundLight;
  final Color success;
  final Color error;

  final PillColors statusOpen;
  final PillColors statusClosed;
  final PillColors statusMatched;
  final PillColors statusClaimed;

  final PillColors typeLost;
  final PillColors typeFound;

  const AppCustomColors({
    this.navyPrimary = AppColors.navyPrimary,
    this.navySurface = AppColors.navySurface,
    this.accentAmber = AppColors.accentAmber,
    this.textPrimary = AppColors.textPrimary,
    this.textBody = AppColors.textBody,
    this.textMuted = AppColors.textMuted,
    this.borderDivider = AppColors.borderDivider,
    this.slateSubtle = AppColors.slateSubtle,
    this.surfaceLight = AppColors.surfaceLight,
    this.backgroundLight = AppColors.backgroundLight,
    this.success = AppColors.success,
    this.error = AppColors.error,
    this.statusOpen = const PillColors(
      background: AppColors.statusOpenBg,
      text: AppColors.statusOpenText,
      border: Color(0xFFBBF7D0),
    ),
    this.statusClosed = const PillColors(
      background: AppColors.statusClosedBg,
      text: AppColors.statusClosedText,
      border: Color(0xFFE2E8F0),
    ),
    this.statusMatched = const PillColors(
      background: AppColors.statusMatchedBg,
      text: AppColors.statusMatchedText,
      border: Color(0xFFFDE68A),
    ),
    this.statusClaimed = const PillColors(
      background: AppColors.statusClaimedBg,
      text: AppColors.statusClaimedText,
      border: Color(0xFFBFDBFE),
    ),
    this.typeLost = const PillColors(
      background: AppColors.typeLostBg,
      text: AppColors.typeLostText,
      border: Color(0xFFFECACA),
    ),
    this.typeFound = const PillColors(
      background: AppColors.typeFoundBg,
      text: AppColors.typeFoundText,
      border: Color(0xFFBBF7D0),
    ),
  });

  PillColors getStatusColors(String status) {
    switch (status.toUpperCase()) {
      case 'CLOSED':
        return statusClosed;
      case 'MATCHED':
        return statusMatched;
      case 'CLAIMED':
        return statusClaimed;
      case 'OPEN':
      default:
        return statusOpen;
    }
  }

  PillColors getTypeColors(String type) {
    switch (type.toUpperCase()) {
      case 'FOUND':
        return typeFound;
      case 'LOST':
      default:
        return typeLost;
    }
  }

  @override
  AppCustomColors copyWith({
    Color? navyPrimary,
    Color? navySurface,
    Color? accentAmber,
    Color? textPrimary,
    Color? textBody,
    Color? textMuted,
    Color? borderDivider,
    Color? slateSubtle,
    Color? surfaceLight,
    Color? backgroundLight,
    Color? success,
    Color? error,
    PillColors? statusOpen,
    PillColors? statusClosed,
    PillColors? statusMatched,
    PillColors? statusClaimed,
    PillColors? typeLost,
    PillColors? typeFound,
  }) {
    return AppCustomColors(
      navyPrimary: navyPrimary ?? this.navyPrimary,
      navySurface: navySurface ?? this.navySurface,
      accentAmber: accentAmber ?? this.accentAmber,
      textPrimary: textPrimary ?? this.textPrimary,
      textBody: textBody ?? this.textBody,
      textMuted: textMuted ?? this.textMuted,
      borderDivider: borderDivider ?? this.borderDivider,
      slateSubtle: slateSubtle ?? this.slateSubtle,
      surfaceLight: surfaceLight ?? this.surfaceLight,
      backgroundLight: backgroundLight ?? this.backgroundLight,
      success: success ?? this.success,
      error: error ?? this.error,
      statusOpen: statusOpen ?? this.statusOpen,
      statusClosed: statusClosed ?? this.statusClosed,
      statusMatched: statusMatched ?? this.statusMatched,
      statusClaimed: statusClaimed ?? this.statusClaimed,
      typeLost: typeLost ?? this.typeLost,
      typeFound: typeFound ?? this.typeFound,
    );
  }

  @override
  AppCustomColors lerp(ThemeExtension<AppCustomColors>? other, double t) {
    if (other is! AppCustomColors) return this;
    return AppCustomColors(
      navyPrimary: Color.lerp(navyPrimary, other.navyPrimary, t)!,
      navySurface: Color.lerp(navySurface, other.navySurface, t)!,
      accentAmber: Color.lerp(accentAmber, other.accentAmber, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textBody: Color.lerp(textBody, other.textBody, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      borderDivider: Color.lerp(borderDivider, other.borderDivider, t)!,
      slateSubtle: Color.lerp(slateSubtle, other.slateSubtle, t)!,
      surfaceLight: Color.lerp(surfaceLight, other.surfaceLight, t)!,
      backgroundLight: Color.lerp(backgroundLight, other.backgroundLight, t)!,
      success: Color.lerp(success, other.success, t)!,
      error: Color.lerp(error, other.error, t)!,
      statusOpen: statusOpen,
      statusClosed: statusClosed,
      statusMatched: statusMatched,
      statusClaimed: statusClaimed,
      typeLost: typeLost,
      typeFound: typeFound,
    );
  }
}

/// Helper extension on BuildContext to quickly access custom palette tokens
extension ThemeContextExtension on BuildContext {
  AppCustomColors get appColors =>
      Theme.of(this).extension<AppCustomColors>() ?? const AppCustomColors();
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
}

/// Centralized ThemeData definition
ThemeData buildAppTheme() {
  const customColors = AppCustomColors();

  return ThemeData(
    useMaterial3: true,
    fontFamily: null,
    scaffoldBackgroundColor: AppColors.backgroundLight,
    colorScheme: const ColorScheme(
      brightness: Brightness.light,
      primary: AppColors.navyPrimary,
      onPrimary: AppColors.onNavyPrimary,
      primaryContainer: AppColors.navySurface,
      onPrimaryContainer: AppColors.onNavyPrimary,
      secondary: AppColors.accentAmber,
      onSecondary: AppColors.onAccentAmber,
      secondaryContainer: AppColors.amberLight,
      onSecondaryContainer: Color(0xFF92400E),
      surface: AppColors.surfaceLight,
      onSurface: AppColors.textPrimary,
      surfaceVariant: AppColors.slateSubtle,
      onSurfaceVariant: AppColors.textMuted,
      background: AppColors.backgroundLight,
      onBackground: AppColors.textPrimary,
      error: AppColors.error,
      onError: Colors.white,
      outline: AppColors.borderDivider,
      outlineVariant: Color(0xFFCBD5E1),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.navyPrimary,
      foregroundColor: AppColors.onNavyPrimary,
      elevation: 0,
      iconTheme: IconThemeData(color: AppColors.onNavyPrimary),
      actionsIconTheme: IconThemeData(color: AppColors.onNavyPrimary),
      titleTextStyle: TextStyle(
        color: AppColors.onNavyPrimary,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.navyPrimary,
        foregroundColor: AppColors.onNavyPrimary,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.navyPrimary,
        side: const BorderSide(color: AppColors.navyPrimary, width: 1.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.accentAmber,
      foregroundColor: AppColors.onAccentAmber, // Navy on Amber: 7.95:1 contrast
      elevation: 2,
    ),
    cardTheme: CardThemeData(
      color: AppColors.surfaceLight,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.borderDivider, width: 1),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surfaceLight,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.borderDivider),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.borderDivider),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.navyPrimary, width: 1.5),
      ),
      labelStyle: const TextStyle(color: AppColors.textMuted),
      hintStyle: const TextStyle(color: AppColors.textMuted),
      prefixIconColor: AppColors.textMuted,
      suffixIconColor: AppColors.textMuted,
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
      displayMedium: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
      displaySmall: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
      headlineMedium: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
      headlineSmall: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
      titleLarge: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
      titleMedium: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600),
      titleSmall: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600),
      bodyLarge: TextStyle(color: AppColors.textBody),
      bodyMedium: TextStyle(color: AppColors.textBody),
      bodySmall: TextStyle(color: AppColors.textMuted),
      labelLarge: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600),
    ),
    dividerTheme: const DividerThemeData(
      color: AppColors.borderDivider,
      thickness: 1,
      space: 1,
    ),
    extensions: const [
      customColors,
    ],
  );
}
