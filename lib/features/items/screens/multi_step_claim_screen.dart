import 'package:flutter/material.dart';
import '../../../core/core.dart';
import '../data/item_api.dart';
import '../models/match_result.dart';

/// USE CASE 4 & 8: Polished multi-step claim experience
/// Steps:
/// 1. Confirmation & Intent
/// 2. Student ID & Contact
/// 3. Where & When lost
/// 4. Identifying marks & unique characteristics
/// 5. Internal contents & private proof
/// 6. Review & Submission
class MultiStepClaimScreen extends StatefulWidget {
  final String itemId;
  final String itemTitle;
  final String? itemCategory;
  final String? itemLocation;

  const MultiStepClaimScreen({
    super.key,
    required this.itemId,
    required this.itemTitle,
    this.itemCategory,
    this.itemLocation,
  });

  @override
  State<MultiStepClaimScreen> createState() => _MultiStepClaimScreenState();
}

class _MultiStepClaimScreenState extends State<MultiStepClaimScreen> {
  final _itemApi = ItemApi();
  int _currentStep = 0;
  bool _isSubmitting = false;

  // Form Fields
  bool _confirmOwnership = false;
  final _studentIdController = TextEditingController();
  final _lostLocationController = TextEditingController();
  final _lostDateController = TextEditingController();
  final _identifyingMarksController = TextEditingController();
  final _internalContentsController = TextEditingController();
  final _additionalProofController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _loadUserStudentId();
  }

  Future<void> _loadUserStudentId() async {
    final regNo = await TokenStorage.getRegistrationNumber();
    if (regNo != null && regNo.isNotEmpty && mounted) {
      setState(() => _studentIdController.text = regNo);
    }
  }

  @override
  void dispose() {
    _studentIdController.dispose();
    _lostLocationController.dispose();
    _lostDateController.dispose();
    _identifyingMarksController.dispose();
    _internalContentsController.dispose();
    _additionalProofController.dispose();
    super.dispose();
  }

  bool _validateStep(int step) {
    if (step == 0) {
      if (!_confirmOwnership) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please confirm that you genuinely believe this item is yours.')),
        );
        return false;
      }
      return true;
    }
    if (step == 1) {
      if (_studentIdController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter your University Student or Staff ID.')),
        );
        return false;
      }
      return true;
    }
    if (step == 2) {
      if (_lostLocationController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please specify where you remember losing this item.')),
        );
        return false;
      }
      return true;
    }
    if (step == 3) {
      if (_identifyingMarksController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please provide at least one identifying mark or characteristic.')),
        );
        return false;
      }
      return true;
    }
    return true;
  }

  Future<void> _submitClaim() async {
    setState(() => _isSubmitting = true);

    try {
      final combinedProof = StringBuffer();
      combinedProof.writeln('Loss Location: ${_lostLocationController.text.trim()}');
      if (_lostDateController.text.trim().isNotEmpty) {
        combinedProof.writeln('Loss Date/Time: ${_lostDateController.text.trim()}');
      }
      combinedProof.writeln('Identifying Marks: ${_identifyingMarksController.text.trim()}');
      if (_internalContentsController.text.trim().isNotEmpty) {
        combinedProof.writeln('Internal Contents: ${_internalContentsController.text.trim()}');
      }
      if (_additionalProofController.text.trim().isNotEmpty) {
        combinedProof.writeln('Additional Proof: ${_additionalProofController.text.trim()}');
      }

      final claim = await _itemApi.submitClaim(
        itemId: widget.itemId,
        itemTitle: widget.itemTitle,
        proofDescription: combinedProof.toString().trim(),
        studentId: _studentIdController.text.trim(),
        lostLocation: _lostLocationController.text.trim(),
        lostDate: _lostDateController.text.trim(),
        identifyingMarks: _identifyingMarksController.text.trim(),
        internalContents: _internalContentsController.text.trim(),
      );

      if (!mounted) return;

      // Show Success Dialog as required by Section 8
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              const Icon(Icons.check_circle, color: Color(0xFF16A34A), size: 28),
              const SizedBox(width: 10),
              const Text('Claim Submitted', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Your claim has been sent to the Security/Lost & Found Office for verification.',
                style: TextStyle(fontSize: 14, height: 1.4),
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Status: PENDING VERIFICATION', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF1E40AF))),
                    const SizedBox(height: 4),
                    const Text(
                      'Security will compare your answers with confidential item notes. You will be notified once reviewed.',
                      style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.pop(context, claim);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0F172A),
                foregroundColor: Colors.white,
              ),
              child: const Text('Return to Item'),
            ),
          ],
        ),
      );
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
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text('Ownership Claim', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Important Notice Banner (Section 8 requirement)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              color: const Color(0xFFFEF3C7),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.shield_outlined, size: 20, color: Color(0xFF92400E)),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'Your claim will be reviewed by the university Security/Lost & Found Office. Do not submit a claim unless you genuinely believe this item belongs to you.',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF92400E),
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Stepper Content
            Expanded(
              child: Stepper(
                currentStep: _currentStep,
                type: StepperType.vertical,
                physics: const ClampingScrollPhysics(),
                elevation: 0,
                onStepContinue: () {
                  if (_validateStep(_currentStep)) {
                    if (_currentStep < 5) {
                      setState(() => _currentStep += 1);
                    } else {
                      _submitClaim();
                    }
                  }
                },
                onStepCancel: () {
                  if (_currentStep > 0) {
                    setState(() => _currentStep -= 1);
                  } else {
                    Navigator.pop(context);
                  }
                },
                controlsBuilder: (context, details) {
                  final isLast = _currentStep == 5;
                  return Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Row(
                      children: [
                        ElevatedButton(
                          onPressed: _isSubmitting ? null : details.onStepContinue,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isLast ? customColors.navyPrimary : customColors.accentAmber,
                            foregroundColor: isLast ? Colors.white : customColors.navyPrimary,
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          ),
                          child: _isSubmitting
                              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                              : Text(isLast ? 'Submit Claim' : 'Continue', style: const TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(width: 12),
                        if (_currentStep > 0)
                          OutlinedButton(
                            onPressed: _isSubmitting ? null : details.onStepCancel,
                            child: const Text('Back'),
                          )
                        else
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancel'),
                          ),
                      ],
                    ),
                  );
                },
                steps: [
                  // Step 1: Confirmation
                  Step(
                    title: const Text('Item Verification Intent', style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('Claiming: "${widget.itemTitle}"', maxLines: 1, overflow: TextOverflow.ellipsis),
                    isActive: _currentStep >= 0,
                    state: _currentStep > 0 ? StepState.complete : StepState.indexed,
                    content: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: customColors.slateSubtle,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: customColors.borderDivider),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Target Item ID: ${widget.itemId}', style: TextStyle(fontSize: 12, color: customColors.textMuted)),
                              const SizedBox(height: 4),
                              Text(widget.itemTitle, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                              if (widget.itemLocation != null && widget.itemLocation!.isNotEmpty) ...[
                                const SizedBox(height: 2),
                                Text('Found Location: ${widget.itemLocation}', style: TextStyle(fontSize: 12, color: customColors.textMuted)),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),
                        CheckboxListTile(
                          value: _confirmOwnership,
                          activeColor: customColors.navyPrimary,
                          title: const Text(
                            'I confirm that I am the genuine owner of this item and understand that filing false claims violates university honor codes.',
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                          ),
                          controlAffinity: ListTileControlAffinity.leading,
                          contentPadding: EdgeInsets.zero,
                          onChanged: (v) => setState(() => _confirmOwnership = v ?? false),
                        ),
                      ],
                    ),
                  ),

                  // Step 2: Student ID
                  Step(
                    title: const Text('University Identification', style: TextStyle(fontWeight: FontWeight.bold)),
                    isActive: _currentStep >= 1,
                    state: _currentStep > 1 ? StepState.complete : StepState.indexed,
                    content: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Enter your official Student ID or Staff Registration Number so the Security Office can verify your records before handover.',
                          style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _studentIdController,
                          decoration: InputDecoration(
                            labelText: 'Student / Staff Registration ID *',
                            hintText: 'e.g. 20241092',
                            prefixIcon: const Icon(Icons.badge_outlined),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            filled: true,
                            fillColor: customColors.slateSubtle,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Step 3: Where & When lost
                  Step(
                    title: const Text('Loss Location & Date', style: TextStyle(fontWeight: FontWeight.bold)),
                    isActive: _currentStep >= 2,
                    state: _currentStep > 2 ? StepState.complete : StepState.indexed,
                    content: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextFormField(
                          controller: _lostLocationController,
                          decoration: InputDecoration(
                            labelText: 'Where did you lose it? *',
                            hintText: 'e.g. Library 2nd floor, Science Hall Lab 4',
                            prefixIcon: const Icon(Icons.pin_drop_outlined),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            filled: true,
                            fillColor: customColors.slateSubtle,
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _lostDateController,
                          decoration: InputDecoration(
                            labelText: 'Approximate Date and Time (Optional)',
                            hintText: 'e.g. Yesterday around 3:30 PM',
                            prefixIcon: const Icon(Icons.calendar_today_outlined),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            filled: true,
                            fillColor: customColors.slateSubtle,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Step 4: Identifying Marks
                  Step(
                    title: const Text('Identifying Characteristics', style: TextStyle(fontWeight: FontWeight.bold)),
                    isActive: _currentStep >= 3,
                    state: _currentStep > 3 ? StepState.complete : StepState.indexed,
                    content: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Describe unique features not shown publicly: stickers, scratches, case color, engraved names, wallpapers, keychains, etc.',
                          style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _identifyingMarksController,
                          maxLines: 3,
                          decoration: InputDecoration(
                            labelText: 'Identifying Marks & Characteristics *',
                            hintText: 'e.g. Small yellow smiley sticker on bottom right, initials engraved...',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            filled: true,
                            fillColor: customColors.slateSubtle,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Step 5: Internal Contents & Proof
                  Step(
                    title: const Text('Internal Contents & Additional Proof', style: TextStyle(fontWeight: FontWeight.bold)),
                    isActive: _currentStep >= 4,
                    state: _currentStep > 4 ? StepState.complete : StepState.indexed,
                    content: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextFormField(
                          controller: _internalContentsController,
                          maxLines: 2,
                          decoration: InputDecoration(
                            labelText: 'Internal Contents (if bag, wallet, or notebook)',
                            hintText: 'e.g. Contains blue pen, bus pass, notes on Linear Algebra',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            filled: true,
                            fillColor: customColors.slateSubtle,
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _additionalProofController,
                          maxLines: 2,
                          decoration: InputDecoration(
                            labelText: 'Additional Notes for Security Office',
                            hintText: 'e.g. Can demonstrate unlocking with passcode or fingerprint',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            filled: true,
                            fillColor: customColors.slateSubtle,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Step 6: Review & Submit
                  Step(
                    title: const Text('Review & Final Submit', style: TextStyle(fontWeight: FontWeight.bold)),
                    isActive: _currentStep >= 5,
                    state: StepState.indexed,
                    content: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: customColors.slateSubtle,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: customColors.borderDivider),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('CLAIM SUMMARY', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.8, color: Color(0xFF64748B))),
                          const SizedBox(height: 8),
                          _buildSummaryRow('Item', widget.itemTitle),
                          _buildSummaryRow('Student ID', _studentIdController.text),
                          _buildSummaryRow('Loss Location', _lostLocationController.text),
                          if (_lostDateController.text.isNotEmpty)
                            _buildSummaryRow('Loss Time', _lostDateController.text),
                          _buildSummaryRow('Marks', _identifyingMarksController.text),
                          if (_internalContentsController.text.isNotEmpty)
                            _buildSummaryRow('Contents', _internalContentsController.text),
                          const Divider(height: 20),
                          const Text(
                            '• Submitting this claim will lock the item into PENDING VERIFICATION.\n• The Security Office acts as mediator and will review this information privately.\n• Your verification answers are never visible to the reporter.',
                            style: TextStyle(fontSize: 12, color: Color(0xFF1E293B), height: 1.4),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF64748B))),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF0F172A))),
          ),
        ],
      ),
    );
  }
}
