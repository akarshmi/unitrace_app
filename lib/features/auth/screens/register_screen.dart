import 'package:flutter/material.dart';
import '../../../core/core.dart';
import '../data/auth_api.dart';
import 'otp_screen.dart';

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

      // OAS 3.1: POST /api/uni/v1/auth/registration/initiation
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

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('OTP sent! Code expires in $ttl minutes.')),
      );

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
        SnackBar(content: Text('Registration initiation failed: $msg')),
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
        title: const Text('Student Registration'),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Join UniTrace',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: customColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Two-step verified university account creation',
                  style: TextStyle(
                    fontSize: 14,
                    color: customColors.textMuted,
                  ),
                ),
                const SizedBox(height: 24),

                // Name Row
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _firstNameController,
                        decoration: _inputDecoration('First Name *', Icons.person_outline, customColors, colorScheme),
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _lastNameController,
                        decoration: _inputDecoration('Last Name', Icons.person_outline, customColors, colorScheme),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // University Email
                TextFormField(
                  controller: _uniEmailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: _inputDecoration('University Email *', Icons.school_outlined, customColors, colorScheme, hint: 'student@university.edu'),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'University email is required';
                    if (!v.contains('@')) return 'Enter a valid email';
                    return null;
                  },
                ),
                const SizedBox(height: 14),

                // Personal Email
                TextFormField(
                  controller: _personalEmailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: _inputDecoration('Personal Email (Backup)', Icons.email_outlined, customColors, colorScheme),
                ),
                const SizedBox(height: 14),

                // Registration Number & Department
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _regNumberController,
                        keyboardType: TextInputType.number,
                        decoration: _inputDecoration('Reg Number *', Icons.badge_outlined, customColors, colorScheme, hint: 'e.g. 102450'),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return 'Required';
                          if (int.tryParse(v.trim()) == null) return 'Must be digits';
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _departmentController,
                        decoration: _inputDecoration('Department', Icons.account_balance_outlined, customColors, colorScheme, hint: 'e.g. CS'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Phone Number
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: _inputDecoration('Phone Number (10 digits) *', Icons.phone_outlined, customColors, colorScheme, hint: '1234567890'),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Phone number required';
                    final cleaned = v.trim().replaceAll(RegExp(r'[^0-9]'), '');
                    if (cleaned.length != 10) return 'Must be exactly 10 digits';
                    return null;
                  },
                ),
                const SizedBox(height: 14),

                // Password
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Password (8+ chars, Upper+Lower+Digit) *',
                    labelStyle: TextStyle(color: customColors.textMuted, fontSize: 13),
                    prefixIcon: Icon(Icons.lock_outline, color: customColors.textMuted),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                        color: customColors.textMuted,
                      ),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    filled: true,
                    fillColor: colorScheme.surface,
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Password required';
                    if (v.length < 8) return 'Password must be at least 8 characters';
                    if (!v.contains(RegExp(r'[A-Z]'))) return 'Must contain an uppercase letter';
                    if (!v.contains(RegExp(r'[a-z]'))) return 'Must contain a lowercase letter';
                    if (!v.contains(RegExp(r'[0-9]'))) return 'Must contain a number';
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Submit Button
                AppButton(
                  text: 'Initiate Registration (Get OTP)',
                  isLoading: _isLoading,
                  onPressed: _handleRegister,
                ),
                const SizedBox(height: 16),

                // Back to Login
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Already registered? ', style: TextStyle(color: customColors.textMuted)),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'Log in',
                        style: TextStyle(
                          color: customColors.navyPrimary,
                          fontWeight: FontWeight.bold,
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
    );
  }

  InputDecoration _inputDecoration(
    String label,
    IconData icon,
    AppCustomColors customColors,
    ColorScheme colorScheme, {
    String? hint,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: customColors.textMuted, fontSize: 13),
      hintText: hint,
      prefixIcon: Icon(icon, color: customColors.textMuted),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      filled: true,
      fillColor: colorScheme.surface,
      isDense: true,
    );
  }
}
