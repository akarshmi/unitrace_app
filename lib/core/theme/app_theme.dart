import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_durations.dart';
import 'app_radius.dart';
import 'app_shadows.dart';
import 'app_spacing.dart';
import 'app_typography.dart';

export 'app_colors.dart';
export 'app_durations.dart';
export 'app_radius.dart';
export 'app_shadows.dart';
export 'app_spacing.dart';
export 'app_typography.dart';

/// Semantic Chip / Pill Color Tokens
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

/// Unified ThemeExtension delivering UniTrace master design-system tokens
@immutable
class AppCustomColors extends ThemeExtension<AppCustomColors> {
  final Color primary;
  final Color primaryDark;
  final Color primaryLight;
  final Color onPrimary;

  final Color background;
  final Color surface;
  final Color elevatedSurface;
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;
  final Color border;
  final Color divider;

  final Color success;
  final Color successBg;
  final Color warning;
  final Color warningBg;
  final Color error;
  final Color errorBg;
  final Color info;
  final Color infoBg;

  // Backward-compatibility aliases for existing widgets
  final Color navyPrimary;
  final Color navySurface;
  final Color accentAmber;
  final Color textBody;
  final Color borderDivider;
  final Color slateSubtle;
  final Color surfaceLight;
  final Color backgroundLight;

  // Semantic Pill Tokens
  final PillColors statusOpen;
  final PillColors statusClosed;
  final PillColors statusMatched;
  final PillColors statusClaimed;
  final PillColors statusVerified;
  final PillColors statusReturned;
  final PillColors statusAwaitingSecurity;
  final PillColors statusReceivedBySecurity;
  final PillColors statusUnderReview;
  final PillColors statusRejected;

  final PillColors typeLost;
  final PillColors typeFound;

  const AppCustomColors({
    this.primary = AppColors.primary,
    this.primaryDark = AppColors.primaryDark,
    this.primaryLight = AppColors.primaryLight,
    this.onPrimary = AppColors.onPrimary,
    this.background = AppColors.backgroundLight,
    this.surface = AppColors.surfaceLight,
    this.elevatedSurface = AppColors.elevatedLight,
    this.textPrimary = AppColors.textPrimaryLight,
    this.textSecondary = AppColors.textSecondaryLight,
    this.textMuted = AppColors.textMutedLight,
    this.border = AppColors.borderLight,
    this.divider = AppColors.dividerLight,
    this.success = AppColors.success,
    this.successBg = AppColors.successBg,
    this.warning = AppColors.warning,
    this.warningBg = AppColors.warningBg,
    this.error = AppColors.error,
    this.errorBg = AppColors.errorBg,
    this.info = AppColors.info,
    this.infoBg = AppColors.infoBg,
    this.navyPrimary = AppColors.primary,
    this.navySurface = AppColors.primaryDark,
    this.accentAmber = AppColors.warning,
    this.textBody = AppColors.textPrimaryLight,
    this.borderDivider = AppColors.borderLight,
    this.slateSubtle = const Color(0xFFF1F3F9),
    this.surfaceLight = AppColors.surfaceLight,
    this.backgroundLight = AppColors.backgroundLight,
    this.statusOpen = const PillColors(
      background: AppColors.statusOpenBg,
      text: AppColors.statusOpenText,
      border: AppColors.successBorder,
    ),
    this.statusClosed = const PillColors(
      background: AppColors.statusClosedBg,
      text: AppColors.statusClosedText,
      border: AppColors.borderLight,
    ),
    this.statusMatched = const PillColors(
      background: AppColors.statusMatchedBg,
      text: AppColors.statusMatchedText,
      border: AppColors.infoBorder,
    ),
    this.statusClaimed = const PillColors(
      background: AppColors.statusClaimedBg,
      text: AppColors.statusClaimedText,
      border: AppColors.warningBorder,
    ),
    this.statusVerified = const PillColors(
      background: AppColors.successBg,
      text: AppColors.success,
      border: AppColors.successBorder,
    ),
    this.statusReturned = const PillColors(
      background: AppColors.successBg,
      text: AppColors.success,
      border: AppColors.successBorder,
    ),
    this.statusAwaitingSecurity = const PillColors(
      background: AppColors.warningBg,
      text: AppColors.warning,
      border: AppColors.warningBorder,
    ),
    this.statusReceivedBySecurity = const PillColors(
      background: AppColors.infoBg,
      text: AppColors.info,
      border: AppColors.infoBorder,
    ),
    this.statusUnderReview = const PillColors(
      background: AppColors.warningBg,
      text: AppColors.warning,
      border: AppColors.warningBorder,
    ),
    this.statusRejected = const PillColors(
      background: AppColors.errorBg,
      text: AppColors.error,
      border: AppColors.errorBorder,
    ),
    this.typeLost = const PillColors(
      background: AppColors.typeLostBg,
      text: AppColors.typeLostText,
      border: AppColors.infoBorder,
    ),
    this.typeFound = const PillColors(
      background: AppColors.typeFoundBg,
      text: AppColors.typeFoundText,
      border: AppColors.successBorder,
    ),
  });

