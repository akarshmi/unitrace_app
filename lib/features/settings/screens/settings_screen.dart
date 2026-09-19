import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../../../core/core.dart';

/// Standardized SettingsScreen conforming to UniTrace Design System:
/// Rules:
/// - Responsive container (max 600px)
/// - Information card explaining backend host configuration
/// - Standardized AppTextField for backend host
/// - Quick preset action chips
/// - Status feedback banner with clear semantic colors
/// - Standard AppButton actions for testing and saving
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _urlController = TextEditingController();
  bool _isLoading = false;
  bool _isTesting = false;
  String? _testResult;
  bool _testSuccess = false;

  @override
  void initState() {
    super.initState();
    _loadCurrentSettings();
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _loadCurrentSettings() async {
    final url = await SettingsStorage.getBaseUrl();
    if (mounted) {
      setState(() {
        _urlController.text = url;
      });
    }
  }

  Future<void> _testConnection() async {
    final candidateUrl = _urlController.text.trim();
    if (candidateUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a server URL to test'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() {
      _isTesting = true;
      _testResult = null;
    });

    try {
      final dio = Dio(
        BaseOptions(
          connectTimeout: const Duration(seconds: 4),
          receiveTimeout: const Duration(seconds: 4),
        ),
      );

      final stopwatch = Stopwatch()..start();
      var cleanUrl = candidateUrl.endsWith('/')
          ? candidateUrl.substring(0, candidateUrl.length - 1)
          : candidateUrl;

      final response = await dio.get(
        '$cleanUrl/api/uni/v1/items',
        queryParameters: {'type': 'LOST', 'status': 'OPEN', 'size': 1},
      );
      stopwatch.stop();

      if (!mounted) return;
      setState(() {
        _testSuccess = true;
        _testResult =
            'Connection verified! Status ${response.statusCode} (${stopwatch.elapsedMilliseconds}ms)';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _testSuccess = false;
        _testResult = 'Connection failed: ${e.toString().split('\n').first}';
      });
    } finally {
      if (mounted) {
        setState(() => _isTesting = false);
      }
    }
  }

  Future<void> _saveSettings() async {
    final newUrl = _urlController.text.trim();
    if (newUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Server URL cannot be empty'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      await SettingsStorage.saveBaseUrl(newUrl);
      ApiClient().updateBaseUrl(newUrl);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Saved backend URL: $newUrl'),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving settings: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _resetToDefault() async {
    await SettingsStorage.resetBaseUrl();
    ApiClient().updateBaseUrl(kDefaultBaseUrl);
    if (!mounted) return;
    setState(() {
      _urlController.text = kDefaultBaseUrl;
      _testResult = null;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Reset to default: http://localhost:8081'),
        backgroundColor: AppColors.info,
      ),
    );
  }

  void _applyPreset(String presetUrl) {
    setState(() {
      _urlController.text = presetUrl;
      _testResult = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final customColors = context.appColors;

    return Scaffold(
      backgroundColor: customColors.background,
      appBar: AppBar(
        title: Text(
          'Backend Settings',
          style: AppTypography.cardTitle.copyWith(fontSize: 18),
        ),
        backgroundColor: customColors.surface,
        elevation: 0,
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: AppSpacing.maxContentWidth),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Info Card
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: customColors.surface,
                      borderRadius: BorderRadius.circular(AppRadius.card),
                      border: Border.all(color: customColors.border),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(AppSpacing.sm),
                          decoration: BoxDecoration(
                            color: customColors.primaryLight,
                            borderRadius: BorderRadius.circular(AppRadius.input),
                          ),
                          child: Icon(
                            Icons.dns_rounded,
                            color: customColors.primary,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Backend Host Configuration',
                                style: AppTypography.cardTitle.copyWith(fontSize: 15),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Set the Spring Boot OAS 3.1 REST API endpoint used for campus authentication and lost & found records.',
                                style: AppTypography.caption.copyWith(
                                  color: customColors.textSecondary,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // URL Input Field
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: customColors.surface,
                      borderRadius: BorderRadius.circular(AppRadius.card),
                      border: Border.all(color: customColors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        AppTextField(
                          label: 'API Server Base URL *',
                          hintText: 'http://localhost:8081',
                          controller: _urlController,
                          keyboardType: TextInputType.url,
                          prefixIcon: const Icon(Icons.link_rounded, size: 20),
                        ),
                        const SizedBox(height: AppSpacing.md),

                        // Quick Presets
                        Text(
                          'Quick Environment Presets',
                          style: AppTypography.label.copyWith(color: customColors.textSecondary),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            ActionChip(
                              avatar: const Icon(Icons.computer, size: 16),
                              label: const Text('Localhost (8081)'),
                              backgroundColor: customColors.background,
                              side: BorderSide(color: customColors.border),
                              labelStyle: AppTypography.caption.copyWith(color: customColors.textPrimary),
                              onPressed: () => _applyPreset('http://localhost:8081'),
                            ),
                            ActionChip(
                              avatar: const Icon(Icons.phone_android, size: 16),
                              label: const Text('Android Host (10.0.2.2:8081)'),
                              backgroundColor: customColors.background,
                              side: BorderSide(color: customColors.border),
                              labelStyle: AppTypography.caption.copyWith(color: customColors.textPrimary),
                              onPressed: () => _applyPreset('http://10.0.2.2:8081'),
                            ),
                            ActionChip(
                              avatar: const Icon(Icons.lan, size: 16),
                              label: const Text('LAN Server (192.168.1.100)'),
                              backgroundColor: customColors.background,
                              side: BorderSide(color: customColors.border),
                              labelStyle: AppTypography.caption.copyWith(color: customColors.textPrimary),
                              onPressed: () => _applyPreset('http://192.168.1.100:8081'),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.lg),

                        // Test Connection Button
                        AppButton(
                          text: _isTesting ? 'Testing Connectivity...' : 'Test Connection',
                          variant: ButtonVariant.secondary,
                          icon: Icons.network_check_rounded,
                          isLoading: _isTesting,
                          onPressed: _testConnection,
                        ),

                        // Test feedback banner
                        if (_testResult != null) ...[
                          const SizedBox(height: AppSpacing.sm),
                          Container(
                            padding: const EdgeInsets.all(AppSpacing.sm),
                            decoration: BoxDecoration(
                              color: _testSuccess
                                  ? AppColors.success.withOpacity(0.12)
                                  : AppColors.error.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(AppRadius.input),
                              border: Border.all(
                                color: _testSuccess ? AppColors.success : AppColors.error,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  _testSuccess ? Icons.check_circle : Icons.error_outline,
                                  color: _testSuccess ? AppColors.success : AppColors.error,
                                  size: 18,
                                ),
                                const SizedBox(width: AppSpacing.xs),
                                Expanded(
                                  child: Text(
                                    _testResult!,
                                    style: TextStyle(
                                      fontFamily: AppTypography.fontFamily,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: _testSuccess ? AppColors.success : AppColors.error,
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
                  const SizedBox(height: AppSpacing.lg),

                  // Save and Apply Button
                  AppButton(
                    text: 'Save and Apply',
                    isLoading: _isLoading,
                    icon: Icons.save_rounded,
                    onPressed: _saveSettings,
                  ),
                  const SizedBox(height: AppSpacing.sm),

                  // Reset Button
                  AppButton(
                    text: 'Reset to Default (localhost:8081)',
                    variant: ButtonVariant.tertiary,
                    icon: Icons.refresh,
                    onPressed: _resetToDefault,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
