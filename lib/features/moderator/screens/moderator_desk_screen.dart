import 'package:flutter/material.dart';
import '../../../core/core.dart';
import '../../items/items.dart';

class ModeratorDeskScreen extends StatefulWidget {
  const ModeratorDeskScreen({super.key});

  @override
  State<ModeratorDeskScreen> createState() => _ModeratorDeskScreenState();
}

class _ModeratorDeskScreenState extends State<ModeratorDeskScreen> {
  final ItemApi _itemApi = ItemApi();
  final _searchController = TextEditingController();

  List<Item> _deskItems = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadDeskItems();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadDeskItems() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Desk typically handles FOUND items that are OPEN or MATCHED
      final openItems = await _itemApi.getItems(type: 'FOUND', status: 'OPEN', size: 50);
      final matchedItems = await _itemApi.getItems(type: 'FOUND', status: 'MATCHED', size: 50);
      if (!mounted) return;
      setState(() {
        _deskItems = [...matchedItems, ...openItems];
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
        SnackBar(content: Text('Failed to load desk items: $msg')),
      );
    }
  }

  Future<void> _handleClaimHandover(Item item) async {
    final studentIdController = TextEditingController();
    final claimantNameController = TextEditingController();
    bool idChecked = false;
    bool itemVerified = false;

    await showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final customColors = context.appColors;

            return AlertDialog(
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: customColors.accentAmber,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'STAFF',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: customColors.navyPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Hand-over & Claim Verification',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Item: ${item.title}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    Text(
                      'Reported Location: ${item.location}',
                      style: TextStyle(color: customColors.textMuted, fontSize: 12),
                    ),
                    const Divider(height: 20),
                    const Text(
                      'Claimant Identification',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: claimantNameController,
                      decoration: const InputDecoration(
                        labelText: 'Claimant Full Name',
                        isDense: true,
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: studentIdController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Student Reg Number (6 digits)',
                        isDense: true,
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    CheckboxListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      value: idChecked,
                      title: const Text('Physical University Student ID Verified', style: TextStyle(fontSize: 12)),
                      onChanged: (val) => setDialogState(() => idChecked = val ?? false),
                    ),
                    CheckboxListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      value: itemVerified,
                      title: const Text('Claimant provided proof of ownership (e.g. passcode, receipts)', style: TextStyle(fontSize: 12)),
                      onChanged: (val) => setDialogState(() => itemVerified = val ?? false),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: (!idChecked || !itemVerified)
                      ? null
                      : () async {
                          Navigator.pop(ctx);
                          try {
                            // Update case status to CLAIMED
                            await _itemApi.updateStatus(item.id, 'CLAIMED');
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Item "${item.title}" successfully handed over and marked CLAIMED',
                                ),
                              ),
                            );
                            _loadDeskItems();
                          } catch (e) {
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Hand-over failed: ${e.toString().split('\n').first}')),
                            );
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: customColors.navyPrimary,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Confirm Hand-over'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final customColors = context.appColors;
    final colorScheme = Theme.of(context).colorScheme;

    final filterText = _searchController.text.trim().toLowerCase();
    final displayedItems = filterText.isEmpty
        ? _deskItems
        : _deskItems.where((i) =>
            i.title.toLowerCase().contains(filterText) ||
            i.location.toLowerCase().contains(filterText) ||
            (i.reportedByName?.toLowerCase().contains(filterText) ?? false)).toList();

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        title: Row(
          children: [
            Text(
              'Campus Intake Desk',
              style: TextStyle(color: colorScheme.onPrimary, fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: customColors.accentAmber,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'STAFF',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  color: customColors.navyPrimary,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDeskItems,
          ),
        ],
      ),
      body: Column(
        children: [
          // Desk Station Header Card
          Container(
            padding: const EdgeInsets.all(16),
            color: customColors.navySurface,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Icon(Icons.meeting_room_rounded, color: customColors.accentAmber, size: 22),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        'Central Campus Lost & Found Station #1',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          final res = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const CreateItemScreen(initialType: 'FOUND'),
                            ),
                          );
                          if (res == true) _loadDeskItems();
                        },
                        icon: const Icon(Icons.inventory, size: 16),
                        label: const Text('New Desk Intake'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: customColors.accentAmber,
                          foregroundColor: customColors.navyPrimary,
                          textStyle: const TextStyle(fontWeight: FontWeight.bold),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Search Bar
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _searchController,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Search desk locker inventory...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {});
                        },
                      )
                    : null,
                isDense: true,
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: customColors.borderDivider),
                ),
              ),
            ),
          ),

          // List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage != null
                    ? Center(child: Text(_errorMessage!))
                    : displayedItems.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.inventory_2_outlined, size: 48, color: customColors.textMuted),
                                const SizedBox(height: 10),
                                Text(
                                  'No items currently held in desk lockers',
                                  style: TextStyle(color: customColors.textMuted),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                            itemCount: displayedItems.length,
                            itemBuilder: (context, index) {
                              final item = displayedItems[index];
                              final isMatched = item.status == 'MATCHED';

                              return Card(
                                margin: const EdgeInsets.only(bottom: 10),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  side: BorderSide(
                                    color: isMatched ? customColors.accentAmber : customColors.borderDivider,
                                    width: isMatched ? 1.5 : 1.0,
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: customColors.navyPrimary.withOpacity(0.08),
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              'Locker #A-${(index % 12) + 1}',
                                              style: TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.bold,
                                                color: customColors.navyPrimary,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          StatusPill(status: item.status, fontSize: 11),
                                          const Spacer(),
                                          Text(
                                            item.createdAt != null && item.createdAt!.length >= 10
                                                ? item.createdAt!.substring(0, 10)
                                                : '',
                                            style: TextStyle(fontSize: 11, color: customColors.textMuted),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        item.title,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: customColors.textPrimary,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Intake location: ${item.location.isNotEmpty ? item.location : "Campus"}',
                                        style: TextStyle(fontSize: 12, color: customColors.textMuted),
                                      ),
                                      const Divider(height: 16),
                                      Row(
                                        children: [
                                          OutlinedButton(
                                            onPressed: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (_) => ItemDetailScreen(item: item),
                                                ),
                                              ).then((_) => _loadDeskItems());
                                            },
                                            child: const Text('Details', style: TextStyle(fontSize: 12)),
                                          ),
                                          const Spacer(),
                                          ElevatedButton.icon(
                                            onPressed: () => _handleClaimHandover(item),
                                            icon: const Icon(Icons.handshake_rounded, size: 16),
                                            label: const Text('Verify & Hand-over', style: TextStyle(fontSize: 12)),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: customColors.accentAmber,
                                              foregroundColor: customColors.navyPrimary,
                                              textStyle: const TextStyle(fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }
}