  PillColors getStatusColors(String status) {
    switch (status.toUpperCase()) {
      case 'VERIFIED':
        return statusVerified;
      case 'RETURNED':
      case 'COMPLETED':
        return statusReturned;
      case 'CLOSED':
        return statusClosed;
      case 'MATCHED':
      case 'POTENTIAL MATCH':
      case 'POTENTIAL_MATCH':
        return statusMatched;
      case 'UNDER REVIEW':
      case 'UNDER_REVIEW':
        return statusUnderReview;
      case 'AWAITING SECURITY':
      case 'AWAITING_SECURITY':
        return statusAwaitingSecurity;
      case 'RECEIVED BY SECURITY':
      case 'RECEIVED_BY_SECURITY':
        return statusReceivedBySecurity;
      case 'REJECTED':
        return statusRejected;
      case 'CLAIMED':
      case 'CLAIM SUBMITTED':
      case 'CLAIM_SUBMITTED':
      case 'PENDING':
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
    Color? primary,
    Color? primaryDark,
    Color? primaryLight,
    Color? onPrimary,
    Color? background,
    Color? surface,
    Color? elevatedSurface,
    Color? textPrimary,
    Color? textSecondary,
    Color? textMuted,
    Color? border,
    Color? divider,
    Color? success,
    Color? successBg,
    Color? warning,
    Color? warningBg,
    Color? error,
    Color? errorBg,
    Color? info,
    Color? infoBg,
    Color? navyPrimary,
    Color? navySurface,
    Color? accentAmber,
    Color? textBody,
    Color? borderDivider,
    Color? slateSubtle,
    Color? surfaceLight,
    Color? backgroundLight,
    PillColors? statusOpen,
    PillColors? statusClosed,
    PillColors? statusMatched,
    PillColors? statusClaimed,
    PillColors? statusVerified,
    PillColors? statusReturned,
    PillColors? statusAwaitingSecurity,
    PillColors? statusReceivedBySecurity,
    PillColors? statusUnderReview,
    PillColors? statusRejected,
    PillColors? typeLost,
    PillColors? typeFound,
  }) {
    return AppCustomColors(
      primary: primary ?? this.primary,
      primaryDark: primaryDark ?? this.primaryDark,
      primaryLight: primaryLight ?? this.primaryLight,
      onPrimary: onPrimary ?? this.onPrimary,
      background: background ?? this.background,
      surface: surface ?? this.surface,
      elevatedSurface: elevatedSurface ?? this.elevatedSurface,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textMuted: textMuted ?? this.textMuted,
      border: border ?? this.border,
      divider: divider ?? this.divider,
      success: success ?? this.success,
      successBg: successBg ?? this.successBg,
      warning: warning ?? this.warning,
      warningBg: warningBg ?? this.warningBg,
      error: error ?? this.error,
      errorBg: errorBg ?? this.errorBg,
      info: info ?? this.info,
      infoBg: infoBg ?? this.infoBg,
      navyPrimary: navyPrimary ?? this.navyPrimary,
      navySurface: navySurface ?? this.navySurface,
      accentAmber: accentAmber ?? this.accentAmber,
      textBody: textBody ?? this.textBody,
      borderDivider: borderDivider ?? this.borderDivider,
      slateSubtle: slateSubtle ?? this.slateSubtle,
      surfaceLight: surfaceLight ?? this.surfaceLight,
      backgroundLight: backgroundLight ?? this.backgroundLight,
      statusOpen: statusOpen ?? this.statusOpen,
      statusClosed: statusClosed ?? this.statusClosed,
      statusMatched: statusMatched ?? this.statusMatched,
      statusClaimed: statusClaimed ?? this.statusClaimed,
      statusVerified: statusVerified ?? this.statusVerified,
      statusReturned: statusReturned ?? this.statusReturned,
      statusAwaitingSecurity: statusAwaitingSecurity ?? this.statusAwaitingSecurity,
      statusReceivedBySecurity: statusReceivedBySecurity ?? this.statusReceivedBySecurity,
      statusUnderReview: statusUnderReview ?? this.statusUnderReview,
      statusRejected: statusRejected ?? this.statusRejected,
      typeLost: typeLost ?? this.typeLost,
      typeFound: typeFound ?? this.typeFound,
    );
  }

