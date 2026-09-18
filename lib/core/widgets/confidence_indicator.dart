import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Match Confidence indicator conforming to Section 13 of UniTrace Master Design:
/// Ranges:
/// HIGH POTENTIAL: 80-100%
/// MODERATE POTENTIAL: 60-79%
/// LOW POTENTIAL: < 60%
/// Wording: "% match confidence" (NOT "chance this belongs to you")
/// Primary Brand color (#3157D5) used for match UI (NOT green).
class ConfidenceIndicator extends StatelessWidget {
  final double score; // 0.0 to 1.0 or 0 to 100
  final bool compact;

  const ConfidenceIndicator({
    super.key,
    required this.score,
    this.compact = false,
  });

  int get _percent {
    if (score <= 1.0) {
      return (score * 100).round();
    }
    return score.round();
  }

  String get _potentialLabel {
    final p = _percent;
    if (p >= 80) return 'HIGH POTENTIAL';
    if (p >= 60) return 'MODERATE POTENTIAL';
    return 'LOW POTENTIAL';
  }

  @override
  Widget build(BuildContext context) {
    final customColors = context.appColors;
    final pct = _percent;

    if (compact) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs, vertical: 3),
        decoration: BoxDecoration(
          color: customColors.primaryLight,
          borderRadius: BorderRadius.circular(AppRadius.sm),
          border: Border.all(color: customColors.primary.withOpacity(0.25)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.auto_awesome, size: 12, color: customColors.primary),
            const SizedBox(width: 4),
            Text(
              '$pct% Match',
              style: TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: customColors.primary,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: customColors.primaryLight,
        borderRadius: BorderRadius.circular(AppRadius.input),
        border: Border.all(color: customColors.primary.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 36,
            height: 36,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CircularProgressIndicator(
                  value: pct / 100.0,
                  strokeWidth: 3.5,
                  backgroundColor: Colors.white,
                  valueColor: AlwaysStoppedAnimation<Color>(customColors.primary),
                ),
                Center(
                  child: Text(
                    '$pct%',
                    style: TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: customColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _potentialLabel,
                style: TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: customColors.primary,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Match confidence',
                style: TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: customColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
