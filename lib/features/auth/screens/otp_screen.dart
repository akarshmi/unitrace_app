import 'package:flutter/material.dart';
import '../../../core/core.dart';
import '../data/auth_api.dart';

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
        SnackBar(content: Text('$message Please login with your credentials.')),
      );

      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    } catch (e) {
      if (!mounted) return;
      final msg = e.toString().split('\n').first;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Verification failed: $msg')),
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
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        title: const Text('Verify Account'),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: customColors.navyPrimary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    Icons.mark_email_read_outlined,
                    color: customColors.navyPrimary,
                    size: 34,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Enter Verification Code',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: customColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'We sent a temporary verification token OTP to:\n${widget.email}',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: customColors.textMuted,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Valid for ${widget.otpTtlMinutes} minutes',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: customColors.accentAmber,
                ),
              ),
              const SizedBox(height: 32),

              // OTP Input
              TextFormField(
                controller: _otpController,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  letterSpacing: 6,
                  fontWeight: FontWeight.bold,
                  color: customColors.textPrimary,
                ),
                decoration: InputDecoration(
                  hintText: '• • • • • •',
                  hintStyle: TextStyle(
                    fontSize: 24,
                    letterSpacing: 6,
                    color: customColors.textMuted,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: customColors.borderDivider),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: customColors.navyPrimary, width: 2),
                  ),
                  filled: true,
                  fillColor: colorScheme.surface,
                ),
              ),
              const SizedBox(height: 28),

              // Verify Button
              AppButton(
                text: 'Verify & Activate Account',
                isLoading: _isLoading,
                onPressed: _handleVerify,
              ),
              const SizedBox(height: 16),

              TextButton(
                onPressed: () => Navigator.pushNamedAndRemoveUntil(context, '/login', (r) => false),
                child: Text(
                  'Back to Login',
                  style: TextStyle(color: customColors.navyPrimary, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
