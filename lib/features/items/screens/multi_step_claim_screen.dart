import 'package:flutter/material.dart';
import '../../../core/core.dart';
import '../data/item_api.dart';
import '../models/match_result.dart';

/// USE CASE 4 & 8: Polished multi-step claim experience conforming to UniTrace Design System:
/// Rules:
/// - Trust banner at top with clear official mediation notice
/// - Vertical stepper with clean states and proper theme colors
/// - Standardized AppTextField inputs (48-52px comfortable height, persistent labels)
/// - Review card summarizing all details with privacy assurance
/// - Responsive container (max 600px)
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
          const SnackBar(
            content: Text('Please confirm that you genuinely believe this item is yours.'),
            backgroundColor: AppColors.error,
          ),
        );
        return false;
      }
      return true;
    }
    if (step == 1) {
      if (_studentIdController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please enter your University Student or Staff ID.'),
            backgroundColor: AppColors.error,
          ),
        );
        return false;
      }
      return true;
    }
    if (step == 2) {
      if (_lostLocationController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please specify where you remember losing this item.'),
            backgroundColor: AppColors.error,
          ),
        );
        return false;
      }
      return true;
    }
    if (step == 3) {
      if (_identifyingMarksController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please provide at least one identifying mark or characteristic.'),
            backgroundColor: AppColors.error,
          ),
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

      final customColors = context.appColors;

      // Show Confirmation Dialog
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.card)),
          backgroundColor: customColors.surface,
          title: Row(
            children: [
              Icon(Icons.check_circle, color: AppColors.success, size: 24),
              const SizedBox(width: AppSpacing.xs),
              Text(
                'Claim Submitted',
                style: AppTypography.cardTitle.copyWith(fontSize: 18),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Your claim has been securely submitted to the University Security & Lost-and-Found Office for review.',
                style: AppTypography.bodySmall.copyWith(color: customColors.textPrimary, height: 1.4),
              ),
              const SizedBox(height: AppSpacing.md),
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: customColors.background,
                  borderRadius: BorderRadius.circular(AppRadius.input),
                  border: Border.all(color: customColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        StatusChip(status: 'PENDING', fontSize: 11),
                        const Spacer(),
                        Text(
                          'Case Locked',
                          style: AppTypography.caption.copyWith(color: customColors.textSecondary),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Campus staff will cross-reference your identifying characteristics against confidential records. You will receive an update once verified.',
                      style: AppTypography.caption.copyWith(color: customColors.textSecondary, height: 1.4),
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
                backgroundColor: customColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.button)),
              ),
              child: const Text('Return to Item Details'),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to submit claim: ${e.toString().split('\n').first}'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final customColors = context.appColors;

    return Scaffold(
      backgroundColor: customColors.background,
      appBar: AppBar(
        title: Text(
          'Submit Ownership Claim',
          style: AppTypography.cardTitle.copyWith(fontSize: 18),
        ),
        backgroundColor: customColors.surface,
        elevation: 0,
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: AppSpacing.maxContentWidth),
            child: Column(
              children: [
                // Trust Banner
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withOpacity(0.12),
                    border: Border(
                      bottom: BorderSide(color: AppColors.warning.withOpacity(0.3)),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.shield_outlined, size: 18, color: AppColors.warning),
                      const SizedBox(width: AppSpacing.xs),
                      Expanded(
                        child: Text(
                          'Your claim will be verified by campus security. Claims must be made in good faith under university code of conduct.',
                          style: TextStyle(
                            fontFamily: AppTypography.fontFamily,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.warning,
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
                        padding: const EdgeInsets.only(top: AppSpacing.md),
                        child: Row(
                          children: [
                            ElevatedButton(
                              onPressed: _isSubmitting ? null : details.onStepContinue,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: customColors.primary,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(AppRadius.button),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.lg,
                                  vertical: AppSpacing.sm,
                                ),
                              ),
                              child: _isSubmitting
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : Text(
                                      isLast ? 'Submit Claim' : 'Continue',
                                      style: AppTypography.button,
                                    ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            if (_currentStep > 0)
                              OutlinedButton(
                                onPressed: _isSubmitting ? null : details.onStepCancel,
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: customColors.textSecondary,
                                  side: BorderSide(color: customColors.border),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(AppRadius.button),
                                  ),
                                ),
                                child: const Text('Back'),
                              )
                            else
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                style: TextButton.styleFrom(
                                  foregroundColor: customColors.textSecondary,
                                ),
                                child: const Text('Cancel'),
                              ),
                          ],
                        ),
                      );
                    },
                    steps: [
                      // Step 1: Confirmation
                      Step(
                        title: Text(
                          'Intent Confirmation',
                          style: AppTypography.cardTitle.copyWith(fontSize: 15),
                        ),
                        subtitle: Text(
                          'Claiming: "${widget.itemTitle}"',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.caption.copyWith(color: customColors.textSecondary),
                        ),
                        isActive: _currentStep >= 0,
                        state: _currentStep > 0 ? StepState.complete : StepState.indexed,
                        content: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(AppSpacing.md),
                              decoration: BoxDecoration(
                                color: customColors.surface,
                                borderRadius: BorderRadius.circular(AppRadius.card),
                                border: Border.all(color: customColors.border),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'TARGET ITEM REPORT',
                                    style: TextStyle(
                                      fontFamily: AppTypography.fontFamily,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.8,
                                      color: customColors.primary,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    widget.itemTitle,
                                    style: AppTypography.cardTitle.copyWith(fontSize: 16),
                                  ),
                                  if (widget.itemLocation != null &&
                                      widget.itemLocation!.isNotEmpty) ...[
                                    const SizedBox(height: 2),
                                    Text(
                                      'Found Location: ${widget.itemLocation}',
                                      style: AppTypography.caption.copyWith(
                                        color: customColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            CheckboxListTile(
                              value: _confirmOwnership,
                              activeColor: customColors.primary,
                              title: Text(
                                'I declare that I am the rightful owner of this item and understand that filing fraudulent claims violates campus policies.',
                                style: AppTypography.bodySmall.copyWith(
                                  color: customColors.textPrimary,
                                  height: 1.35,
                                ),
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
                        title: Text(
                          'University Identity',
                          style: AppTypography.cardTitle.copyWith(fontSize: 15),
                        ),
                        isActive: _currentStep >= 1,
                        state: _currentStep > 1 ? StepState.complete : StepState.indexed,
                        content: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Provide your Student or Staff Registration ID so that the security desk can confirm authorization.',
                              style: AppTypography.caption.copyWith(
                                color: customColors.textSecondary,
                                height: 1.4,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            AppTextField(
                              label: 'Student / Staff ID *',
                              hintText: 'e.g. 20241092',
                              controller: _studentIdController,
                              prefixIcon: const Icon(Icons.badge_outlined, size: 20),
                            ),
                          ],
                        ),
                      ),

                      // Step 3: Where & When lost
                      Step(
                        title: Text(
                          'Loss Location & Time',
                          style: AppTypography.cardTitle.copyWith(fontSize: 15),
                        ),
                        isActive: _currentStep >= 2,
                        state: _currentStep > 2 ? StepState.complete : StepState.indexed,
                        content: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppTextField(
                              label: 'Where did you lose this item? *',
                              hintText: 'e.g. Main Library 2nd floor, Science Hall Lab 4',
                              controller: _lostLocationController,
                              prefixIcon: const Icon(Icons.pin_drop_outlined, size: 20),
                            ),
                            const SizedBox(height: AppSpacing.md),
                            AppTextField(
                              label: 'Approximate Date / Time (Optional)',
                              hintText: 'e.g. Yesterday around 3:30 PM',
                              controller: _lostDateController,
                              prefixIcon: const Icon(Icons.calendar_today_outlined, size: 20),
                            ),
                          ],
                        ),
                      ),

                      // Step 4: Identifying Marks
                      Step(
                        title: Text(
                          'Identifying Marks',
                          style: AppTypography.cardTitle.copyWith(fontSize: 15),
                        ),
                        isActive: _currentStep >= 3,
                        state: _currentStep > 3 ? StepState.complete : StepState.indexed,
                        content: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Provide non-public details: scratches, unique stickers, keychains, phone lockscreen, engraved initials, or serial marks.',
                              style: AppTypography.caption.copyWith(
                                color: customColors.textSecondary,
                                height: 1.4,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            AppTextField(
                              label: 'Unique Marks & Characteristics *',
                              hintText:
                                  'e.g. Small yellow smiley sticker on bottom right, initials engraved on buckle...',
                              controller: _identifyingMarksController,
                              maxLines: 3,
                              alignLabelWithHint: true,
                              prefixIcon: const Icon(Icons.fingerprint_rounded, size: 20),
                            ),
                          ],
                        ),
                      ),

                      // Step 5: Internal Contents & Proof
                      Step(
                        title: Text(
                          'Contents & Secret Verification',
                          style: AppTypography.cardTitle.copyWith(fontSize: 15),
                        ),
                        isActive: _currentStep >= 4,
                        state: _currentStep > 4 ? StepState.complete : StepState.indexed,
                        content: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppTextField(
                              label: 'Internal Contents (if bag, wallet, folder)',
                              hintText:
                                  'e.g. Contains student ID card, blue Parker pen, calculus notes...',
                              controller: _internalContentsController,
                              maxLines: 2,
                              alignLabelWithHint: true,
                              prefixIcon: const Icon(Icons.inventory_2_outlined, size: 20),
                            ),
                            const SizedBox(height: AppSpacing.md),
                            AppTextField(
                              label: 'Additional Instructions for Security Desk',
                              hintText:
                                  'e.g. Can unlock device in presence of officer using PIN or fingerprint',
                              controller: _additionalProofController,
                              maxLines: 2,
                              alignLabelWithHint: true,
                              prefixIcon: const Icon(Icons.security_outlined, size: 20),
                            ),
                          ],
                        ),
                      ),

                      // Step 6: Review & Submit
                      Step(
                        title: Text(
                          'Review & Submit',
                          style: AppTypography.cardTitle.copyWith(fontSize: 15),
                        ),
                        isActive: _currentStep >= 5,
                        state: StepState.indexed,
                        content: Container(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          decoration: BoxDecoration(
                            color: customColors.surface,
                            borderRadius: BorderRadius.circular(AppRadius.card),
                            border: Border.all(color: customColors.border),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'CLAIM SUMMARY',
                                style: TextStyle(
                                  fontFamily: AppTypography.fontFamily,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.8,
                                  color: customColors.primary,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              _buildSummaryRow(
                                  'Item', widget.itemTitle, customColors),
                              _buildSummaryRow(
                                  'Student ID', _studentIdController.text, customColors),
                              _buildSummaryRow(
                                  'Loss Location', _lostLocationController.text, customColors),
                              if (_lostDateController.text.isNotEmpty)
                                _buildSummaryRow(
                                    'Loss Time', _lostDateController.text, customColors),
                              _buildSummaryRow(
                                  'Marks', _identifyingMarksController.text, customColors),
                              if (_internalContentsController.text.isNotEmpty)
                                _buildSummaryRow('Contents',
                                    _internalContentsController.text, customColors),
                              Divider(height: AppSpacing.lg, color: customColors.divider),
                              Text(
                                '• Submitting this claim transitions the case to PENDING VERIFICATION.\n• Security staff will inspect confidential records privately.\n• Your verification data is never exposed publicly or to other students.',
                                style: AppTypography.caption.copyWith(
                                  color: customColors.textSecondary,
                                  height: 1.45,
                                ),
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
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, AppCustomColors colors) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 95,
            child: Text(
              label,
              style: TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: colors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: colors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
