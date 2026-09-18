import 'package:flutter/material.dart';
import '../../../core/core.dart';
import '../models/match_result.dart';

/// Distinctive Match Card conforming to Section 12 & 13 of UniTrace Master Design:
/// Rules:
/// - 16px radius
/// - Primary brand color (#3157D5) used for match UI (NEVER green: Green = verified ownership)
/// - Confidence displayed as "% match confidence" (not "chance it belongs to you")
/// - Clear comparison between Lost Report and Found Report
/// - Wording clearly distinguishes automated possibility from university verification
class MatchCard extends StatelessWidget {
  final MatchCandidate match;
  final VoidCallback onTapLost;
  final VoidCallback onTapFound;
  final VoidCallback onClaim;

  const MatchCard({
    super.key,
    required this.match,
    required this.onTapLost,
    required this.onTapFound,
    required this.onClaim,
  });

  @override
  Widget build(BuildContext context) {
    final customColors = context.appColors;

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: customColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(
          color: match.score >= 0.75
              ? customColors.primary.withOpacity(0.35)
              : customColors.border,
          width: match.score >= 0.75 ? 1.5 : 1.0,
        ),
        boxShadow: AppShadows.card,
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: POTENTIAL MATCH + Confidence
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                  decoration: BoxDecoration(
                    color: customColors.primaryLight,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.auto_awesome, size: 12, color: customColors.primary),
                      const SizedBox(width: 4),
                      Text(
                        'POTENTIAL MATCH',
                        style: TextStyle(
                          fontFamily: AppTypography.fontFamily,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: customColors.primary,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                ConfidenceIndicator(score: match.score, compact: true),
              ],
            ),
            const SizedBox(height: AppSpacing.md),

            // Comparison Layout: Lost Item vs Found Item
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: customColors.background,
                borderRadius: BorderRadius.circular(AppRadius.input),
                border: Border.all(color: customColors.border),
              ),
              child: Row(
                children: [
                  // Lost Item Column
                  Expanded(
                    child: InkWell(
                      onTap: onTapLost,
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              TypeBadge(type: 'LOST', fontSize: 9),
                              const Spacer(),
                              StatusChip(status: match.lostItem.status, fontSize: 9),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            match.lostItem.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.cardTitle.copyWith(fontSize: 13),
                          ),
                          const SizedBox(height: 3),
                          Row(
                            children: [
                              Icon(Icons.location_on_outlined, size: 11, color: customColors.textMuted),
                              const SizedBox(width: 2),
                              Expanded(
                                child: Text(
                                  match.lostItem.location.isNotEmpty ? match.lostItem.location : 'Campus',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTypography.caption.copyWith(color: customColors.textSecondary),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Divider
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: customColors.surface,
                            shape: BoxShape.circle,
                            border: Border.all(color: customColors.border),
                          ),
                          child: Icon(Icons.sync_alt, color: customColors.primary, size: 16),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'VS',
                          style: TextStyle(
                            fontFamily: AppTypography.fontFamily,
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: customColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Found Item Column
                  Expanded(
                    child: InkWell(
                      onTap: onTapFound,
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              TypeBadge(type: 'FOUND', fontSize: 9),
                              const Spacer(),
                              StatusChip(status: match.foundItem.status, fontSize: 9),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            match.foundItem.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.cardTitle.copyWith(fontSize: 13),
                          ),
                          const SizedBox(height: 3),
                          Row(
                            children: [
                              Icon(Icons.location_on_outlined, size: 11, color: customColors.textMuted),
                              const SizedBox(width: 2),
                              Expanded(
                                child: Text(
                                  match.foundItem.location.isNotEmpty ? match.foundItem.location : 'Campus',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTypography.caption.copyWith(color: customColors.textSecondary),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.sm),

            // Similarity breakdown statement
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline, size: 14, color: customColors.primary),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    match.reason,
                    style: AppTypography.caption.copyWith(
                      color: customColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onTapFound,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: customColors.textPrimary,
                      side: BorderSide(color: customColors.border),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      minimumSize: const Size(0, 42),
                    ),
                    child: const Text('View Match'),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onClaim,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: customColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      minimumSize: const Size(0, 42),
                    ),
                    child: const Text('Submit Claim'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
