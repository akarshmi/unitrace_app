import 'package:flutter/material.dart';
import '../../../core/core.dart';
import '../../auth/auth.dart';
import '../../items/items.dart';
import '../../settings/screens/settings_screen.dart';
import 'moderator_desk_screen.dart';
import 'moderator_item_review_screen.dart';
import 'moderator_profile_screen.dart';

class ModeratorHomeScreen extends StatefulWidget {
  const ModeratorHomeScreen({super.key});

  @override
  State<ModeratorHomeScreen> createState() => _ModeratorHomeScreenState();
}

class _ModeratorHomeScreenState extends State<ModeratorHomeScreen> {
  final ItemApi _itemApi = ItemApi();
  final AuthApi _authApi = AuthApi();

  String _selectedType = 'FOUND'; // FOUND or LOST
  String _selectedStatus = 'OPEN'; // OPEN, MATCHED, CLAIMED, CLOSED
  List<Item> _items = [];
  bool _isLoading = true;
  String? _errorMessage;
  int _currentNavIndex = 0;

  int _openLostCount = 0;
  int _openFoundCount = 0;
  int _matchedCount = 0;
  String? _staffEmail;

  @override
  void initState() {
    super.initState();
    _loadStaffInfo();
    _loadItems();
    _loadStats();
  }

  Future<void> _loadStaffInfo() async {
    final email = await TokenStorage.getUserEmail();
    if (mounted) {
      setState(() => _staffEmail = email);
    }
  }

