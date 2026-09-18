import 'package:flutter/material.dart';

/// Centralized Elevation and Shadows for UniTrace.
/// Master prompt specifications:
/// - Subtle elevation
/// - Thin border + surface contrast over heavy shadows
/// - Clean, calm, professional aesthetic
class AppShadows {
  AppShadows._();

  // Very subtle card shadow
  static const List<BoxShadow> card = [
    BoxShadow(
      color: Color(0x0A101828), // 4% alpha
      offset: Offset(0, 1),
      blurRadius: 3,
      spreadRadius: 0,
    ),
    BoxShadow(
      color: Color(0x0A101828),
      offset: Offset(0, 2),
      blurRadius: 6,
      spreadRadius: -1,
    ),
  ];

  // Slightly elevated card / dropdown / dialog
  static const List<BoxShadow> elevated = [
    BoxShadow(
      color: Color(0x10101828), // ~6% alpha
      offset: Offset(0, 4),
      blurRadius: 12,
      spreadRadius: -2,
    ),
  ];

  // Floating button shadow
  static const List<BoxShadow> button = [
    BoxShadow(
      color: Color(0x183157D5), // 10% primary
      offset: Offset(0, 2),
      blurRadius: 8,
      spreadRadius: 0,
    ),
  ];

  // None (flat)
  static const List<BoxShadow> none = [];
}
