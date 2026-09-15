import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/app_constants.dart';

class SettingsStorage {
  static const _storage = FlutterSecureStorage();
  static const _baseUrlKey = 'backend_base_url';

  static Future<String> getBaseUrl() async {
    final saved = await _storage.read(key: _baseUrlKey);
    if (saved != null && saved.trim().isNotEmpty) {
      return saved.trim();
    }
    return kDefaultBaseUrl;
  }

  static Future<void> saveBaseUrl(String url) async {
    var cleaned = url.trim();
    if (cleaned.endsWith('/')) {
      cleaned = cleaned.substring(0, cleaned.length - 1);
    }
    await _storage.write(key: _baseUrlKey, value: cleaned);
  }

  static Future<void> resetBaseUrl() async {
    await _storage.delete(key: _baseUrlKey);
  }
}