  @override
  AppCustomColors lerp(ThemeExtension<AppCustomColors>? other, double t) {
    if (other is! AppCustomColors) return this;
    return AppCustomColors(
      primary: Color.lerp(primary, other.primary, t)!,
      primaryDark: Color.lerp(primaryDark, other.primaryDark, t)!,
      primaryLight: Color.lerp(primaryLight, other.primaryLight, t)!,
      onPrimary: Color.lerp(onPrimary, other.onPrimary, t)!,
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      elevatedSurface: Color.lerp(elevatedSurface, other.elevatedSurface, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      border: Color.lerp(border, other.border, t)!,
      divider: Color.lerp(divider, other.divider, t)!,
      success: Color.lerp(success, other.success, t)!,
      successBg: Color.lerp(successBg, other.successBg, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      warningBg: Color.lerp(warningBg, other.warningBg, t)!,
      error: Color.lerp(error, other.error, t)!,
      errorBg: Color.lerp(errorBg, other.errorBg, t)!,
      info: Color.lerp(info, other.info, t)!,
      infoBg: Color.lerp(infoBg, other.infoBg, t)!,
      navyPrimary: Color.lerp(navyPrimary, other.navyPrimary, t)!,
      navySurface: Color.lerp(navySurface, other.navySurface, t)!,
      accentAmber: Color.lerp(accentAmber, other.accentAmber, t)!,
      textBody: Color.lerp(textBody, other.textBody, t)!,
      borderDivider: Color.lerp(borderDivider, other.borderDivider, t)!,
      slateSubtle: Color.lerp(slateSubtle, other.slateSubtle, t)!,
      surfaceLight: Color.lerp(surfaceLight, other.surfaceLight, t)!,
      backgroundLight: Color.lerp(backgroundLight, other.backgroundLight, t)!,
      statusOpen: statusOpen,
      statusClosed: statusClosed,
      statusMatched: statusMatched,
      statusClaimed: statusClaimed,
      statusVerified: statusVerified,
      statusReturned: statusReturned,
      statusAwaitingSecurity: statusAwaitingSecurity,
      statusReceivedBySecurity: statusReceivedBySecurity,
      statusUnderReview: statusUnderReview,
      statusRejected: statusRejected,
      typeLost: typeLost,
      typeFound: typeFound,
    );
  }
}

/// Helper extension on BuildContext to access UniTrace design tokens
extension ThemeContextExtension on BuildContext {
  AppCustomColors get appColors =>
      Theme.of(this).extension<AppCustomColors>() ?? const AppCustomColors();
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
}

/// Master Light Theme builder adhering to the UniTrace Design System specification
ThemeData buildAppTheme() {
  const customColors = AppCustomColors();

  return ThemeData(
    useMaterial3: true,
    fontFamily: AppTypography.fontFamily,
    scaffoldBackgroundColor: AppColors.backgroundLight,
    colorScheme: const ColorScheme(
      brightness: Brightness.light,
      primary: AppColors.primary,
      onPrimary: AppColors.onPrimary,
      primaryContainer: AppColors.primaryLight,
      onPrimaryContainer: AppColors.primaryDark,
      secondary: AppColors.primaryDark,
      onSecondary: Colors.white,
      secondaryContainer: AppColors.primaryLight,
      onSecondaryContainer: AppColors.primaryDark,
      surface: AppColors.surfaceLight,
      onSurface: AppColors.textPrimaryLight,
      surfaceVariant: AppColors.backgroundLight,
      onSurfaceVariant: AppColors.textSecondaryLight,
      background: AppColors.backgroundLight,
      onBackground: AppColors.textPrimaryLight,
      error: AppColors.error,
      onError: Colors.white,
      outline: AppColors.borderLight,
      outlineVariant: AppColors.dividerLight,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.surfaceLight,
      foregroundColor: AppColors.textPrimaryLight,
      elevation: 0,
      scrolledUnderElevation: 1,
      centerTitle: false,
      iconTheme: IconThemeData(color: AppColors.textPrimaryLight, size: 20),
      actionsIconTheme: IconThemeData(color: AppColors.textPrimaryLight, size: 20),
      titleTextStyle: TextStyle(
        fontFamily: AppTypography.fontFamily,
        color: AppColors.textPrimaryLight,
        fontSize: 18,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.2,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        elevation: 0,
        minimumSize: const Size(0, 48),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.button),
        ),
        textStyle: AppTypography.button,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        minimumSize: const Size(0, 48),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
        side: const BorderSide(color: AppColors.borderLight, width: 1.2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.button),
        ),
        textStyle: AppTypography.button.copyWith(color: AppColors.primary),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primary,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
        textStyle: AppTypography.button.copyWith(color: AppColors.primary),
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
    ),
    cardTheme: CardThemeData(
      color: AppColors.surfaceLight,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.card),
        side: const BorderSide(color: AppColors.borderLight, width: 1),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surfaceLight,
      contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.input),
        borderSide: const BorderSide(color: AppColors.borderLight, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.input),
        borderSide: const BorderSide(color: AppColors.borderLight, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.input),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.input),
        borderSide: const BorderSide(color: AppColors.error, width: 1.2),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.input),
        borderSide: const BorderSide(color: AppColors.error, width: 1.5),
      ),
      labelStyle: const TextStyle(
        fontFamily: AppTypography.fontFamily,
        color: AppColors.textSecondaryLight,
        fontSize: 14,
      ),
      hintStyle: const TextStyle(
        fontFamily: AppTypography.fontFamily,
        color: AppColors.textMutedLight,
        fontSize: 14,
      ),
      prefixIconColor: AppColors.textSecondaryLight,
      suffixIconColor: AppColors.textSecondaryLight,
    ),
    textTheme: const TextTheme(
      displayLarge: AppTypography.heroDisplay,
      displayMedium: AppTypography.pageTitle,
      headlineLarge: AppTypography.sectionTitle,
      headlineMedium: AppTypography.sectionTitle,
      titleLarge: AppTypography.cardTitle,
      titleMedium: TextStyle(
        fontFamily: AppTypography.fontFamily,
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimaryLight,
      ),
      titleSmall: TextStyle(
        fontFamily: AppTypography.fontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimaryLight,
      ),
      bodyLarge: AppTypography.body,
      bodyMedium: AppTypography.bodySmall,
      bodySmall: AppTypography.secondary,
      labelLarge: AppTypography.button,
      labelSmall: AppTypography.caption,
    ),
    dividerTheme: const DividerThemeData(
      color: AppColors.dividerLight,
      thickness: 1,
      space: 1,
    ),
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.backgroundLight,
      side: const BorderSide(color: AppColors.borderLight, width: 1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.pill)),
      labelStyle: const TextStyle(
        fontFamily: AppTypography.fontFamily,
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimaryLight,
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: AppColors.surfaceLight,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.card)),
      titleTextStyle: AppTypography.cardTitle,
      contentTextStyle: AppTypography.bodySmall,
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: AppColors.surfaceLight,
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: AppRadius.bottomSheet),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: AppColors.surfaceLight,
      elevation: 0,
      indicatorColor: AppColors.primaryLight,
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      labelTextStyle: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return const TextStyle(
            fontFamily: AppTypography.fontFamily,
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
          );
        }
        return const TextStyle(
          fontFamily: AppTypography.fontFamily,
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: AppColors.textSecondaryLight,
        );
      }),
      iconTheme: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return const IconThemeData(color: AppColors.primary, size: 22);
        }
        return const IconThemeData(color: AppColors.textSecondaryLight, size: 22);
      }),
    ),
    extensions: const [
      customColors,
    ],
  );
}

