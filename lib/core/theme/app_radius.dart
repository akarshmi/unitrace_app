import 'package:flutter/material.dart';

/// Centralized Border Radius tokens for UniTrace.
/// Master prompt specifications:
/// - Small controls: 8px
/// - Inputs: 10px
/// - Buttons: 10-12px
/// - Cards: 16px
/// - Large containers: 20px
/// - Hero elements: 24px
/// - Status/Tags/Pills: Rounded / Full
class AppRadius {
  AppRadius._();

  // Raw values
  static const double sm = 8.0; // small controls
  static const double input = 10.0; // inputs
  static const double button = 12.0; // buttons
  static const double card = 16.0; // cards
  static const double container = 20.0; // large containers
  static const double hero = 24.0; // hero elements
  static const double pill = 999.0; // chips & status pills

  // BorderRadius objects
  static const BorderRadius borderSm = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius borderInput = BorderRadius.all(Radius.circular(input));
  static const BorderRadius borderButton = BorderRadius.all(Radius.circular(button));
  static const BorderRadius borderCard = BorderRadius.all(Radius.circular(card));
  static const BorderRadius borderContainer = BorderRadius.all(Radius.circular(container));
  static const BorderRadius borderHero = BorderRadius.all(Radius.circular(hero));
  static const BorderRadius borderPill = BorderRadius.all(Radius.circular(pill));

  // Top rounded for bottom sheets and modals
  static const BorderRadius bottomSheet = BorderRadius.vertical(top: Radius.circular(container));
}
