import 'package:flutter/material.dart';
import '../api/auth_api.dart';
import '../api/item_api.dart';
import '../models/item.dart';
import '../theme/app_theme.dart';
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
      final items = await _itemApi.getItems(type: _selectedType);
      if (!mounted) return;
      setState(() {
        _items = items;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString().split('\n').first;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load items: $_errorMessage')),
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
            icon: Icon(Icons.refresh, color: colorScheme.onPrimary),
            tooltip: 'Refresh',
            onPressed: _loadItems,
          ),
          IconButton(
            icon: Icon(Icons.logout, color: colorScheme.onPrimary),
            tooltip: 'Logout',
            onPressed: _handleLogout,
          ),
        ],
      ),
      body: Column(
        children: [
          // Top Segmented Toggle: Lost / Found
          Container(
            color: colorScheme.surface,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Container(
              decoration: BoxDecoration(
                color: customColors.slateSubtle,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _buildSegmentButton(
                      label: 'Lost Items',
                      type: 'LOST',
                      icon: Icons.search_rounded,
                      customColors: customColors,
                      colorScheme: colorScheme,
                    ),
                  ),
                  Expanded(
                    child: _buildSegmentButton(
                      label: 'Found Items',
                      type: 'FOUND',
                      icon: Icons.inventory_2_outlined,
                      customColors: customColors,
                      colorScheme: colorScheme,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Divider(height: 1, color: customColors.borderDivider),

          // Body: Pull-to-refresh List
          Expanded(
            child: RefreshIndicator(
              color: customColors.navyPrimary,
              onRefresh: _loadItems,
              child: _buildBody(customColors, colorScheme),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push<bool>(
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
        foregroundColor: customColors.navyPrimary, // Navy on Amber contrast: 7.95:1
        icon: Icon(Icons.add, color: customColors.navyPrimary),
        label: Text(
          _selectedType == 'LOST' ? 'Report Lost' : 'Report Found',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: customColors.navyPrimary,
          ),
        ),
      ),
    );
  }

  Widget _buildSegmentButton({
    required String label,
    required String type,
    required IconData icon,
    required AppCustomColors customColors,
    required ColorScheme colorScheme,
  }) {
    final isSelected = _selectedType == type;

    return GestureDetector(
      onTap: () {
        if (_selectedType != type) {
          setState(() => _selectedType = type);
          _loadItems();
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? customColors.navyPrimary : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? customColors.accentAmber : customColors.textMuted,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                color: isSelected ? colorScheme.onPrimary : customColors.textMuted,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(AppCustomColors customColors, ColorScheme colorScheme) {
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(color: customColors.navyPrimary),
      );
    }

    if (_errorMessage != null && _items.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.cloud_off_outlined, size: 48, color: customColors.textMuted),
              const SizedBox(height: 12),
              Text(
                'Could not connect to backend server:\n$_errorMessage',
                textAlign: TextAlign.center,
                style: TextStyle(color: customColors.textMuted),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _loadItems,
                icon: Icon(Icons.refresh, color: colorScheme.onPrimary),
                label: Text('Try Again', style: TextStyle(color: colorScheme.onPrimary)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_items.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _selectedType == 'LOST' ? Icons.search_off_rounded : Icons.check_circle_outline,
                size: 64,
                color: customColors.textMuted.withOpacity(0.5),
              ),
              const SizedBox(height: 16),
              Text(
                'No ${_selectedType.toLowerCase()} items reported yet',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: customColors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Tap the button below to report a new item.',
                style: TextStyle(fontSize: 13, color: customColors.textMuted),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(top: 8, bottom: 88),
      itemCount: _items.length,
      itemBuilder: (context, index) {
        final item = _items[index];
        return ItemCard(
          item: item,
          onTap: () async {
            final refreshed = await Navigator.push<bool>(
              context,
              MaterialPageRoute(
                builder: (_) => ItemDetailScreen(item: item),
              ),
            );
            if (refreshed == true) {
              _loadItems();
            }
          },
        );
      },
    );
  }
}