  Future<void> _loadStats() async {
    try {
      final lostOpen = await _itemApi.getItems(type: 'LOST', status: 'OPEN', size: 100);
      final foundOpen = await _itemApi.getItems(type: 'FOUND', status: 'OPEN', size: 100);
      final matched = await _itemApi.getItems(type: 'FOUND', status: 'MATCHED', size: 100);
      if (mounted) {
        setState(() {
          _openLostCount = lostOpen.length;
          _openFoundCount = foundOpen.length;
          _matchedCount = matched.length;
        });
      }
    } catch (_) {
      // Non-blocking for stats preview
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
    } catch (e) {
      if (!mounted) return;
      final msg = e.toString().split('\n').first;
      setState(() {
        _isLoading = false;
        _errorMessage = msg;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load queue: $msg')),
      );
    }
  }

  Future<void> _handleLogout() async {
    await _authApi.logout();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final customColors = context.appColors;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: customColors.navyPrimary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.admin_panel_settings_rounded,
                color: customColors.accentAmber,
                size: 22,
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Text(
                      'UniTrace',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: colorScheme.onPrimary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Mandatory STAFF badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: customColors.accentAmber,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'STAFF',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.8,
                          color: customColors.navyPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
                Text(
                  'Campus Moderator Portal',
                  style: TextStyle(
                    fontSize: 11,
                    color: colorScheme.onPrimary.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ],
        ),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.settings_outlined, color: colorScheme.onPrimary),
            tooltip: 'Server Settings',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.refresh, color: colorScheme.onPrimary),
            tooltip: 'Refresh',
            onPressed: () {
              _loadItems();
              _loadStats();
            },
          ),
          IconButton(
            icon: Icon(Icons.logout_rounded, color: colorScheme.onPrimary),
            tooltip: 'Logout',
            onPressed: _handleLogout,
          ),
        ],
      ),
      body: _buildBody(customColors, colorScheme),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentNavIndex,
        selectedItemColor: customColors.accentAmber,
        unselectedItemColor: Colors.white70,
        backgroundColor: customColors.navyPrimary,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ModeratorItemReviewScreen()),
            ).then((_) {
              _loadItems();
              _loadStats();
            });
          } else if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ModeratorDeskScreen()),
            ).then((_) {
              _loadItems();
              _loadStats();
            });
          } else if (index == 3) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ModeratorProfileScreen()),
            );
          } else {
            setState(() => _currentNavIndex = index);
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_rounded),
            label: 'Overview',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.fact_check_rounded),
            label: 'Review Queue',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.storefront_rounded),
            label: 'Campus Desk',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_pin_rounded),
            label: 'Profile',
          ),
        ],
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
            _loadStats();
          }
        },
        backgroundColor: customColors.accentAmber,
        foregroundColor: customColors.navyPrimary,
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'Log Item',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildBody(AppCustomColors customColors, ColorScheme colorScheme) {
    return RefreshIndicator(
      onRefresh: () async {
        await _loadItems();
        await _loadStats();
      },
      child: CustomScrollView(
        slivers: [
          // Moderator Banner and Stats
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Moderator greeting bar
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: customColors.navySurface,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: customColors.accentAmber.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.verified_user_rounded, color: customColors.accentAmber, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Logged in as Campus Staff (${_staffEmail ?? "Moderator"})',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Quick Stats Cards
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          title: 'Open Lost',
                          count: _openLostCount,
                          color: const Color(0xFFEF4444),
                          icon: Icons.search_rounded,
                          onTap: () {
                            setState(() {
                              _selectedType = 'LOST';
                              _selectedStatus = 'OPEN';
                            });
                            _loadItems();
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildStatCard(
                          title: 'Open Found',
                          count: _openFoundCount,
                          color: const Color(0xFF10B981),
                          icon: Icons.inventory_2_rounded,
                          onTap: () {
                            setState(() {
                              _selectedType = 'FOUND';
                              _selectedStatus = 'OPEN';
                            });
                            _loadItems();
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildStatCard(
                          title: 'Matched',
                          count: _matchedCount,
                          color: customColors.accentAmber,
                          icon: Icons.link_rounded,
                          onTap: () {
                            setState(() {
                              _selectedType = 'FOUND';
                              _selectedStatus = 'MATCHED';
                            });
                            _loadItems();
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Quick shortcuts row
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const ModeratorItemReviewScreen()),
                            ).then((_) {
                              _loadItems();
                              _loadStats();
                            });
                          },
                          icon: const Icon(Icons.fact_check_rounded, size: 18),
                          label: const Text('Review Queue'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: customColors.navyPrimary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const ModeratorDeskScreen()),
                            ).then((_) {
                              _loadItems();
                              _loadStats();
                            });
                          },
                          icon: const Icon(Icons.storefront_rounded, size: 18),
                          label: const Text('Desk Hand-over'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: customColors.navyPrimary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Filter Segment Controls: Type & Status
                  Text(
                    'Item Management Queue',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: customColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Type Selector
                  Container(
                    decoration: BoxDecoration(
                      color: customColors.slateSubtle,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.all(4),
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildTypeSegment('FOUND', 'Found Items', customColors),
                        ),
                        Expanded(
                          child: _buildTypeSegment('LOST', 'Lost Reports', customColors),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Status Chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: ['OPEN', 'MATCHED', 'CLAIMED', 'CLOSED'].map((st) {
                        final isSel = _selectedStatus == st;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(
                              st,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: isSel ? customColors.navyPrimary : customColors.textPrimary,
                              ),
                            ),
                            selected: isSel,
                            selectedColor: customColors.accentAmber,
                            backgroundColor: customColors.slateSubtle,
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
          ),

          // Content List
          if (_isLoading)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_errorMessage != null)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 48, color: customColors.error),
                      const SizedBox(height: 12),
                      Text(
                        _errorMessage!,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: customColors.textPrimary),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadItems,
                        child: const Text('Retry Query'),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else if (_items.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.check_circle_outline_rounded,
                        size: 56,
                        color: customColors.accentAmber,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No $_selectedStatus $_selectedType items in queue',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: customColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Campus queue for this category is clear.',
                        style: TextStyle(
                          fontSize: 13,
                          color: customColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
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
                        _loadStats();
                      },
                    );
                  },
                  childCount: _items.length,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required int count,
    required Color color,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 16, color: color),
                const Spacer(),
                Text(
                  count.toString(),
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              title,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeSegment(String type, String label, AppCustomColors customColors) {
    final isSelected = _selectedType == type;
    return GestureDetector(
      onTap: () {
        if (_selectedType != type) {
          setState(() => _selectedType = type);
          _loadItems();
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? customColors.navyPrimary : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.white : customColors.textMuted,
            ),
          ),
        ),
      ),
    );
  }
}
