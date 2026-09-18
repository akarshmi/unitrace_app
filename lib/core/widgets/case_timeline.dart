import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Vertical case timeline adhering to Section 26 of UniTrace Master Design:
/// Steps:
/// 1. Reported
/// 2. Potential Match
/// 3. Claim Submitted
/// 4. Under Security Review
/// 5. Verified
/// 6. Handover
/// 7. Completed (Returned)
class CaseTimeline extends StatelessWidget {
  final String status;
  final String custodyStatus;
  final bool isFound;

  const CaseTimeline({
    super.key,
    required this.status,
    this.custodyStatus = '',
    this.isFound = false,
  });

  @override
  Widget build(BuildContext context) {
    final customColors = context.appColors;

    // Determine active index (0..6)
    int activeIndex = 0;
    final st = status.toUpperCase();
    final cust = custodyStatus.toUpperCase();

    if (st == 'CLOSED' || st == 'RETURNED' || st == 'COMPLETED') {
      activeIndex = 6;
    } else if (cust == 'HANDED_OVER') {
      activeIndex = 5;
    } else if (st == 'VERIFIED') {
      activeIndex = 4;
    } else if (st == 'CLAIMED' || st == 'UNDER_REVIEW' || st == 'UNDER REVIEW') {
      activeIndex = 3;
    } else if (st == 'MATCHED') {
      activeIndex = 1;
    } else {
      activeIndex = 0;
    }

    final steps = [
      _StepInfo(
        title: 'Reported',
        desc: isFound ? 'Found incident recorded' : 'Lost item report active',
      ),
      _StepInfo(
        title: 'Potential Match',
        desc: 'Identified via automated correlation',
      ),
      _StepInfo(
        title: 'Claim Submitted',
        desc: 'Confidential questionnaire completed',
      ),
      _StepInfo(
        title: 'Under Security Review',
        desc: 'Security officers checking evidence',
      ),
      _StepInfo(
        title: 'Verified',
        desc: 'Ownership confirmed by university office',
      ),
      _StepInfo(
        title: 'Handover',
        desc: 'Physical pickup & student ID verification',
      ),
      _StepInfo(
        title: 'Completed',
        desc: 'Belonging returned & case archived',
      ),
    ];

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: customColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: customColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.shield_outlined, size: 18, color: customColors.primary),
              const SizedBox(width: AppSpacing.xs),
              Text(
                'Case Lifecycle Progress',
                style: AppTypography.cardTitle.copyWith(fontSize: 15),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: customColors.primaryLight,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Text(
                  'STEP ${activeIndex + 1} OF ${steps.length}',
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
          const SizedBox(height: AppSpacing.md),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: steps.length,
            separatorBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(left: 11),
                child: Container(
                  width: 2,
                  height: 18,
                  color: index < activeIndex ? customColors.success : customColors.divider,
                ),
              );
            },
            itemBuilder: (context, index) {
              final step = steps[index];
              final isCompleted = index < activeIndex;
              final isCurrent = index == activeIndex;

              final Color dotColor;
              final Color textColor;
              final Widget indicator;

              if (isCompleted) {
                dotColor = customColors.success;
                textColor = customColors.textPrimary;
                indicator = Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: customColors.success,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check, size: 14, color: Colors.white),
                );
              } else if (isCurrent) {
                dotColor = customColors.primary;
                textColor = customColors.primary;
                indicator = Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: customColors.primaryLight,
                    shape: BoxShape.circle,
                    border: Border.all(color: customColors.primary, width: 2),
                  ),
                  child: Center(
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: customColors.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                );
              } else {
                dotColor = customColors.divider;
                textColor = customColors.textMuted;
                indicator = Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: customColors.surface,
                    shape: BoxShape.circle,
                    border: Border.all(color: customColors.border, width: 1.5),
                  ),
                );
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  indicator,
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          step.title,
                          style: TextStyle(
                            fontFamily: AppTypography.fontFamily,
                            fontSize: 14,
                            fontWeight: isCurrent ? FontWeight.w700 : (isCompleted ? FontWeight.w600 : FontWeight.w500),
                            color: textColor,
                          ),
                        ),
                        Text(
                          step.desc,
                          style: AppTypography.caption.copyWith(color: customColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _StepInfo {
  final String title;
  final String desc;

  const _StepInfo({required this.title, required this.desc});
}
