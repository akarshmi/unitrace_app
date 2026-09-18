import 'package:flutter/material.dart';
import '../../../core/core.dart';
import '../../settings/screens/settings_screen.dart';
import '../data/auth_api.dart';

/// Standardized LoginScreen adhering to Section 18 of UniTrace Master Design:
/// Rules:
/// - Calm, premium, trustworthy
/// - Clear typography: "Find it. Verify it. Get it back."
/// - 48-52px input fields with top labels (AppTextField)
/// - Generous whitespace, responsive container (max 480px on web)
/// - No unnecessary decorative cartoon clutter
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authApi = AuthApi();

  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final tokenResponse = await _authApi.login(
        uniEmail: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (!mounted) return;

      if (tokenResponse.accessToken.isNotEmpty) {
        if (tokenResponse.role == 'MODERATOR' ||
            tokenResponse.role == 'ADMIN' ||
            tokenResponse.role == 'SECURITY' ||
            tokenResponse.role == 'STAFF') {
          Navigator.pushReplacementNamed(context, '/moderator/home');
        } else {
          Navigator.pushReplacementNamed(context, '/home');
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Login failed: Invalid server response')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      final msg = e.toString().split('\n').first;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Login failed: $msg'),
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
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.settings_outlined, color: customColors.textSecondary),
            tooltip: 'Server Settings',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),
        ],
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
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Brand Icon
                    Center(
                      child: Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: customColors.primary,
                          borderRadius: BorderRadius.circular(AppRadius.input + 2),
                          boxShadow: AppShadows.button,
                        ),
                        child: const Icon(
                          Icons.shield_outlined,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // UniTrace Title
                    Text(
                      'UniTrace',
                      textAlign: TextAlign.center,
                      style: AppTypography.pageTitle.copyWith(
                        color: customColors.textPrimary,
                        fontSize: 26,
                      ),
                    ),
                    const SizedBox(height: 6),

                    // Brand Ethos Subtitle
                    Text(
                      'Find it. Verify it. Get it back.',
                      textAlign: TextAlign.center,
                      style: AppTypography.bodySmall.copyWith(
                        color: customColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxl),

                    // Form Card Container
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
                            'Sign In',
                            style: AppTypography.sectionTitle.copyWith(fontSize: 20),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Access your campus lost & found reports',
                            style: AppTypography.caption.copyWith(color: customColors.textSecondary),
                          ),
                          const SizedBox(height: AppSpacing.lg),

                          // University Email
                          AppTextField(
                            label: 'University Email',
                            hintText: 'name@university.edu',
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            prefixIcon: const Icon(Icons.email_outlined, size: 20),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter your university email';
                              }
                              if (!value.contains('@')) {
                                return 'Please enter a valid email address';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: AppSpacing.md),

                          // Password
                          AppTextField(
                            label: 'Password',
                            hintText: 'Enter your password',
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
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your password';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: AppSpacing.lg),

                          // Sign In Button
                          AppButton(
                            text: 'Sign In',
                            isLoading: _isLoading,
                            onPressed: _handleLogin,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // Registration Link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Don't have an account? ",
                          style: AppTypography.secondary.copyWith(color: customColors.textSecondary),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/register');
                          },
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text(
                            'Create account',
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
}