/// Dark Mode theme builder
ThemeData buildDarkAppTheme() {
  const darkCustomColors = AppCustomColors(
    primary: AppColors.primary,
    primaryDark: AppColors.primaryDark,
    primaryLight: Color(0xFF1D283A),
    onPrimary: Colors.white,
    background: AppColors.backgroundDark,
    surface: AppColors.surfaceDark,
    elevatedSurface: AppColors.elevatedDark,
    textPrimary: AppColors.textPrimaryDark,
    textSecondary: AppColors.textSecondaryDark,
    textMuted: AppColors.textMutedDark,
    border: AppColors.borderDark,
    divider: AppColors.dividerDark,
    success: AppColors.success,
    successBg: Color(0xFF0E2E20),
    warning: AppColors.warning,
    warningBg: Color(0xFF38260B),
    error: AppColors.error,
    errorBg: Color(0xFF3D1616),
    info: AppColors.info,
    infoBg: Color(0xFF14244D),
    navyPrimary: AppColors.primary,
    navySurface: AppColors.surfaceDark,
    accentAmber: AppColors.warning,
    textBody: AppColors.textPrimaryDark,
    borderDivider: AppColors.borderDark,
    slateSubtle: AppColors.surfaceDark,
    surfaceLight: AppColors.surfaceDark,
    backgroundLight: AppColors.backgroundDark,
    statusOpen: PillColors(
      background: Color(0xFF0E2E20),
      text: Color(0xFF5CE3A7),
      border: Color(0xFF1D5A40),
    ),
    statusClosed: PillColors(
      background: Color(0xFF1B2330),
      text: AppColors.textSecondaryDark,
      border: AppColors.borderDark,
    ),
    statusMatched: PillColors(
      background: Color(0xFF14244D),
      text: Color(0xFF7FA7FF),
      border: Color(0xFF264082),
    ),
    statusClaimed: PillColors(
      background: Color(0xFF38260B),
      text: Color(0xFFF3C06A),
      border: Color(0xFF6B4B18),
    ),
  );

  return ThemeData(
    useMaterial3: true,
    fontFamily: AppTypography.fontFamily,
    scaffoldBackgroundColor: AppColors.backgroundDark,
    colorScheme: const ColorScheme(
      brightness: Brightness.dark,
      primary: AppColors.primary,
      onPrimary: Colors.white,
      primaryContainer: Color(0xFF1E2F5E),
      onPrimaryContainer: Colors.white,
      secondary: Color(0xFF4C70EC),
      onSecondary: Colors.white,
      surface: AppColors.surfaceDark,
      onSurface: AppColors.textPrimaryDark,
      background: AppColors.backgroundDark,
      onBackground: AppColors.textPrimaryDark,
      error: AppColors.error,
      onError: Colors.white,
      outline: AppColors.borderDark,
      outlineVariant: AppColors.dividerDark,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.surfaceDark,
      foregroundColor: AppColors.textPrimaryDark,
      elevation: 0,
      scrolledUnderElevation: 1,
      centerTitle: false,
      titleTextStyle: TextStyle(
        fontFamily: AppTypography.fontFamily,
        color: AppColors.textPrimaryDark,
        fontSize: 18,
        fontWeight: FontWeight.w700,
      ),
    ),
    cardTheme: CardThemeData(
      color: AppColors.surfaceDark,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.card),
        side: const BorderSide(color: AppColors.borderDark, width: 1),
      ),
    ),
    extensions: const [
      darkCustomColors,
    ],
  );
}
