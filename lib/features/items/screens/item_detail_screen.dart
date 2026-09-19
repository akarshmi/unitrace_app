import 'package:flutter/material.dart';
import '../../../core/core.dart';
import '../data/item_api.dart';
import '../models/item.dart';
import '../widgets/case_timeline_tracker.dart';
import 'matches_screen.dart';
import 'multi_step_claim_screen.dart';

/// Standardized ItemDetailScreen conforming to Section 22 of UniTrace Master Design:
/// Rules:
/// - Distinctive hero section with crisp photo or neutral placeholder
/// - Semantic StatusChip & TypeBadge with proper padding and radii
/// - Case Lifecycle Tracker in card container
/// - Clean specifications grid (Location, Category, Date, Reporter)
/// - Ownership authorization check (creator or staff can update status)
/// - Clear, high-contrast action buttons using AppButton
class ItemDetailScreen extends StatefulWidget {
  final Item item;

  const ItemDetailScreen({super.key, required this.item});

  @override
  State<ItemDetailScreen> createState() => _ItemDetailScreenState();
}

class _ItemDetailScreenState extends State<ItemDetailScreen> {
  final ItemApi _itemApi = ItemApi();
  late Item _item;
  bool _isUpdatingStatus = false;
  String? _currentUserEmail;
  String? _currentUserName;
  String? _currentUserRole;
  String? _currentUserId;
  bool _isLocallyTrackedCreator = false;

  @override
  void initState() {
    super.initState();
    _item = widget.item;
    _loadCurrentUserInfo();
  }

  Future<void> _loadCurrentUserInfo() async {
    final email = await TokenStorage.getUserEmail();
    final name = await TokenStorage.getUserName();
    final role = await TokenStorage.getUserRole();
    final id = await TokenStorage.getUserId();
    final isTrackedCreator = await TokenStorage.isMyCreatedItem(_item.id);

    if (mounted) {
      setState(() {
        _currentUserEmail = email;
        _currentUserName = name;
        _currentUserRole = role;
        _currentUserId = id;
        _isLocallyTrackedCreator = isTrackedCreator;
      });
    }
  }

  bool get _isModerator {
    final r = (_currentUserRole ?? '').toUpperCase();
    return r == 'MODERATOR' || r == 'ADMIN';
  }

  bool get _isItemCreator {
    if (_isLocallyTrackedCreator) return true;

    if (_currentUserEmail != null &&
        _item.reportedByEmail != null &&
        _item.reportedByEmail!.isNotEmpty &&
        _currentUserEmail!.toLowerCase() == _item.reportedByEmail!.toLowerCase()) {
      return true;
    }
    if (_currentUserName != null &&
        _item.reportedByName != null &&
        _item.reportedByName!.isNotEmpty &&
        _currentUserName!.toLowerCase() == _item.reportedByName!.toLowerCase()) {
      return true;
    }
    if (_currentUserId != null &&
        _item.reportedById != null &&
        _item.reportedById!.isNotEmpty &&
        _currentUserId == _item.reportedById) {
      return true;
    }
    if (_currentUserEmail != null &&
        _item.reportedByName != null &&
        _item.reportedByName!.toLowerCase().contains(_currentUserEmail!.toLowerCase())) {
      return true;
    }
    return false;
  }

  bool get _canChangeStatus => _isModerator || _isItemCreator;

