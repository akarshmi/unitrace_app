import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Standardized StatusChip adhering strictly to the UniTrace Design System.
/// Specifications:
/// - Semantic background & text
/// - Rounded pill (or 6px rounded)
/// - Never rely solely on color (always displays text)
/// - Visual hierarchy:
///   - Success (#168A5B / #E8F7F0): Verified, Returned, Completed
///   - Warning (#B7791F / #FFF7E6): Pending, Under Review, Awaiting Security, Claim Submitted
///   - Info (#356AE6 / #EAF0FF): Potential Match, Open, System Updates
///   - Error (#D64545 / #FDECEC): Rejected, Failed
class StatusChip extends StatelessWidget {
  final String status;
  final double fontSize;
  final EdgeInsetsGeometry padding;
  final bool showDot;

  const StatusChip({
    super.key,
    required this.status,
    this.fontSize = 11,
    this.padding = const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
    this.showDot = false,
  });

  @override
  Widget build(BuildContext context) {
    final pillColors = context.appColors.getStatusColors(status);
    final displayLabel = _formatStatus(status);

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: pillColors.background,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(color: pillColors.border, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showDot) ...[
            Container(
              width: 6,
              height: 6,
              margin: const EdgeInsets.only(right: 5),
              decoration: BoxDecoration(
                color: pillColors.text,
                shape: BoxShape.circle,
              ),
            ),
          ],
          Text(
            displayLabel,
            style: TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
              color: pillColors.text,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }

  String _formatStatus(String raw) {
    final clean = raw.replaceAll('_', ' ').toUpperCase();
    switch (clean) {
      case 'POTENTIAL MATCH':
        return 'POTENTIAL MATCH';
      case 'CLAIMED':
        return 'CLAIM SUBMITTED';
      case 'UNDER REVIEW':
        return 'UNDER REVIEW';
      case 'AWAITING SECURITY':
        return 'AWAITING SECURITY';
      case 'RECEIVED BY SECURITY':
        return 'IN SECURITY CUSTODY';
      case 'VERIFIED':
        return 'VERIFIED';
      case 'RETURNED':
        return 'RETURNED';
      case 'REJECTED':
        return 'REJECTED';
      case 'CLOSED':
        return 'CLOSED';
      case 'OPEN':
      default:
        return 'OPEN';
    }
  }
}

/// Backward compatible StatusPill delegating to StatusChip
class StatusPill extends StatelessWidget {
  final String status;
  final double fontSize;
  final EdgeInsetsGeometry padding;

  const StatusPill({
    super.key,
    required this.status,
    this.fontSize = 11,
    this.padding = const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
  });

  @override
  Widget build(BuildContext context) {
    return StatusChip(status: status, fontSize: fontSize, padding: padding);
  }
}

/// TypeBadge (LOST / FOUND report indicators)
class TypeBadge extends StatelessWidget {
  final String type;
  final double fontSize;
  final EdgeInsetsGeometry padding;

  const TypeBadge({
    super.key,
    required this.type,
    this.fontSize = 11,
    this.padding = const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
  });

  @override
  Widget build(BuildContext context) {
    final pillColors = context.appColors.getTypeColors(type);
    final isLost = type.toUpperCase() == 'LOST';

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: pillColors.background,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(color: pillColors.border, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isLost ? Icons.search : Icons.inventory_2_outlined,
            size: fontSize + 1,
            color: pillColors.text,
          ),
          const SizedBox(width: 4),
          Text(
            isLost ? 'LOST REPORT' : 'FOUND REPORT',
            style: TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
              color: pillColors.text,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}
