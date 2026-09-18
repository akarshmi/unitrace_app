/// Centralized Animation Durations & Curves for UniTrace.
/// Master prompt specifications:
/// - 150-250ms: small interactions
/// - 250-350ms: page transitions
/// - 350-500ms: larger state transitions
/// - Motion should feel subtle, controlled, and expensive.
class AppDurations {
  AppDurations._();

  static const Duration fast = Duration(milliseconds: 180);
  static const Duration normal = Duration(milliseconds: 280);
  static const Duration slow = Duration(milliseconds: 400);

  // Interaction-specific durations
  static const Duration buttonPress = Duration(milliseconds: 120);
  static const Duration chipToggle = Duration(milliseconds: 200);
  static const Duration modalSlide = Duration(milliseconds: 300);
  static const Duration confidenceIndicator = Duration(milliseconds: 600);
}
