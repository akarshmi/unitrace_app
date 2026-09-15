import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorage {
  static const _storage = FlutterSecureStorage();
  static const _accessTokenKey = 'jwt_access_token';
  static const _userRoleKey = 'user_role';
  static const _userEmailKey = 'user_email';
  static const _userNameKey = 'user_name';
  static const _userIdKey = 'user_id';
  static const _registrationNumberKey = 'user_registration_number';
  static const _departmentKey = 'user_department';
  static const _pendingTokenKey = 'pending_verification_token';
  static const _pendingEmailKey = 'pending_verification_email';

  static Future<void> saveAccessToken(String token) async {
    await _storage.write(key: _accessTokenKey, value: token);
  }

  static Future<String?> getAccessToken() async {
    return await _storage.read(key: _accessTokenKey);
  }

  static Future<void> saveUserRole(String role) async {
    await _storage.write(key: _userRoleKey, value: role.toUpperCase());
  }

  static Future<String?> getUserRole() async {
    return await _storage.read(key: _userRoleKey);
  }

  static Future<void> saveUserEmail(String email) async {
    await _storage.write(key: _userEmailKey, value: email);
  }

  static Future<String?> getUserEmail() async {
    return await _storage.read(key: _userEmailKey);
  }

  static Future<void> saveUserName(String name) async {
    await _storage.write(key: _userNameKey, value: name);
  }

  static Future<String?> getUserName() async {
    return await _storage.read(key: _userNameKey);
  }

  static Future<void> saveUserId(String id) async {
    await _storage.write(key: _userIdKey, value: id);
  }

  static Future<String?> getUserId() async {
    return await _storage.read(key: _userIdKey);
  }

  static Future<void> saveDepartment(String dept) async {
    await _storage.write(key: _departmentKey, value: dept);
  }

  static Future<String?> getDepartment() async {
    return await _storage.read(key: _departmentKey);
  }

  static Future<void> saveRegistrationNumber(int regNum) async {
    await _storage.write(key: _registrationNumberKey, value: regNum.toString());
  }

  static Future<String?> getRegistrationNumber() async {
    return await _storage.read(key: _registrationNumberKey);
  }

  static Future<void> savePendingVerification({
    required String token,
    required String email,
  }) async {
    await _storage.write(key: _pendingTokenKey, value: token);
    await _storage.write(key: _pendingEmailKey, value: email);
  }

  static Future<String?> getPendingVerificationToken() async {
    return await _storage.read(key: _pendingTokenKey);
  }

  static Future<String?> getPendingVerificationEmail() async {
    return await _storage.read(key: _pendingEmailKey);
  }

  static Future<void> clearPendingVerification() async {
    await _storage.delete(key: _pendingTokenKey);
    await _storage.delete(key: _pendingEmailKey);
  }

  static Future<void> clearAll() async {
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _userRoleKey);
    await _storage.delete(key: _userEmailKey);
    await _storage.delete(key: _userNameKey);
    await _storage.delete(key: _userIdKey);
    await _storage.delete(key: _registrationNumberKey);
    await _storage.delete(key: _departmentKey);
    await _storage.delete(key: _pendingTokenKey);
    await _storage.delete(key: _pendingEmailKey);
  }
}
