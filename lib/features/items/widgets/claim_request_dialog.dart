import 'package:flutter/material.dart';
import '../../../core/core.dart';
import '../data/item_api.dart';

class ClaimRequestDialog extends StatefulWidget {
  final String itemId;
  final String itemTitle;
  final String itemType;

  const ClaimRequestDialog({
    super.key,
    required this.itemId,
    required this.itemTitle,
    required this.itemType,
  });

  @override
  State<ClaimRequestDialog> createState() => _ClaimRequestDialogState();
}

class _ClaimRequestDialogState extends State<ClaimRequestDialog> {
  final _formKey = GlobalKey<FormState>();
  final _proofController = TextEditingController();
  final _studentIdController = TextEditingController();
  final _itemApi = ItemApi();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _proofController.dispose();
    _studentIdController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);

    try {
      final claim = await _itemApi.submitClaim(
        itemId: widget.itemId,
        itemTitle: widget.itemTitle,
        proofDescription: _proofController.text.trim(),
        studentId: _studentIdController.text.trim().isNotEmpty ? _studentIdController.text.trim() : null,
      );

      if (!mounted) return;
      Navigator.pop(context, claim);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to submit claim: ${e.toString().split('\n').first}')),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final customColors = context.appColors;

    return AlertDialog(
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: customColors.navyPrimary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.verified_user_outlined, color: customColors.accentAmber, size: 20),
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'Claim This Item',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: customColors.slateSubtle,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.inventory_2_outlined, size: 18, color: customColors.navyPrimary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Case: "${widget.itemTitle}"',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: customColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'Provide proof that this item belongs to you (e.g., distinguishing stickers, lock screen photo, serial number, or exact contents):',
                style: TextStyle(fontSize: 13, color: customColors.textMuted),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _proofController,
                maxLines: 4,
                style: TextStyle(color: customColors.textPrimary),
                decoration: InputDecoration(
                  hintText: 'Detailed ownership proof or identifying marks...',
                  hintStyle: TextStyle(color: customColors.textMuted, fontSize: 13),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: customColors.borderDivider),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: customColors.navyPrimary, width: 1.5),
                  ),
                ),
                validator: (val) {
                  if (val == null || val.trim().length < 5) {
                    return 'Please provide at least 5 characters of proof';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _studentIdController,
                style: TextStyle(color: customColors.textPrimary),
                decoration: InputDecoration(
                  labelText: 'Student / Staff ID (Optional)',
                  labelStyle: TextStyle(color: customColors.textMuted, fontSize: 13),
                  hintText: 'e.g. 20240981',
                  hintStyle: TextStyle(color: customColors.textMuted, fontSize: 13),
                  filled: true,
                  fillColor: Colors.white,
                  prefixIcon: Icon(Icons.badge_outlined, color: customColors.textMuted, size: 20),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: customColors.borderDivider),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isSubmitting ? null : _submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: customColors.navyPrimary,
            foregroundColor: Colors.white,
          ),
          child: _isSubmitting
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : const Text('Submit Claim Request'),
        ),
      ],
    );
  }
}
