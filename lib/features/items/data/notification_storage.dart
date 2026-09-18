import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/match_result.dart';

class NotificationStorage {
  static const _storage = FlutterSecureStorage();
  static const _notificationsKey = 'app_user_notifications_v1';

  static Future<List<AppNotification>> getNotifications() async {
    final raw = await _storage.read(key: _notificationsKey);
    if (raw == null || raw.trim().isEmpty) {
      return _defaultNotifications();
    }
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      final parsed = list.map((e) => AppNotification.fromJson(e as Map<String, dynamic>)).toList();
      return parsed;
    } catch (_) {
      return _defaultNotifications();
    }
  }

  static Future<void> addNotification(AppNotification notif) async {
    final current = await getNotifications();
    // Prepend new notification
    current.insert(0, notif);
    // Keep max 50
    final trimmed = current.take(50).toList();
    final serialized = jsonEncode(trimmed.map((e) => e.toJson()).toList());
    await _storage.write(key: _notificationsKey, value: serialized);
  }

  static Future<void> markAllAsRead() async {
    final current = await getNotifications();
    final updated = current.map((n) => AppNotification(
      id: n.id,
      title: n.title,
      message: n.message,
      type: n.type,
      relatedItemId: n.relatedItemId,
      timestamp: n.timestamp,
      isRead: true,
    )).toList();
    final serialized = jsonEncode(updated.map((e) => e.toJson()).toList());
    await _storage.write(key: _notificationsKey, value: serialized);
  }

  static Future<int> getUnreadCount() async {
    final list = await getNotifications();
    return list.where((n) => !n.isRead).length;
  }

  static List<AppNotification> _defaultNotifications() {
    return [
      AppNotification(
        id: 'notif_welcome',
        title: 'UniTrace Active Tracking',
        message: 'Automatic matching is monitoring campus lost and found items 24/7.',
        type: 'SYSTEM',
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        isRead: false,
      ),
    ];
  }
}
