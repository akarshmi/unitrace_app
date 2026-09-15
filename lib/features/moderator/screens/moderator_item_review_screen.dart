import 'package:flutter/material.dart';
import '../../../core/core.dart';
import '../../items/items.dart';

class ModeratorItemReviewScreen extends StatefulWidget {
  const ModeratorItemReviewScreen({super.key});

  @override
  State<ModeratorItemReviewScreen> createState() => _ModeratorItemReviewScreenState();
}

class _ModeratorItemReviewScreenState extends State<ModeratorItemReviewScreen> {
  final ItemApi _itemApi = ItemApi();
  String _type = 'FOUND';
  String _status = 'OPEN';
  List<Item> _items = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchItems();
  }

  Future<void> _fetchItems() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final items = await _itemApi.getItems(type: _type, status: _status);
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
        SnackBar(content: Text('Failed to load review queue: $msg')),
      );
    }
  }

  Future<void> _showStatusChangeDialog(Item item) async {
    String selectedNewStatus = item.status;
    final noteController = TextEditingController();

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final customColors = context.appColors;

            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: customColors.accentAmber,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'STAFF AUDIT',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            color: customColors.navyPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Update Case Status',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: customColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Item: "${item.title}" (${item.type})',
                    style: TextStyle(
                      fontSize: 13,
                      color: customColors.textMuted,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Select New Status',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: ['OPEN', 'MATCHED', 'CLAIMED', 'CLOSED'].map((st) {
                      final isSel = selectedNewStatus == st;
                      return ChoiceChip(
                        label: Text(
                          st,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isSel ? customColors.navyPrimary : customColors.textPrimary,
                          ),
                        ),
                        selected: isSel,
                        selectedColor: customColors.accentAmber,
                        onSelected: (val) {
                          if (val) setSheetState(() => selectedNewStatus = st);
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: noteController,
                    decoration: InputDecoration(
                      labelText: 'Moderator Audit Note (Optional)',
                      hintText: 'e.g. Verified claimant student card #882190',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      Navigator.pop(ctx);
                      await _executeStatusUpdate(item.id, selectedNewStatus);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: customColors.navyPrimary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('Confirm Status Change', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _executeStatusUpdate(String itemId, String newStatus) async {
    try {
      await _itemApi.updateStatus(itemId, newStatus);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Item status updated to $newStatus successfully')),
      );
      _fetchItems();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update status: ${e.toString().split('\n').first}')),
      );
    }
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
            Text(
              'Moderator Review Queue',
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
      ),
      body: Column(
        children: [
          // Filter Header Bar
          Container(
            padding: const EdgeInsets.all(12),
            color: Colors.white,
            child: Column(
              children: [
                // Type Switcher
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          if (_type != 'FOUND') {
                            setState(() => _type = 'FOUND');
                            _fetchItems();
                          }
                        },
                        style: OutlinedButton.styleFrom(
                          backgroundColor: _type == 'FOUND' ? customColors.navyPrimary : Colors.transparent,
                          foregroundColor: _type == 'FOUND' ? Colors.white : customColors.textPrimary,
                          side: BorderSide(color: customColors.navyPrimary),
                        ),
                        child: const Text('Found Items Queue'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          if (_type != 'LOST') {
                            setState(() => _type = 'LOST');
                            _fetchItems();
                          }
                        },
                        style: OutlinedButton.styleFrom(
                          backgroundColor: _type == 'LOST' ? customColors.navyPrimary : Colors.transparent,
                          foregroundColor: _type == 'LOST' ? Colors.white : customColors.textPrimary,
                          side: BorderSide(color: customColors.navyPrimary),
                        ),
                        child: const Text('Lost Claims Queue'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Status row
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: ['OPEN', 'MATCHED', 'CLAIMED', 'CLOSED'].map((st) {
                      final isSel = _status == st;
                      return Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: FilterChip(
                          label: Text(st),
                          selected: isSel,
                          selectedColor: customColors.accentAmber,
                          labelStyle: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                            color: isSel ? customColors.navyPrimary : customColors.textPrimary,
                          ),
                          onSelected: (val) {
                            if (val && _status != st) {
                              setState(() => _status = st);
                              _fetchItems();
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

          // Items Queue
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage != null
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(_errorMessage!),
                              const SizedBox(height: 12),
                              ElevatedButton(onPressed: _fetchItems, child: const Text('Retry')),
                            ],
                          ),
                        ),
                      )
                    : _items.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.playlist_add_check_circle_rounded,
                                    size: 54, color: customColors.accentAmber),
                                const SizedBox(height: 12),
                                Text(
                                  'Queue is Clear',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: customColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'No $_type items with status $_status',
                                  style: TextStyle(color: customColors.textMuted, fontSize: 13),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(14),
                            itemCount: _items.length,
                            itemBuilder: (context, index) {
                              final item = _items[index];
                              return Card(
                                margin: const EdgeInsets.only(bottom: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  side: BorderSide(color: customColors.borderDivider),
                                ),
                                elevation: 0,
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          TypeBadge(type: item.type, fontSize: 11),
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
                                        item.description.isNotEmpty
                                            ? item.description
                                            : 'No description provided',
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(fontSize: 13, color: customColors.textBody),
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          Icon(Icons.location_on, size: 14, color: customColors.navyPrimary),
                                          const SizedBox(width: 4),
                                          Text(
                                            item.location.isNotEmpty ? item.location : 'Campus General',
                                            style: TextStyle(fontSize: 12, color: customColors.textMuted),
                                          ),
                                          const Spacer(),
                                          Text(
                                            'By: ${item.reportedByName ?? "Campus Member"}',
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontStyle: FontStyle.italic,
                                              color: customColors.textMuted,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const Divider(height: 18),
                                      Row(
                                        children: [
                                          OutlinedButton(
                                            onPressed: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (_) => ItemDetailScreen(item: item),
                                                ),
                                              ).then((_) => _fetchItems());
                                            },
                                            style: OutlinedButton.styleFrom(
                                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                                            ),
                                            child: const Text('View Full Case', style: TextStyle(fontSize: 12)),
                                          ),
                                          const Spacer(),
                                          ElevatedButton.icon(
                                            onPressed: () => _showStatusChangeDialog(item),
                                            icon: const Icon(Icons.edit_note_rounded, size: 16),
                                            label: const Text('Moderate Status', style: TextStyle(fontSize: 12)),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: customColors.navyPrimary,
                                              foregroundColor: Colors.white,
                                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
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
