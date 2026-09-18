import 'package:flutter/material.dart';
import '../../../core/core.dart';
import '../data/auth_api.dart';

/// Standardized OtpScreen adhering to Section 19 of UniTrace Master Design:
/// Rules:
/// - Step indicator (Step 02 Verification)
/// - Clean OTP input box with clear focus state
/// - Informative university email confirmation
/// - Responsive card container
class OtpScreen extends StatefulWidget {
  final String email;
  final String? token;
  final int otpTtlMinutes;

  const OtpScreen({
    super.key,
    required this.email,
    this.token,
    this.otpTtlMinutes = 10,
  });

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final _otpController = TextEditingController();
  final _authApi = AuthApi();
  bool _isLoading = false;
  String? _verificationToken;

  @override
  void initState() {
    super.initState();
    _resolveToken();
  }

  Future<void> _resolveToken() async {
    if (widget.token != null && widget.token!.isNotEmpty) {
      _verificationToken = widget.token;
    } else {
      _verificationToken = await TokenStorage.getPendingVerificationToken();
    }
  }

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _handleVerify() async {
    final otp = _otpController.text.trim();
    if (otp.length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter the OTP verification code')),
      );
      return;
    }

    final token = _verificationToken ?? await TokenStorage.getPendingVerificationToken() ?? '';
    if (token.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Verification token missing. Please register again.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await _authApi.verifyRegistration(
        uniEmail: widget.email,
        token: token,
        otp: otp,
      );

      if (!mounted) return;

      final message = response['message']?.toString() ?? 'Registration successful!';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$message Please login with your credentials.'),
          backgroundColor: AppColors.success,
        ),
      );

      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    } catch (e) {
      if (!mounted) return;
      final msg = e.toString().split('\n').first;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Verification failed: $msg'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final customColors = context.appColors;

    return Scaffold(
      backgroundColor: customColors.background,
      appBar: AppBar(
        title: const Text('Account Verification'),
        backgroundColor: customColors.surface,
        elevation: 0,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xl,
              vertical: AppSpacing.md,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Step Indicator: Step 02 active
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                    decoration: BoxDecoration(
                      color: customColors.surface,
                      borderRadius: BorderRadius.circular(AppRadius.input),
                      border: Border.all(color: customColors.border),
                    ),
                    child: Row(
                      children: [
                        _buildStepItem('01', 'Account', false, true, customColors),
                        Expanded(
                          child: Container(
                            height: 1,
                            color: customColors.success,
                            margin: const EdgeInsets.symmetric(horizontal: 8),
                          ),
                        ),
                        _buildStepItem('02', 'Verification', true, false, customColors),
                        Expanded(
                          child: Container(
                            height: 1,
                            color: customColors.divider,
                            margin: const EdgeInsets.symmetric(horizontal: 8),
                          ),
                        ),
                        _buildStepItem('03', 'Ready', false, false, customColors),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Verification Card
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    decoration: BoxDecoration(
                      color: customColors.surface,
                      borderRadius: BorderRadius.circular(AppRadius.card),
                      border: Border.all(color: customColors.border),
                      boxShadow: AppShadows.card,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Center(
                          child: Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              color: customColors.primaryLight,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.mark_email_read_outlined,
                              color: customColors.primary,
                              size: 26,
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          'Verification Code',
                          textAlign: TextAlign.center,
                          style: AppTypography.sectionTitle.copyWith(fontSize: 20),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Enter the OTP code sent to\n${widget.email}',
                          textAlign: TextAlign.center,
                          style: AppTypography.bodySmall.copyWith(
                            color: customColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),

                        // OTP Input Box (48-52px height)
                        AppTextField(
                          label: 'One-Time Passcode',
                          hintText: 'e.g. 123456',
                          controller: _otpController,
                          keyboardType: TextInputType.number,
                          prefixIcon: const Icon(Icons.password_outlined, size: 20),
                          helperText: 'Valid for ${widget.otpTtlMinutes} minutes.',
                        ),
                        const SizedBox(height: AppSpacing.xl),

                        // Verify Button
                        AppButton(
                          text: 'Verify & Activate Account',
                          isLoading: _isLoading,
                          onPressed: _handleVerify,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  Center(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'Change email address',
                        style: AppTypography.secondary.copyWith(color: customColors.primary),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStepItem(
    String num,
    String title,
    bool isActive,
    bool isCompleted,
    AppCustomColors colors,
  ) {
    Color bg = isCompleted
        ? colors.success
        : (isActive ? colors.primary : colors.background);
    Color border = isCompleted
        ? colors.success
        : (isActive ? colors.primary : colors.border);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: bg,
            shape: BoxShape.circle,
            border: Border.all(color: border),
          ),
          child: Center(
            child: isCompleted
                ? const Icon(Icons.check, size: 12, color: Colors.white)
                : Text(
                    num,
                    style: TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: isActive ? Colors.white : colors.textSecondary,
                    ),
                  ),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          title,
          style: TextStyle(
            fontFamily: AppTypography.fontFamily,
            fontSize: 11,
            fontWeight: isActive || isCompleted ? FontWeight.w600 : FontWeight.w500,
            color: isActive
                ? colors.primary
                : (isCompleted ? colors.success : colors.textSecondary),
          ),
        ),
      ],
    );
  }
}
