import 'package:flutter/material.dart';
import '../../../core/core.dart';
import '../models/item.dart';

/// Standardized CaseTimelineTracker aligning with Section 14 (Case Lifecycle Flow)
/// 01 Reported -> 02 Deposited -> 03 Matched -> 04 Claimed -> 05 Verified -> 06 Handed Over -> 07 Closed
class CaseTimelineTracker extends StatelessWidget {
  final Item item;

  const CaseTimelineTracker({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final customColors = context.appColors;

    int currentStep = 0;
    final status = item.status.toUpperCase();
    final custody = item.custodyStatus.toUpperCase();

    if (status == 'CLOSED' || status == 'RETURNED') {
      currentStep = 5;
    } else if (custody == 'HANDED_OVER') {
      currentStep = 4;
    } else if (status == 'CLAIMED') {
      currentStep = 3;
    } else if (status == 'MATCHED') {
      currentStep = 2;
    } else if (item.isFound && (custody == 'RECEIVED_BY_SECURITY' || custody == 'AVAILABLE_FOR_CLAIM')) {
      currentStep = 1;
    } else {
      currentStep = 0;
    }

    final steps = [
      _TimelineStep(
        title: 'Reported',
        desc: item.isLost ? 'Lost incident filed' : 'Found report registered',
        icon: Icons.edit_note_outlined,
      ),
      _TimelineStep(
        title: 'Security',
        desc: item.isFound ? 'Deposited at Security Office' : 'Logged with Security',
        icon: Icons.shield_outlined,
      ),
      _TimelineStep(
        title: 'Matched',
        desc: 'Correlated across reports',
        icon: Icons.auto_awesome,
      ),
      _TimelineStep(
        title: 'Claimed',
        desc: 'Ownership claim submitted',
        icon: Icons.verified_user_outlined,
      ),
      _TimelineStep(
        title: 'Handover',
        desc: 'ID check and digital signoff',
        icon: Icons.how_to_reg_outlined,
      ),
      _TimelineStep(
        title: 'Resolved',
        desc: 'Item returned to rightful owner',
        icon: Icons.check_circle_outline,
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
              Icon(Icons.timeline_rounded, size: 18, color: customColors.primary),
              const SizedBox(width: AppSpacing.xs),
              Text(
                'Case Lifecycle Flow',
                style: AppTypography.cardTitle.copyWith(fontSize: 14),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: customColors.primaryLight,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
                child: Text(
                  'STEP ${currentStep + 1} OF 6',
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

          // Horizontal Progress Indicator
          LayoutBuilder(builder: (context, constraints) {
            final width = constraints.maxWidth;

            return Stack(
              alignment: Alignment.centerLeft,
              children: [
                // Inactive line
                Positioned(
                  top: 14,
                  left: 14,
                  right: 14,
                  child: Container(
                    height: 2,
                    color: customColors.border,
                  ),
                ),
                // Active line
                Positioned(
                  top: 14,
                  left: 14,
                  child: Container(
                    height: 2,
                    width: currentStep == 0
                        ? 0
                        : ((width - 28) / (steps.length - 1)) * currentStep,
                    color: customColors.primary,
                  ),
                ),
                // Step circles
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(steps.length, (idx) {
                    final isPast = idx < currentStep;
                    final isCurrent = idx == currentStep;

                    Color circleBg;
                    Color circleBorder;
                    Color iconColor;

                    if (isPast) {
                      circleBg = customColors.success;
                      circleBorder = customColors.success;
                      iconColor = Colors.white;
                    } else if (isCurrent) {
                      circleBg = customColors.primary;
                      circleBorder = customColors.primary;
                      iconColor = Colors.white;
                    } else {
                      circleBg = customColors.surface;
                      circleBorder = customColors.border;
                      iconColor = customColors.textSecondary;
                    }

                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: circleBg,
                            shape: BoxShape.circle,
                            border: Border.all(color: circleBorder, width: 1.5),
                            boxShadow: isCurrent ? AppShadows.button : null,
                          ),
                          child: Center(
                            child: isPast
                                ? const Icon(Icons.check, size: 14, color: Colors.white)
                                : Icon(steps[idx].icon, size: 13, color: iconColor),
                          ),
                        ),
                        const SizedBox(height: 6),
                        SizedBox(
                          width: 48,
                          child: Text(
                            steps[idx].title,
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontFamily: AppTypography.fontFamily,
                              fontSize: 10,
                              fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500,
                              color: isCurrent
                                  ? customColors.primary
                                  : (isPast ? customColors.success : customColors.textSecondary),
                            ),
                          ),
                        ),
                      ],
                    );
                  }),
                ),
              ],
            );
          }),
          const SizedBox(height: AppSpacing.md),

          // Current step note
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 8),
            decoration: BoxDecoration(
              color: customColors.background,
              borderRadius: BorderRadius.circular(AppRadius.sm),
              border: Border.all(color: customColors.border),
            ),
            child: Row(
              children: [
                Icon(steps[currentStep].icon, size: 16, color: customColors.primary),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      style: TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        fontSize: 12,
                        color: customColors.textSecondary,
                      ),
                      children: [
                        TextSpan(
                          text: 'Current: ${steps[currentStep].title} — ',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: customColors.textPrimary,
                          ),
                        ),
                        TextSpan(text: steps[currentStep].desc),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TimelineStep {
  final String title;
  final String desc;
  final IconData icon;

  const _TimelineStep({
    required this.title,
    required this.desc,
    required this.icon,
  });
}
