import 'package:flutter/material.dart';
import '../../../core/core.dart';
import '../../auth/auth.dart';
import '../../settings/screens/settings_screen.dart';

class ModeratorProfileScreen extends StatefulWidget {
  const ModeratorProfileScreen({super.key});

  @override
  State<ModeratorProfileScreen> createState() => _ModeratorProfileScreenState();
}

class _ModeratorProfileScreenState extends State<ModeratorProfileScreen> {
  final AuthApi _authApi = AuthApi();
  String? _email;
  String? _name;
  String? _role;
  String? _department;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final email = await TokenStorage.getUserEmail();
    final name = await TokenStorage.getUserName();
    final role = await TokenStorage.getUserRole();
    final dept = await TokenStorage.getDepartment();

    if (mounted) {
      setState(() {
        _email = email ?? 'moderator@university.edu';
        _name = name ?? 'Campus Staff Moderator';
        _role = role ?? 'MODERATOR';
        _department = dept ?? 'Campus Safety & Student Services';
      });
    }
  }

  Future<void> _handleLogout() async {
    await _authApi.logout();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final customColors = context.appColors;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        title: Row(
          children: [
            Text(
              'Staff Profile',
              style: TextStyle(color: colorScheme.onPrimary, fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: customColors.accentAmber,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'STAFF',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  color: customColors.navyPrimary,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Avatar and Badge Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: customColors.borderDivider),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: customColors.navyPrimary,
                    child: Icon(Icons.security_rounded, size: 44, color: customColors.accentAmber),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _name ?? 'Staff Moderator',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: customColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _email ?? '',
                    style: TextStyle(
                      fontSize: 13,
                      color: customColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: customColors.accentAmber.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: customColors.accentAmber),
                    ),
                    child: Text(
                      'ROLE: ${_role ?? "MODERATOR"}',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                        color: customColors.navyPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Station & Permissions
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: customColors.borderDivider),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Campus Station Details',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: customColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildDetailRow(Icons.business_rounded, 'Department', _department ?? 'Student Affairs', customColors),
                  const Divider(height: 16),
                  _buildDetailRow(Icons.place_rounded, 'Station', 'Desk #1 — Student Union Ground Floor', customColors),
                  const Divider(height: 16),
                  _buildDetailRow(Icons.badge_rounded, 'Staff Authority', 'Authorized for Status Transitions & Hand-overs', customColors),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Quick Actions
            ListTile(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: BorderSide(color: customColors.borderDivider),
              ),
              tileColor: Colors.white,
              leading: Icon(Icons.settings_suggest_rounded, color: customColors.navyPrimary),
              title: const Text('Backend Server Settings', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              subtitle: const Text('Configure OAS 3.1 host URL', style: TextStyle(fontSize: 12)),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SettingsScreen()),
                );
              },
            ),
            const SizedBox(height: 24),

            // Logout Button
            OutlinedButton.icon(
              onPressed: _handleLogout,
              icon: Icon(Icons.logout_rounded, color: customColors.error),
              label: Text(
                'Log Out of Staff Session',
                style: TextStyle(color: customColors.error, fontWeight: FontWeight.bold),
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                side: BorderSide(color: customColors.error.withOpacity(0.5)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value, AppCustomColors customColors) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: customColors.navyPrimary),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 11, color: customColors.textMuted),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: customColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
