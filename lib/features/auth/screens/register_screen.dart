import 'package:flutter/material.dart';
import '../../../core/core.dart';
import '../data/auth_api.dart';
import 'otp_screen.dart';

/// Standardized RegisterScreen adhering to Section 19 of UniTrace Master Design:
/// Rules:
/// - Step indicator: 01 Account -> 02 Verification -> 03 Complete
/// - Clean inputs with persistent top labels (AppTextField)
/// - Responsive card container (max 480px on web)
/// - Consistent typography and palette
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _uniEmailController = TextEditingController();
  final _personalEmailController = TextEditingController();
  final _regNumberController = TextEditingController();
  final _departmentController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authApi = AuthApi();

  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _uniEmailController.dispose();
    _personalEmailController.dispose();
    _regNumberController.dispose();
    _departmentController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final regNum = int.parse(_regNumberController.text.trim());
      final uniEmail = _uniEmailController.text.trim();

      final response = await _authApi.registerInitiation(
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        uniEmail: uniEmail,
        personalEmail: _personalEmailController.text.trim(),
        registrationNumber: regNum,
        department: _departmentController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        password: _passwordController.text,
      );

      if (!mounted) return;

      final token = response['token']?.toString() ?? '';
      final ttl = response['otpTtlMinutes'] is num
          ? (response['otpTtlMinutes'] as num).toInt()
          : 10;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => OtpScreen(
            email: uniEmail,
            token: token,
            otpTtlMinutes: ttl,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      final msg = e.toString().split('\n').first;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Registration initiation failed: $msg'),
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
        title: const Text('Create Account'),
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
              constraints: const BoxConstraints(maxWidth: 480),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Step Indicator: 01 Account -> 02 Verification -> 03 Complete
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
                          _buildStepItem('01', 'Account', true, customColors),
                          Expanded(
                            child: Container(
                              height: 1,
                              color: customColors.divider,
                              margin: const EdgeInsets.symmetric(horizontal: 8),
                            ),
                          ),
                          _buildStepItem('02', 'Verification', false, customColors),
                          Expanded(
                            child: Container(
                              height: 1,
                              color: customColors.divider,
                              margin: const EdgeInsets.symmetric(horizontal: 8),
                            ),
                          ),
                          _buildStepItem('03', 'Ready', false, customColors),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // Main Form Card
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
                          Text(
                            'Student Information',
                            style: AppTypography.sectionTitle.copyWith(fontSize: 20),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Two-step verified university account creation',
                            style: AppTypography.caption.copyWith(color: customColors.textSecondary),
                          ),
                          const SizedBox(height: AppSpacing.lg),

                          // Name Row
                          Row(
                            children: [
                              Expanded(
                                child: AppTextField(
                                  label: 'First Name *',
                                  hintText: 'Jane',
                                  controller: _firstNameController,
                                  validator: (v) =>
                                      (v == null || v.trim().isEmpty) ? 'Required' : null,
                                ),
                              ),
                              const SizedBox(width: AppSpacing.md),
                              Expanded(
                                child: AppTextField(
                                  label: 'Last Name',
                                  hintText: 'Doe',
                                  controller: _lastNameController,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.md),

                          // University Email
                          AppTextField(
                            label: 'University Email *',
                            hintText: 'student@university.edu',
                            controller: _uniEmailController,
                            keyboardType: TextInputType.emailAddress,
                            prefixIcon: const Icon(Icons.school_outlined, size: 20),
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) return 'University email is required';
                              if (!v.contains('@')) return 'Enter a valid email';
                              return null;
                            },
                          ),
                          const SizedBox(height: AppSpacing.md),

                          // Registration Number & Department
                          Row(
                            children: [
                              Expanded(
                                child: AppTextField(
                                  label: 'Reg Number *',
                                  hintText: '102450',
                                  controller: _regNumberController,
                                  keyboardType: TextInputType.number,
                                  validator: (v) {
                                    if (v == null || v.trim().isEmpty) return 'Required';
                                    if (int.tryParse(v.trim()) == null) return 'Must be digits';
                                    return null;
                                  },
                                ),
                              ),
                              const SizedBox(width: AppSpacing.md),
                              Expanded(
                                child: AppTextField(
                                  label: 'Department',
                                  hintText: 'Computer Science',
                                  controller: _departmentController,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.md),

                          // Phone Number
                          AppTextField(
                            label: 'Phone Number (10 digits) *',
                            hintText: '1234567890',
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            prefixIcon: const Icon(Icons.phone_outlined, size: 20),
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) return 'Phone number required';
                              final cleaned = v.trim().replaceAll(RegExp(r'[^0-9]'), '');
                              if (cleaned.length != 10) return 'Must be exactly 10 digits';
                              return null;
                            },
                          ),
                          const SizedBox(height: AppSpacing.md),

                          // Password
                          AppTextField(
                            label: 'Password (8+ chars) *',
                            hintText: 'Create a secure password',
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            prefixIcon: const Icon(Icons.lock_outline, size: 20),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                size: 20,
                              ),
                              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                            ),
                            validator: (v) {
                              if (v == null || v.isEmpty) return 'Password required';
                              if (v.length < 8) return 'Password must be at least 8 characters';
                              if (!v.contains(RegExp(r'[A-Z]'))) return 'Must contain uppercase';
                              if (!v.contains(RegExp(r'[a-z]'))) return 'Must contain lowercase';
                              if (!v.contains(RegExp(r'[0-9]'))) return 'Must contain a number';
                              return null;
                            },
                          ),
                          const SizedBox(height: AppSpacing.xl),

                          // Continue Button
                          AppButton(
                            text: 'Continue to Verification',
                            isLoading: _isLoading,
                            onPressed: _handleRegister,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // Back to Login
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Already registered? ',
                          style: AppTypography.secondary.copyWith(color: customColors.textSecondary),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text(
                            'Sign in',
                            style: AppTypography.secondary.copyWith(
                              color: customColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
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
    AppCustomColors colors,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: isActive ? colors.primary : colors.background,
            shape: BoxShape.circle,
            border: Border.all(
              color: isActive ? colors.primary : colors.border,
            ),
          ),
          child: Center(
            child: Text(
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
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
            color: isActive ? colors.primary : colors.textSecondary,
          ),
        ),
      ],
    );
  }
}
