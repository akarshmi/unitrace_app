import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class StatusPill extends StatelessWidget {
  final String status;
  final double fontSize;
  final EdgeInsetsGeometry padding;

  const StatusPill({
    super.key,
    required this.status,
    this.fontSize = 11,
    this.padding = const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
  });

  @override
  Widget build(BuildContext context) {
    final pillColors = context.appColors.getStatusColors(status);

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: pillColors.background,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: pillColors.border, width: 1),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.w700,
          color: pillColors.text,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

class TypeBadge extends StatelessWidget {
  final String type;
  final double fontSize;
  final EdgeInsetsGeometry padding;

  const TypeBadge({
    super.key,
    required this.type,
    this.fontSize = 11,
    this.padding = const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
  });

  @override
  Widget build(BuildContext context) {
    final pillColors = context.appColors.getTypeColors(type);

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: pillColors.background,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: pillColors.border, width: 1),
      ),
      child: Text(
        type.toUpperCase(),
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.w700,
          color: pillColors.text,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}
