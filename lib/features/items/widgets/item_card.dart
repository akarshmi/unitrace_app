import 'package:flutter/material.dart';
import '../../../core/core.dart';
import '../models/item.dart';

/// Standardized Item Card conforming to Section 9 & 10 of UniTrace Master Design:
/// Rules:
/// - 16px radius
/// - Thin border (#E4E7EC)
/// - Subtle elevation
/// - 16px internal padding
/// - Hierarchy: Image -> Title -> Category & Location -> Date -> Status
/// - Small icons for location and date
class ItemCard extends StatelessWidget {
  final Item item;
  final VoidCallback onTap;

  const ItemCard({
    super.key,
    required this.item,
    required this.onTap,
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
        border: Border.all(color: customColors.border, width: 1),
        boxShadow: AppShadows.card,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.card),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image Presentation (12-16px radius, proper aspect ratio)
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.input),
                  child: Container(
                    width: 76,
                    height: 76,
                    color: customColors.background,
                    child: item.imageUrl != null && item.imageUrl!.isNotEmpty
                        ? Image.network(
                            item.imageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                _buildPlaceholder(customColors),
                          )
                        : _buildPlaceholder(customColors),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                // Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          TypeBadge(type: item.type),
                          const SizedBox(width: 6),
                          StatusChip(status: item.status),
                          const Spacer(),
                          if (item.createdAt != null && item.createdAt!.isNotEmpty) ...[
                            Icon(
                              Icons.calendar_today_outlined,
                              size: 11,
                              color: customColors.textMuted,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _formatDate(item.createdAt!),
                              style: AppTypography.caption.copyWith(
                                color: customColors.textMuted,
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        item.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.cardTitle.copyWith(
                          fontSize: 16,
                          color: customColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          if (item.category != null && item.category!.isNotEmpty) ...[
                            Text(
                              item.category!,
                              style: AppTypography.caption.copyWith(
                                color: customColors.textSecondary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              '  •  ',
                              style: TextStyle(
                                fontSize: 11,
                                color: customColors.border,
                              ),
                            ),
                          ],
                          Icon(
                            Icons.location_on_outlined,
                            size: 13,
                            color: customColors.textMuted,
                          ),
                          const SizedBox(width: 3),
                          Expanded(
                            child: Text(
                              item.location.isNotEmpty ? item.location : 'Campus',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.secondary.copyWith(
                                fontSize: 12,
                                color: customColors.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder(AppCustomColors colors) {
    return Center(
      child: Icon(
        item.isLost ? Icons.search_rounded : Icons.inventory_2_outlined,
        size: 28,
        color: colors.primary.withOpacity(0.4),
      ),
    );
  }

  String _formatDate(String rawDate) {
    try {
      final dt = DateTime.parse(rawDate);
      final months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      return '${dt.day} ${months[dt.month - 1]}';
    } catch (_) {
      return rawDate.length > 10 ? rawDate.substring(0, 10) : rawDate;
    }
  }
}
