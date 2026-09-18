import 'package:flutter/material.dart';
import '../../../core/core.dart';
import '../../auth/auth.dart';
import '../../moderator/screens/security_verification_screen.dart';
import '../../settings/screens/settings_screen.dart';
import '../data/item_api.dart';
import '../data/notification_storage.dart';
import '../models/item.dart';
import '../widgets/item_card.dart';
import '../widgets/notifications_modal.dart';
import 'create_item_screen.dart';
import 'item_detail_screen.dart';
import 'matches_screen.dart';

/// Standardized HomeScreen conforming to Section 20 & 21 of UniTrace Master Design:
/// Rules:
/// - Clean command center header: "Good morning / Welcome", "What are you looking for today?"
/// - Primary dual-action quick cards: [ I Lost Something ] and [ I Found Something ]
/// - Potential matches callout in brand primary color (#3157D5)
/// - Segmented status tabs with clear text
/// - Clean bottom navigation affordances & list presentation
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ItemApi _itemApi = ItemApi();
  final AuthApi _authApi = AuthApi();

  String _selectedType = 'LOST'; // 'LOST' or 'FOUND'
  String _selectedStatus = 'OPEN'; // 'OPEN', 'MATCHED', 'CLAIMED', 'RETURNED', 'CLOSED'
  List<Item> _items = [];
  bool _isLoading = true;
  String? _errorMessage;
  int _unreadNotifications = 0;
  String? _userRole;

  @override
  void initState() {
    super.initState();
    _loadUserRole();
    _loadItems();
    _checkUnreadNotifications();
  }

  Future<void> _loadUserRole() async {
    final role = await TokenStorage.getUserRole();
    if (mounted) {
      setState(() => _userRole = role);
    }
  }

  Future<void> _checkUnreadNotifications() async {
    final count = await NotificationStorage.getUnreadCount();
    if (mounted) {
      setState(() => _unreadNotifications = count);
    }
  }

  Future<void> _loadItems() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final items = await _itemApi.getItems(
        type: _selectedType,
        status: _selectedStatus,
      );
      if (!mounted) return;
      setState(() {
        _items = items;
        _isLoading = false;
      });
      _checkUnreadNotifications();
    } catch (e) {
      if (!mounted) return;
      final msg = e.toString().split('\n').first;
      setState(() {
        _isLoading = false;
        _errorMessage = msg;
      });
    }
  }

  Future<void> _handleLogout() async {
    final confirmed = await ConfirmDialog.show(
      context,
      title: 'Sign Out',
      message: 'Are you sure you want to sign out of UniTrace?',
      confirmText: 'Sign Out',
    );
    if (confirmed == true) {
      await _authApi.logout();
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final customColors = context.appColors;

    return Scaffold(
      backgroundColor: customColors.background,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: customColors.primary,
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: const Icon(
                Icons.shield_outlined,
                color: Colors.white,
                size: 18,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'UniTrace',
              style: AppTypography.cardTitle.copyWith(
                fontSize: 18,
                color: customColors.textPrimary,
              ),
            ),
          ],
        ),
        backgroundColor: customColors.surface,
        elevation: 0,
        actions: [
          // Potential Matches button
          IconButton(
            icon: Icon(Icons.auto_awesome, color: customColors.primary, size: 22),
            tooltip: 'View Potential Matches',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MatchesScreen()),
              ).then((_) {
                _loadItems();
                _checkUnreadNotifications();
              });
            },
          ),
          // Notifications
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: Icon(Icons.notifications_none_outlined, color: customColors.textSecondary, size: 22),
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
                  ).then((_) => _checkUnreadNotifications());
                },
              ),
              if (_unreadNotifications > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: customColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '$_unreadNotifications',
                      style: const TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          // Security desk (for campus staff)
          if (_userRole == 'MODERATOR' ||
              _userRole == 'ADMIN' ||
              _userRole == 'SECURITY' ||
              _userRole == 'STAFF')
            IconButton(
              icon: Icon(Icons.security, color: customColors.primary, size: 22),
              tooltip: 'Security Office Desk',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SecurityVerificationScreen()),
                ).then((_) => _loadItems());
              },
            ),
          IconButton(
            icon: Icon(Icons.settings_outlined, color: customColors.textSecondary, size: 22),
            tooltip: 'Settings',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.logout_rounded, color: customColors.textSecondary, size: 22),
            tooltip: 'Logout',
            onPressed: _handleLogout,
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: AppSpacing.maxContentWidth),
          child: Column(
            children: [
              // Command Center Header & Primary Action Cards
              Container(
                color: customColors.surface,
                padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.sm, AppSpacing.md, AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Potential Matches Banner (Clean Primary Blue Callout)
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const MatchesScreen()),
                        ).then((_) {
                          _loadItems();
                          _checkUnreadNotifications();
                        });
                      },
                      borderRadius: BorderRadius.circular(AppRadius.input),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 10),
                        decoration: BoxDecoration(
                          color: customColors.primaryLight,
                          borderRadius: BorderRadius.circular(AppRadius.input),
                          border: Border.all(color: customColors.primary.withOpacity(0.2)),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.auto_awesome, color: customColors.primary, size: 16),
                            const SizedBox(width: AppSpacing.xs),
                            Text(
                              'Automated Matching Active',
                              style: TextStyle(
                                fontFamily: AppTypography.fontFamily,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: customColors.primary,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              'Check Possibilities',
                              style: AppTypography.caption.copyWith(
                                color: customColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(Icons.arrow_forward_ios, size: 11, color: customColors.primary),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // Quick Action Cards: [ I Lost Something ] & [ I Found Something ]
                    Row(
                      children: [
                        Expanded(
                          child: _buildActionCard(
                            title: 'I Lost Something',
                            subtitle: 'Create a lost report',
                            icon: Icons.search_rounded,
                            isLost: true,
                            customColors: customColors,
                            onTap: () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const CreateItemScreen(initialType: 'LOST'),
                                ),
                              );
                              if (result == true) _loadItems();
                            },
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: _buildActionCard(
                            title: 'I Found Something',
                            subtitle: 'Hand over / report',
                            icon: Icons.inventory_2_outlined,
                            isLost: false,
                            customColors: customColors,
                            onTap: () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const CreateItemScreen(initialType: 'FOUND'),
                                ),
                              );
                              if (result == true) _loadItems();
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // Segmented Report Type Selector
                    Container(
                      decoration: BoxDecoration(
                        color: customColors.background,
                        borderRadius: BorderRadius.circular(AppRadius.input),
                        border: Border.all(color: customColors.border),
                      ),
                      padding: const EdgeInsets.all(3),
                      child: Row(
                        children: [
                          Expanded(child: _buildTypeSegment('LOST', 'Lost Reports', customColors)),
                          Expanded(child: _buildTypeSegment('FOUND', 'Found Reports', customColors)),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),

                    // Status Chips
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: ['OPEN', 'MATCHED', 'CLAIMED', 'RETURNED', 'CLOSED'].map((st) {
                          final isSel = _selectedStatus == st;
                          return Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: ChoiceChip(
                              label: Text(st),
                              selected: isSel,
                              selectedColor: customColors.primary,
                              backgroundColor: customColors.surface,
                              labelStyle: TextStyle(
                                fontFamily: AppTypography.fontFamily,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: isSel ? Colors.white : customColors.textSecondary,
                              ),
                              side: BorderSide(
                                color: isSel ? customColors.primary : customColors.border,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(AppRadius.pill),
                              ),
                              onSelected: (selected) {
                                if (selected && _selectedStatus != st) {
                                  setState(() => _selectedStatus = st);
                                  _loadItems();
                                }
                              },
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),

              // Divider between controls and items
              Divider(height: 1, color: customColors.divider),

              // Items List
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _loadItems,
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
                      : _errorMessage != null
                          ? ErrorStateView(
                              message: _errorMessage!,
                              onRetry: _loadItems,
                            )
                          : _items.isEmpty
                              ? EmptyStateView(
                                  icon: _selectedType == 'LOST'
                                      ? Icons.search_off_rounded
                                      : Icons.inventory_2_outlined,
                                  title: 'No ${_selectedStatus.toLowerCase()} ${_selectedType.toLowerCase()} reports',
                                  description: _selectedType == 'LOST'
                                      ? 'No lost item reports currently match this filter.'
                                      : 'No found item reports currently match this filter.',
                                  actionText: 'Report ${_selectedType == 'LOST' ? 'Lost Item' : 'Found Item'}',
                                  onAction: () async {
                                    final result = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => CreateItemScreen(initialType: _selectedType),
                                      ),
                                    );
                                    if (result == true) _loadItems();
                                  },
                                )
                              : ListView.builder(
                                  padding: const EdgeInsets.fromLTRB(
                                    AppSpacing.xs,
                                    AppSpacing.sm,
                                    AppSpacing.xs,
                                    AppSpacing.page,
                                  ),
                                  itemCount: _items.length,
                                  itemBuilder: (context, index) {
                                    final item = _items[index];
                                    return ItemCard(
                                      item: item,
                                      onTap: () async {
                                        await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => ItemDetailScreen(item: item),
                                          ),
                                        );
                                        _loadItems();
                                      },
                                    );
                                  },
                                ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CreateItemScreen(initialType: _selectedType),
            ),
          );
          if (result == true) {
            _loadItems();
          }
        },
        backgroundColor: customColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: Text(
          _selectedType == 'LOST' ? 'Report Lost' : 'Report Found',
          style: AppTypography.button,
        ),
      ),
    );
  }

  Widget _buildActionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isLost,
    required AppCustomColors customColors,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: customColors.background,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: customColors.border),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.card),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: isLost ? customColors.primaryLight : customColors.successBg,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    size: 18,
                    color: isLost ? customColors.primary : customColors.success,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontFamily: AppTypography.fontFamily,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: customColors.textPrimary,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: AppTypography.caption.copyWith(color: customColors.textSecondary),
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

  Widget _buildTypeSegment(String type, String label, AppCustomColors customColors) {
    final isSelected = _selectedType == type;
    return GestureDetector(
      onTap: () {
        if (_selectedType != type) {
          setState(() {
            _selectedType = type;
          });
          _loadItems();
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 9),
        decoration: BoxDecoration(
          color: isSelected ? customColors.surface : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.sm),
          boxShadow: isSelected ? AppShadows.card : null,
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected ? customColors.primary : customColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}
