import 'package:flutter/material.dart';
import '../../../core/core.dart';
import '../../auth/auth.dart';
import '../../settings/screens/settings_screen.dart';
import '../data/item_api.dart';
import '../models/item.dart';
import '../widgets/item_card.dart';
import 'create_item_screen.dart';
import 'item_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ItemApi _itemApi = ItemApi();
  final AuthApi _authApi = AuthApi();

  String _selectedType = 'LOST'; // 'LOST' or 'FOUND'
  String _selectedStatus = 'OPEN'; // 'OPEN', 'MATCHED', 'CLAIMED', 'CLOSED'
  List<Item> _items = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Backend requires both type and status query parameters
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
        SnackBar(content: Text('Failed to load items: $msg')),
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
                Icons.track_changes_rounded,
                color: customColors.accentAmber,
                size: 22,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'UniTrace',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
                color: colorScheme.onPrimary,
              ),
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
            onPressed: _loadItems,
          ),
          IconButton(
            icon: Icon(Icons.logout_rounded, color: colorScheme.onPrimary),
            tooltip: 'Logout',
            onPressed: _handleLogout,
          ),
        ],
      ),
      body: Column(
        children: [
          // Segmented Control for Type (LOST vs FOUND)
          Container(
            color: colorScheme.surface,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: customColors.slateSubtle,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.all(4),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildTypeSegment('LOST', 'Lost Items', customColors),
                      ),
                      Expanded(
                        child: _buildTypeSegment('FOUND', 'Found Items', customColors),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),

                // Status Filter Chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: ['OPEN', 'MATCHED', 'CLAIMED', 'CLOSED'].map((st) {
                      final isSel = _selectedStatus == st;
                      return Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: ChoiceChip(
                          label: Text(
                            st,
                            style: TextStyle(
                              fontSize: 11,
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

          // Items List
          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadItems,
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _errorMessage != null
                      ? Center(
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
                                  child: const Text('Try Again'),
                                ),
                              ],
                            ),
                          ),
                        )
                      : _items.isEmpty
                          ? EmptyStateView(
                              icon: _selectedType == 'LOST'
                                  ? Icons.search_off_rounded
                                  : Icons.inventory_2_outlined,
                              title: 'No $_selectedStatus $_selectedType items',
                              description: _selectedType == 'LOST'
                                  ? 'No reported lost items matching this status.'
                                  : 'No reported found items matching this status.',
                              actionText: 'Refresh',
                              onAction: _loadItems,
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
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
        backgroundColor: customColors.accentAmber,
        foregroundColor: customColors.navyPrimary,
        icon: const Icon(Icons.add_rounded),
        label: Text(
          _selectedType == 'LOST' ? 'Report Lost' : 'Report Found',
          style: const TextStyle(fontWeight: FontWeight.bold),
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
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? customColors.navyPrimary : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.white : customColors.textMuted,
            ),
          ),
        ),
      ),
    );
  }
}
