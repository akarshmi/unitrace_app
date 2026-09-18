import 'package:flutter/material.dart';
import '../../../core/core.dart';
import '../data/notification_storage.dart';
import '../models/match_result.dart';

class NotificationsModal extends StatefulWidget {
  const NotificationsModal({super.key});

  @override
  State<NotificationsModal> createState() => _NotificationsModalState();
}

class _NotificationsModalState extends State<NotificationsModal> {
  List<AppNotification> _notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final list = await NotificationStorage.getNotifications();
    if (!mounted) return;
    setState(() {
      _notifications = list;
      _isLoading = false;
    });
    // Mark as read after viewing
    await NotificationStorage.markAllAsRead();
  }

  @override
  Widget build(BuildContext context) {
    final customColors = context.appColors;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.75,
      ),
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Icon(Icons.notifications_active_rounded, color: customColors.navyPrimary, size: 24),
                const SizedBox(width: 10),
                Text(
                  'Campus Notifications',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: customColors.textPrimary,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _notifications.isEmpty
                    ? Center(
                        child: Text(
                          'No notifications at this time.',
                          style: TextStyle(color: customColors.textMuted),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        itemCount: _notifications.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final n = _notifications[index];
                          return ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                            leading: CircleAvatar(
                              backgroundColor: n.type == 'MATCH_FOUND'
                                  ? customColors.accentAmber.withOpacity(0.2)
                                  : customColors.navyPrimary.withOpacity(0.1),
                              child: Icon(
                                n.type == 'MATCH_FOUND'
                                    ? Icons.auto_awesome
                                    : n.type == 'CLAIM_SUBMITTED'
                                        ? Icons.verified_user_outlined
                                        : Icons.info_outline,
                                color: n.type == 'MATCH_FOUND'
                                    ? customColors.accentAmber
                                    : customColors.navyPrimary,
                                size: 20,
                              ),
                            ),
                            title: Text(
                              n.title,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: customColors.textPrimary,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 4),
                                Text(
                                  n.message,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: customColors.textBody,
                                    height: 1.3,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _formatTime(n.timestamp),
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: customColors.textMuted,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${dt.month}/${dt.day}';
  }
}