  Future<void> _showStatusSelectDialog() async {
    String selectedStatus = _item.status;

    await showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final customColors = context.appColors;

            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.card)),
              backgroundColor: customColors.surface,
              title: Text(
                'Update Case Status',
                style: AppTypography.cardTitle.copyWith(fontSize: 18),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _isModerator
                        ? 'Authorized as Campus Staff Moderator'
                        : 'Authorized as Original Item Reporter',
                    style: TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: customColors.primary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Select new case status:',
                    style: AppTypography.caption.copyWith(color: customColors.textSecondary),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: ['OPEN', 'MATCHED', 'CLAIMED', 'RETURNED', 'CLOSED'].map((st) {
                      final isSel = selectedStatus == st;
                      return ChoiceChip(
                        label: Text(st),
                        selected: isSel,
                        selectedColor: customColors.primary,
                        backgroundColor: customColors.background,
                        labelStyle: TextStyle(
                          fontFamily: AppTypography.fontFamily,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                          color: isSel ? Colors.white : customColors.textSecondary,
                        ),
                        side: BorderSide(
                          color: isSel ? customColors.primary : customColors.border,
                        ),
                        onSelected: (val) {
                          if (val) setDialogState(() => selectedStatus = st);
                        },
                      );
                    }).toList(),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text(
                    'Cancel',
                    style: TextStyle(color: customColors.textSecondary),
                  ),
                ),
                ElevatedButton(
                  onPressed: selectedStatus == _item.status
                      ? null
                      : () async {
                          Navigator.pop(ctx);
                          await _executeStatusUpdate(selectedStatus);
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: customColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.button)),
                  ),
                  child: const Text('Save Status'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _executeStatusUpdate(String newStatus) async {
    setState(() => _isUpdatingStatus = true);

    try {
      final updated = await _itemApi.updateStatus(_item.id, newStatus);
      if (!mounted) return;
      setState(() {
        _item = updated;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Item status updated to $newStatus successfully'),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update status: ${e.toString().split('\n').first}'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isUpdatingStatus = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final customColors = context.appColors;

    return Scaffold(
      backgroundColor: customColors.background,
      appBar: AppBar(
        title: Text(
          '${_item.type} Report Details',
          style: AppTypography.cardTitle.copyWith(fontSize: 18),
        ),
        backgroundColor: customColors.surface,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.share_outlined, color: customColors.textSecondary),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Case link copied to clipboard')),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: AppSpacing.maxContentWidth),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Hero Image Banner or Clean Placeholder
                if (_item.imageUrl != null && _item.imageUrl!.isNotEmpty)
                  Image.network(
                    _item.imageUrl!,
                    height: 240,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        _buildPlaceholderBanner(customColors),
                  )
                else
                  _buildPlaceholderBanner(customColors),

                Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Badges: Type & Status
                      Row(
                        children: [
                          TypeBadge(type: _item.type, fontSize: 12),
                          const SizedBox(width: AppSpacing.xs),
                          StatusChip(status: _item.status, fontSize: 12),
                          const Spacer(),
                          if (_item.createdAt != null && _item.createdAt!.isNotEmpty)
                            Text(
                              _item.createdAt!.length > 10
                                  ? _item.createdAt!.substring(0, 10)
                                  : _item.createdAt!,
                              style: AppTypography.caption.copyWith(color: customColors.textSecondary),
                            ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),

                      // Case Lifecycle Progress Tracker
                      CaseTimelineTracker(item: _item),
                      const SizedBox(height: AppSpacing.md),

                      // Title & Description Card
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: customColors.surface,
                          borderRadius: BorderRadius.circular(AppRadius.card),
                          border: Border.all(color: customColors.border),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _item.title,
                              style: AppTypography.pageTitle.copyWith(fontSize: 20),
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              _item.description.isNotEmpty
                                  ? _item.description
                                  : 'No further details provided by the reporter.',
                              style: AppTypography.bodySmall.copyWith(
                                color: customColors.textPrimary,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),

                      // Key Specifications Grid
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: customColors.surface,
                          borderRadius: BorderRadius.circular(AppRadius.card),
                          border: Border.all(color: customColors.border),
                        ),
                        child: Column(
                          children: [
                            _buildInfoRow(
                              Icons.location_on_outlined,
                              'Location',
                              _item.location.isNotEmpty ? _item.location : 'Campus General',
                              customColors,
                            ),
                            Divider(height: AppSpacing.lg, color: customColors.divider),
                            _buildInfoRow(
                              Icons.category_outlined,
                              'Category',
                              (_item.category != null && _item.category!.isNotEmpty)
                                  ? _item.category!
                                  : 'Uncategorized',
                              customColors,
                            ),
                            Divider(height: AppSpacing.lg, color: customColors.divider),
                            _buildInfoRow(
                              Icons.person_outline,
                              'Reported By',
                              _item.reportedByName != null && _item.reportedByName!.isNotEmpty
                                  ? _item.reportedByName!
                                  : 'Campus Member',
                              customColors,
                              trailingBadge: _isItemCreator ? 'YOU' : null,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),

                      // Automated Matching Action
                      AppButton(
                        text: 'Find Potential Matches for this Item',
                        variant: ButtonVariant.tertiary,
                        icon: Icons.auto_awesome,
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => MatchesScreen(initialItemId: _item.id),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: AppSpacing.sm),

                      // Claim This Item
                      if (!_isItemCreator && _item.status == 'OPEN') ...[
                        AppButton(
                          text: _item.isLost ? 'I Found This Item' : 'Claim: This Item is Mine',
                          variant: ButtonVariant.primary,
                          icon: Icons.verified_user_outlined,
                          onPressed: () async {
                            final claim = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => MultiStepClaimScreen(
                                  itemId: _item.id,
                                  itemTitle: _item.title,
                                  itemCategory: _item.category,
                                  itemLocation: _item.location,
                                ),
                              ),
                            );
                            if (claim != null && mounted) {
                              setState(() {
                                _item = Item(
                                  id: _item.id,
                                  type: _item.type,
                                  title: _item.title,
                                  description: _item.description,
                                  status: 'CLAIMED',
                                  location: _item.location,
                                  imageUrl: _item.imageUrl,
                                  reportedByName: _item.reportedByName,
                                  reportedByEmail: _item.reportedByEmail,
                                  reportedById: _item.reportedById,
                                  category: _item.category,
                                  createdAt: _item.createdAt,
                                  eventFrom: _item.eventFrom,
                                  eventTo: _item.eventTo,
                                  custodyStatus: _item.custodyStatus,
                                );
                              });
                            }
                          },
                        ),
                        const SizedBox(height: AppSpacing.sm),
                      ],

                      // Status Updates - Authorized Roles Only
                      if (_canChangeStatus) ...[
                        AppButton(
                          text: _isModerator ? 'Change Status (Staff Moderator)' : 'Update Case Status',
                          variant: ButtonVariant.secondary,
                          icon: Icons.edit_note_rounded,
                          isLoading: _isUpdatingStatus,
                          onPressed: _showStatusSelectDialog,
                        ),
                        const SizedBox(height: AppSpacing.xs),

                        if (_item.status != 'CLOSED') ...[
                          AppButton(
                            text: 'Close Case (Resolved)',
                            variant: ButtonVariant.danger,
                            icon: Icons.check_circle_outline,
                            onPressed: () async {
                              final confirm = await ConfirmDialog.show(
                                context,
                                title: 'Close Case?',
                                message: 'Are you sure you want to mark "${_item.title}" as CLOSED? This indicates the item has been resolved.',
                                confirmText: 'Close Case',
                                isDestructive: true,
                              );
                              if (confirm == true) {
                                await _executeStatusUpdate('CLOSED');
                              }
                            },
                          ),
                        ],
                      ] else ...[
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(AppSpacing.md),
                          decoration: BoxDecoration(
                            color: customColors.surface,
                            borderRadius: BorderRadius.circular(AppRadius.input),
                            border: Border.all(color: customColors.border),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.lock_outline_rounded, color: customColors.textSecondary, size: 18),
                              const SizedBox(width: AppSpacing.xs),
                              Expanded(
                                child: Text(
                                  'The status of this case can only be changed by its reporter or campus security.',
                                  style: AppTypography.caption.copyWith(color: customColors.textSecondary),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
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

  Widget _buildInfoRow(
    IconData icon,
    String label,
    String value,
    AppCustomColors colors, {
    String? trailingBadge,
  }) {
    return Row(
      children: [
        Icon(icon, size: 18, color: colors.textSecondary),
        const SizedBox(width: AppSpacing.sm),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: AppTypography.caption.copyWith(color: colors.textSecondary)),
            Text(
              value,
              style: TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: colors.textPrimary,
              ),
            ),
          ],
        ),
        if (trailingBadge != null) ...[
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: colors.primaryLight,
              borderRadius: BorderRadius.circular(AppRadius.pill),
            ),
            child: Text(
              trailingBadge,
              style: TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: colors.primary,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildPlaceholderBanner(AppCustomColors customColors) {
    return Container(
      height: 160,
      color: customColors.surface,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _item.isLost ? Icons.search_rounded : Icons.inventory_2_outlined,
              size: 40,
              color: customColors.textSecondary,
            ),
            const SizedBox(height: 8),
            Text(
              'No photo attached to this report',
              style: AppTypography.caption.copyWith(color: customColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
