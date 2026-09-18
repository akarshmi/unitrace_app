import 'package:flutter/material.dart';
import '../../../core/core.dart';
import '../data/item_api.dart';
import '../models/item.dart';
import '../models/match_result.dart';
import '../widgets/match_card.dart';
import '../widgets/notifications_modal.dart';
import 'item_detail_screen.dart';
import 'multi_step_claim_screen.dart';

/// Standardized MatchesScreen conforming to Section 12 & 13 of UniTrace Master Design:
/// Rules:
/// - Primary brand color (#3157D5) represents potential matches (NOT green)
/// - Trust copy: "Potential matches are identified automatically. Final verification is handled by the Security Office."
/// - Clear confidence ratings & comparison flows
class MatchesScreen extends StatefulWidget {
  final String? initialItemId;

  const MatchesScreen({super.key, this.initialItemId});

  @override
  State<MatchesScreen> createState() => _MatchesScreenState();
}

class _MatchesScreenState extends State<MatchesScreen> {
  final ItemApi _itemApi = ItemApi();
  List<MatchCandidate> _matches = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchMatches();
  }

  Future<void> _fetchMatches() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final list = await _itemApi.getMatches(itemId: widget.initialItemId);
      if (!mounted) return;
      setState(() {
        _matches = list;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Failed to load matches: ${e.toString().split('\n').first}';
        _isLoading = false;
      });
    }
  }

  Future<void> _handleClaim(MatchCandidate match) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MultiStepClaimScreen(
          itemId: match.foundItem.id,
          itemTitle: match.foundItem.title,
          itemCategory: match.foundItem.category,
          itemLocation: match.foundItem.location,
        ),
      ),
    );

    if (result != null && mounted) {
      _fetchMatches();
    }
  }

  void _openDetail(Item item) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ItemDetailScreen(item: item)),
    ).then((_) => _fetchMatches());
  }

  @override
  Widget build(BuildContext context) {
    final customColors = context.appColors;

    return Scaffold(
      backgroundColor: customColors.background,
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.auto_awesome, color: customColors.primary, size: 20),
            const SizedBox(width: 8),
            Text(
              'Potential Matches',
              style: AppTypography.cardTitle.copyWith(fontSize: 18),
            ),
          ],
        ),
        backgroundColor: customColors.surface,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.notifications_none_outlined, color: customColors.textSecondary),
            tooltip: 'Notifications',
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: customColors.surface,
                shape: const RoundedRectangleBorder(
                  borderRadius: AppRadius.bottomSheet,
                ),
                builder: (_) => const NotificationsModal(),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.refresh, color: customColors.textSecondary),
            tooltip: 'Refresh',
            onPressed: _fetchMatches,
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: AppSpacing.maxContentWidth),
          child: Column(
            children: [
              // System Matching Trust Banner
              Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 12),
                color: customColors.primaryLight,
                child: Row(
                  children: [
                    Icon(Icons.info_outline, size: 18, color: customColors.primary),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        'Technology identifies the possibility. The Security Office verifies ownership before item handover.',
                        style: AppTypography.caption.copyWith(
                          color: customColors.primary,
                          fontWeight: FontWeight.w500,
                          height: 1.35,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Matches List
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(strokeWidth: 2.5),
                            SizedBox(height: AppSpacing.md),
                            Text(
                              'Correlating lost and found reports...',
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.textSecondaryLight,
                              ),
                            ),
                          ],
                        ),
                      )
                    : _errorMessage != null
                        ? ErrorStateView(
                            message: _errorMessage!,
                            onRetry: _fetchMatches,
                          )
                        : _matches.isEmpty
                            ? EmptyStateView(
                                icon: Icons.search_off_rounded,
                                title: 'No potential matches yet',
                                description:
                                    'We will keep monitoring reports as new items are turned into the campus Security Office.',
                                actionText: 'Refresh Matches',
                                onAction: _fetchMatches,
                              )
                            : RefreshIndicator(
                                onRefresh: _fetchMatches,
                                child: ListView.builder(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: AppSpacing.sm,
                                    horizontal: AppSpacing.xs,
                                  ),
                                  itemCount: _matches.length,
                                  itemBuilder: (context, index) {
                                    final match = _matches[index];
                                    return MatchCard(
                                      match: match,
                                      onTapLost: () => _openDetail(match.lostItem),
                                      onTapFound: () => _openDetail(match.foundItem),
                                      onClaim: () => _handleClaim(match),
                                    );
                                  },
                                ),
                              ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
