import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../../../core/core.dart';

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
        const SnackBar(content: Text('Please enter a server URL to test')),
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

      // Ping items endpoint with required parameters
      final response = await dio.get(
        '$cleanUrl/api/uni/v1/items',
        queryParameters: {'type': 'LOST', 'status': 'OPEN', 'size': 1},
      );
      stopwatch.stop();

      if (!mounted) return;
      setState(() {
        _testSuccess = true;
        _testResult = 'Connection successful! Status ${response.statusCode} (${stopwatch.elapsedMilliseconds}ms)';
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
        const SnackBar(content: Text('Server URL cannot be empty')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      await SettingsStorage.saveBaseUrl(newUrl);
      ApiClient().updateBaseUrl(newUrl);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Saved backend URL: $newUrl')),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving settings: $e')),
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
      const SnackBar(content: Text('Reset to default: http://localhost:8081')),
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
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        title: Text(
          'Backend Settings',
          style: TextStyle(
            color: colorScheme.onPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Info Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: customColors.borderDivider),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: customColors.navyPrimary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.dns_rounded,
                      color: customColors.navyPrimary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Server Base URL Configuration',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: customColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Configure the Spring Boot OAS 3.1 server address used for all auth and item queries.',
                          style: TextStyle(
                            fontSize: 13,
                            color: customColors.textMuted,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // URL Input Field
            Text(
              'Backend Host / URL',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: customColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _urlController,
              keyboardType: TextInputType.url,
              style: TextStyle(color: customColors.textPrimary),
              decoration: InputDecoration(
                hintText: 'http://localhost:8081',
                hintStyle: TextStyle(color: customColors.textMuted),
                prefixIcon: Icon(Icons.link, color: customColors.navyPrimary),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: customColors.borderDivider),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: customColors.borderDivider),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: customColors.navyPrimary, width: 1.5),
                ),
                filled: true,
                fillColor: colorScheme.surface,
              ),
            ),
            const SizedBox(height: 16),

            // Quick Preset Chips
            Text(
              'Quick Presets',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: customColors.textMuted,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ActionChip(
                  avatar: const Icon(Icons.computer, size: 16),
                  label: const Text('Localhost (8081)'),
                  onPressed: () => _applyPreset('http://localhost:8081'),
                ),
                ActionChip(
                  avatar: const Icon(Icons.phone_android, size: 16),
                  label: const Text('Android Host (10.0.2.2:8081)'),
                  onPressed: () => _applyPreset('http://10.0.2.2:8081'),
                ),
                ActionChip(
                  avatar: const Icon(Icons.lan, size: 16),
                  label: const Text('Custom LAN (192.168.1.100:8081)'),
                  onPressed: () => _applyPreset('http://192.168.1.100:8081'),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Test Connection Button
            OutlinedButton.icon(
              onPressed: _isTesting ? null : _testConnection,
              icon: _isTesting
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.network_check_rounded),
              label: Text(_isTesting ? 'Testing...' : 'Test Connection'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                side: BorderSide(color: customColors.navyPrimary),
                foregroundColor: customColors.navyPrimary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),

            if (_testResult != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _testSuccess
                      ? customColors.success.withOpacity(0.12)
                      : customColors.error.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _testSuccess ? customColors.success : customColors.error,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _testSuccess ? Icons.check_circle : Icons.error_outline,
                      color: _testSuccess ? customColors.success : customColors.error,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _testResult!,
                        style: TextStyle(
                          fontSize: 13,
                          color: _testSuccess ? customColors.success : customColors.error,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 28),

            // Save and Apply Button
            AppButton(
              text: 'Save and Apply',
              isLoading: _isLoading,
              icon: Icons.save_rounded,
              onPressed: _saveSettings,
            ),
            const SizedBox(height: 12),

            // Reset Button
            TextButton.icon(
              onPressed: _resetToDefault,
              icon: Icon(Icons.refresh, color: customColors.textMuted, size: 18),
              label: Text(
                'Reset to Default (localhost:8081)',
                style: TextStyle(color: customColors.textMuted),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
