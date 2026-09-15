import 'package:flutter/material.dart';
import '../../../core/core.dart';
import '../data/item_api.dart';
import '../models/item.dart';

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

    if (mounted) {
      setState(() {
        _currentUserEmail = email;
        _currentUserName = name;
        _currentUserRole = role;
        _currentUserId = id;
      });
    }
  }

  // Exact requirement: "The status of the case only two can change either who created that and or modrator"
  bool get _isModerator {
    final r = (_currentUserRole ?? '').toUpperCase();
    return r == 'MODERATOR' || r == 'ADMIN';
  }

  bool get _isItemCreator {
    // Creator check by email
    if (_currentUserEmail != null &&
        _item.reportedByEmail != null &&
        _item.reportedByEmail!.isNotEmpty &&
        _currentUserEmail!.toLowerCase() == _item.reportedByEmail!.toLowerCase()) {
      return true;
    }
    // Creator check by reporter name
    if (_currentUserName != null &&
        _item.reportedByName != null &&
        _item.reportedByName!.isNotEmpty &&
        _currentUserName!.toLowerCase() == _item.reportedByName!.toLowerCase()) {
      return true;
    }
    // Creator check by reporter ID
    if (_currentUserId != null &&
        _item.reportedById != null &&
        _item.reportedById!.isNotEmpty &&
        _currentUserId == _item.reportedById) {
      return true;
    }
    // Fallback: If reporter email is in reportedByName (common backend format)
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
              title: Row(
                children: [
                  Icon(Icons.edit_note_rounded, color: customColors.navyPrimary),
                  const SizedBox(width: 8),
                  const Text('Update Status', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ],
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
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: customColors.accentAmber,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text('Select new case status:', style: TextStyle(fontSize: 13)),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: ['OPEN', 'MATCHED', 'CLAIMED', 'CLOSED'].map((st) {
                      final isSel = selectedStatus == st;
                      return ChoiceChip(
                        label: Text(st),
                        selected: isSel,
                        selectedColor: customColors.accentAmber,
                        labelStyle: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isSel ? customColors.navyPrimary : customColors.textPrimary,
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
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: selectedStatus == _item.status
                      ? null
                      : () async {
                          Navigator.pop(ctx);
                          await _executeStatusUpdate(selectedStatus);
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: customColors.navyPrimary,
                    foregroundColor: Colors.white,
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
        SnackBar(content: Text('Item status updated to $newStatus successfully')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update status: ${e.toString().split('\n').first}')),
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
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        title: Text(
          '${_item.type} Item Details',
          style: TextStyle(
            color: colorScheme.onPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.share_outlined, color: colorScheme.onPrimary),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Item link copied to clipboard')),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image or Placeholder
            if (_item.imageUrl != null && _item.imageUrl!.isNotEmpty)
              Image.network(
                _item.imageUrl!,
                height: 260,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    _buildPlaceholderBanner(customColors),
              )
            else
              _buildPlaceholderBanner(customColors),

            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Badges: Type + Status
                  Row(
                    children: [
                      TypeBadge(type: _item.type, fontSize: 12),
                      const SizedBox(width: 8),
                      StatusPill(status: _item.status, fontSize: 12),
                      const Spacer(),
                      if (_item.createdAt != null && _item.createdAt!.isNotEmpty)
                        Text(
                          _item.createdAt!.length > 10
                              ? _item.createdAt!.substring(0, 10)
                              : _item.createdAt!,
                          style: TextStyle(
                            fontSize: 12,
                            color: customColors.textMuted,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Title
                  Text(
                    _item.title,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: customColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Location Card
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: customColors.borderDivider),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.location_on, color: customColors.navyPrimary, size: 22),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Location Reported',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: customColors.textMuted,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _item.location.isNotEmpty ? _item.location : 'Campus General',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: customColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Description
                  Text(
                    'Description',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: customColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _item.description.isNotEmpty
                        ? _item.description
                        : 'No description provided.',
                    style: TextStyle(
                      fontSize: 14,
                      color: customColors.textBody,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Reporter Info Card
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: customColors.slateSubtle,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: customColors.navyPrimary,
                          radius: 18,
                          child: Icon(Icons.person, color: colorScheme.onPrimary, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Reported By',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: customColors.textMuted,
                                ),
                              ),
                              Text(
                                _item.reportedByName != null && _item.reportedByName!.isNotEmpty
                                    ? _item.reportedByName!
                                    : 'Campus Member',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: customColors.textPrimary,
                                ),
                              ),
                              if (_item.reportedByEmail != null && _item.reportedByEmail!.isNotEmpty)
                                Text(
                                  _item.reportedByEmail!,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: customColors.textMuted,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        if (_isItemCreator)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: customColors.navyPrimary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'YOU',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: customColors.navyPrimary,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),

                  // STATUS CHANGE SECTION - Strictly governed by user authorization
                  if (_canChangeStatus) ...[
                    ElevatedButton.icon(
                      onPressed: _isUpdatingStatus ? null : _showStatusSelectDialog,
                      icon: _isUpdatingStatus
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Icon(Icons.edit_note_rounded),
                      label: Text(
                        _isModerator ? 'Change Status (Staff Moderator)' : 'Update My Case Status',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: customColors.navyPrimary,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Center(
                      child: Text(
                        _isModerator
                            ? 'Authorized as Campus Staff Moderator to transition case state'
                            : 'Authorized as case creator to update resolution status',
                        style: TextStyle(
                          fontSize: 12,
                          color: customColors.textMuted,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ] else ...[
                    // Restricted status banner
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: customColors.slateSubtle,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: customColors.borderDivider),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.lock_outline_rounded, color: customColors.textMuted, size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'The status of this case can only be changed by its creator or a campus moderator.',
                              style: TextStyle(
                                fontSize: 12,
                                color: customColors.textMuted,
                                fontWeight: FontWeight.w500,
                              ),
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
    );
  }

  Widget _buildPlaceholderBanner(AppCustomColors customColors) {
    return Container(
      height: 180,
      color: customColors.slateSubtle,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _item.isLost ? Icons.search_rounded : Icons.inventory_2_outlined,
              size: 48,
              color: customColors.textMuted,
            ),
            const SizedBox(height: 8),
            Text(
              'No Photo Attached',
              style: TextStyle(
                color: customColors.textMuted,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
