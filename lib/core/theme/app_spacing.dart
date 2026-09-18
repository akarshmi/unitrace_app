import 'package:flutter/material.dart';

/// Centralized 8-point spacing system for UniTrace.
/// Allowed spacing tokens:
/// 4, 8, 12, 16, 20, 24, 32, 40, 48, 64, 80
/// Primary spacing:
/// 8px = small
/// 16px = normal
/// 24px = section
/// 32px = large
/// 48px+ = major sections
class AppSpacing {
  AppSpacing._();

  static const double xxs = 4.0;
  static const double xs = 8.0;
  static const double sm = 12.0;
  static const double md = 16.0;
  static const double lg = 20.0;
  static const double xl = 24.0;
  static const double xxl = 32.0;
  static const double xxxl = 40.0;
  static const double major = 48.0;
  static const double section = 64.0;
  static const double page = 80.0;

  // Aliases conforming to prompt description
  static const double small = xs; // 8px
  static const double normal = md; // 16px
  static const double sectionSpacing = xl; // 24px
  static const double large = xxl; // 32px
  static const double majorSection = major; // 48px

  // Edge insets helpers
  static const EdgeInsets paddingAllXs = EdgeInsets.all(xs);
  static const EdgeInsets paddingAllSm = EdgeInsets.all(sm);
  static const EdgeInsets paddingAllMd = EdgeInsets.all(md);
  static const EdgeInsets paddingAllLg = EdgeInsets.all(lg);
  static const EdgeInsets paddingAllXl = EdgeInsets.all(xl);

  static const EdgeInsets horizontalMd = EdgeInsets.symmetric(horizontal: md);
  static const EdgeInsets horizontalXl = EdgeInsets.symmetric(horizontal: xl);
  static const EdgeInsets verticalMd = EdgeInsets.symmetric(vertical: md);
  static const EdgeInsets verticalLg = EdgeInsets.symmetric(vertical: lg);

  // Responsive max content width
  static const double maxContentWidth = 1280.0;
  static const double maxFormWidth = 560.0;
}
