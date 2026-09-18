import 'package:flutter/material.dart';
import '../../../core/core.dart';
import '../../items/data/item_api.dart';
import '../../items/models/item.dart';
import '../../items/models/match_result.dart';
import '../../items/screens/create_item_screen.dart';
import '../../items/screens/item_detail_screen.dart';

class SecurityVerificationScreen extends StatefulWidget {
  const SecurityVerificationScreen({super.key});

  @override
  State<SecurityVerificationScreen> createState() => _SecurityVerificationScreenState();
}

class _SecurityVerificationScreenState extends State<SecurityVerificationScreen>
    with SingleTickerProviderStateMixin {
  final ItemApi _itemApi = ItemApi();
  late TabController _tabController;

  List<OwnershipClaimRequest> _claims = [];
  List<Item> _custodyItems = [];
  bool _isLoading = true;
  String? _errorMessage;
  String _filterClaimStatus = 'ALL';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final claims = await _itemApi.getClaims();
      final openFound = await _itemApi.getItems(type: 'FOUND', status: 'OPEN', size: 50);
      final matchedFound = await _itemApi.getItems(type: 'FOUND', status: 'MATCHED', size: 50);
      final claimedFound = await _itemApi.getItems(type: 'FOUND', status: 'CLAIMED', size: 50);

      if (!mounted) return;
      setState(() {
        _claims = claims;
        _custodyItems = [...openFound, ...matchedFound, ...claimedFound];
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString().split('\n').first;
      });
    }
  }

  // USE CASE 5: Security Review Claim with Compare View
  Future<void> _reviewClaim(OwnershipClaimRequest claim) async {
    // Attempt to locate corresponding item in custody
    Item? relatedItem;
    try {
      relatedItem = _custodyItems.firstWhere((i) => i.id == claim.itemId);
    } catch (_) {
      try {
        relatedItem = await _itemApi.getItemById(claim.itemId);
      } catch (_) {}
    }

    final notesController = TextEditingController();

    if (!mounted) return;
    await showDialog(
      context: context,
      builder: (ctx) {
        final customColors = ctx.appColors;

        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          title: Row(
            children: [
              const Icon(Icons.security, color: Color(0xFF0F172A), size: 22),
              const SizedBox(width: 8),
              const Expanded(
                child: Text('Security Claim Review', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Item Information Header
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('CLAIM ON ITEM #${claim.itemId}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
                        const SizedBox(height: 4),
                        Text(
                          relatedItem?.title ?? claim.itemTitle,
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                        ),
                        if (relatedItem != null) ...[
                          const SizedBox(height: 4),
                          Text('Found at: ${relatedItem.location}', style: const TextStyle(fontSize: 12, color: Color(0xFF475569))),
                          Text('Public Description: ${relatedItem.description}', style: const TextStyle(fontSize: 12, color: Color(0xFF475569))),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Claimant & Submitted Proof Section
                  const Text('CLAIMANT ANSWERS (CONFIDENTIAL)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                  const SizedBox(height: 8),
                  _buildProofTile('Claimant Name', claim.claimantName),
                  _buildProofTile('Claimant Email', claim.claimantEmail),
                  if (claim.studentId != null && claim.studentId!.isNotEmpty)
                    _buildProofTile('Student / Staff ID', claim.studentId!),
                  if (claim.lostLocation.isNotEmpty)
                    _buildProofTile('Stated Loss Location', claim.lostLocation),
                  if (claim.lostDate.isNotEmpty)
                    _buildProofTile('Stated Loss Date/Time', claim.lostDate),
                  if (claim.identifyingMarks.isNotEmpty)
                    _buildProofTile('Identifying Marks', claim.identifyingMarks),
                  if (claim.internalContents.isNotEmpty)
                    _buildProofTile('Internal Contents', claim.internalContents),
                  _buildProofTile('Ownership Proof', claim.proofDescription),
                  const SizedBox(height: 14),

                  TextField(
                    controller: notesController,
                    maxLines: 2,
                    decoration: InputDecoration(
                      labelText: 'Staff Reviewer Notes / Reason',
                      hintText: 'e.g. Serial numbers match, or insufficient proof provided',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Close'),
            ),
            OutlinedButton(
              onPressed: () async {
                Navigator.pop(ctx);
                await _itemApi.rejectClaim(
                  claimId: claim.id,
                  itemId: claim.itemId,
                  reason: notesController.text.trim().isNotEmpty
                      ? notesController.text.trim()
                      : 'Verification details do not match item records.',
                );
                _loadData();
              },
              style: OutlinedButton.styleFrom(foregroundColor: const Color(0xFFDC2626)),
              child: const Text('Reject Claim'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(ctx);
                await _itemApi.verifyClaim(
                  claimId: claim.id,
                  itemId: claim.itemId,
                  reviewerNotes: notesController.text.trim().isNotEmpty
                      ? notesController.text.trim()
                      : 'Student ID verified and identifying features corroborated.',
                );
                _loadData();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF16A34A),
                foregroundColor: Colors.white,
              ),
              child: const Text('Verify Claim'),
            ),
          ],
        );
      },
    );
  }

  // USE CASE 6: Security Complete Handover & Close Case
  Future<void> _completeHandover(OwnershipClaimRequest claim) async {
    final handoverNotesController = TextEditingController();
    bool idChecked = false;
    bool recipientSigned = false;

    await showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              title: Row(
                children: const [
                  Icon(Icons.how_to_reg, color: Color(0xFF0F172A), size: 22),
                  SizedBox(width: 8),
                  Text('Physical Item Handover', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Item: ${claim.itemTitle}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    const SizedBox(height: 4),
                    Text('Claimant: ${claim.claimantName} (${claim.studentId ?? "No Reg ID"})', style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                    const Divider(height: 20),
                    CheckboxListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      value: idChecked,
                      title: const Text('Physical Student ID card inspected and matches claim record', style: TextStyle(fontSize: 12)),
                      onChanged: (v) => setDialogState(() => idChecked = v ?? false),
                    ),
                    CheckboxListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      value: recipientSigned,
                      title: const Text('Recipient has checked item and confirmed custody receipt', style: TextStyle(fontSize: 12)),
                      onChanged: (v) => setDialogState(() => recipientSigned = v ?? false),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: handoverNotesController,
                      decoration: InputDecoration(
                        labelText: 'Handover Log Notes (Optional)',
                        hintText: 'e.g. Returned with charger and pouch',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      ),
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
                  onPressed: (!idChecked || !recipientSigned)
                      ? null
                      : () async {
                          Navigator.pop(ctx);
                          await _itemApi.recordHandover(
                            claimId: claim.id,
                            itemId: claim.itemId,
                            handoverNotes: handoverNotesController.text.trim(),
                          );
                          _loadData();
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F172A),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Confirm Handover & Close Case'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildProofTile(String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF64748B))),
          const SizedBox(height: 2),
          Text(value, style: const TextStyle(fontSize: 12, color: Color(0xFF0F172A), fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final customColors = context.appColors;
    final colorScheme = Theme.of(context).colorScheme;

    final filteredClaims = _filterClaimStatus == 'ALL'
        ? _claims
        : _claims.where((c) => c.status == _filterClaimStatus).toList();

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.shield_rounded, color: Color(0xFFF59E0B), size: 22),
            const SizedBox(width: 8),
            const Text(
              'Security & Moderation',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: customColors.accentAmber,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'STAFF',
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
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
            onPressed: _loadData,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: customColors.accentAmber,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: [
            Tab(text: 'Pending Claims (${_claims.where((c) => c.isPending).length})'),
            Tab(text: 'Custody Locker (${_custodyItems.length})'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab 1: Claims Workflow
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _errorMessage != null
                  ? Center(child: Text(_errorMessage!))
                  : Column(
                      children: [
                        // Filter row
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          color: customColors.slateSubtle,
                          child: Row(
                            children: [
                              const Text('Status:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                              const SizedBox(width: 8),
                              Wrap(
                                spacing: 6,
                                children: ['ALL', 'PENDING', 'VERIFIED', 'COMPLETED'].map((st) {
                                  final isSel = _filterClaimStatus == st;
                                  return ChoiceChip(
                                    label: Text(st, style: const TextStyle(fontSize: 11)),
                                    selected: isSel,
                                    selectedColor: customColors.accentAmber,
                                    onSelected: (val) {
                                      if (val) setState(() => _filterClaimStatus = st);
                                    },
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        ),

                        // Claims List
                        Expanded(
                          child: filteredClaims.isEmpty
                              ? const Center(
                                  child: Text('No claims found matching selected filter', style: TextStyle(color: Color(0xFF64748B))),
                                )
                              : ListView.builder(
                                  padding: const EdgeInsets.all(12),
                                  itemCount: filteredClaims.length,
                                  itemBuilder: (context, index) {
                                    final claim = filteredClaims[index];
                                    final isPending = claim.isPending;
                                    final isVerified = claim.isVerified;

                                    return Card(
                                      margin: const EdgeInsets.only(bottom: 10),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        side: BorderSide(color: customColors.borderDivider),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(12),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                StatusPill(status: claim.status, fontSize: 11),
                                                const SizedBox(width: 8),
                                                Text('Claim #${claim.id.substring(claim.id.length > 8 ? claim.id.length - 8 : 0)}', style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                                                const Spacer(),
                                                Text(
                                                  claim.createdAt.toIso8601String().substring(0, 10),
                                                  style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              claim.itemTitle.isNotEmpty ? claim.itemTitle : 'Item #${claim.itemId}',
                                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              'Claimant: ${claim.claimantName} (${claim.studentId ?? "ID Not Provided"})',
                                              style: const TextStyle(fontSize: 12, color: Color(0xFF1E293B)),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              'Proof summary: ${claim.proofDescription}',
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), fontStyle: FontStyle.italic),
                                            ),
                                            const Divider(height: 16),
                                            Row(
                                              children: [
                                                OutlinedButton(
                                                  onPressed: () => _reviewClaim(claim),
                                                  child: Text(isPending ? 'Review & Decide' : 'View Questionnaire'),
                                                ),
                                                const Spacer(),
                                                if (isVerified)
                                                  ElevatedButton.icon(
                                                    onPressed: () => _completeHandover(claim),
                                                    icon: const Icon(Icons.handshake, size: 16),
                                                    label: const Text('Handover Item'),
                                                    style: ElevatedButton.styleFrom(
                                                      backgroundColor: const Color(0xFF16A34A),
                                                      foregroundColor: Colors.white,
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

          // Tab 2: Custody Locker Inventory
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      color: customColors.navySurface,
                      child: Row(
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
                                if (res == true) _loadData();
                              },
                              icon: const Icon(Icons.add_box_outlined, size: 18),
                              label: const Text('Intake Found Item into Custody'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: customColors.accentAmber,
                                foregroundColor: customColors.navyPrimary,
                                textStyle: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: _custodyItems.length,
                        itemBuilder: (context, index) {
                          final item = _custodyItems[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                              side: BorderSide(color: customColors.borderDivider),
                            ),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: customColors.navyPrimary,
                                child: Text('L${(index % 12) + 1}', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                              ),
                              title: Text(item.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text('Location: ${item.location.isNotEmpty ? item.location : "Campus"}\nStatus: ${item.status}'),
                              trailing: StatusPill(status: item.status),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ItemDetailScreen(item: item),
                                  ),
                                ).then((_) => _loadData());
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
        ],
      ),
    );
  }
}
