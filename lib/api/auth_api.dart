import 'package:dio/dio.dart';
import 'api_client.dart';
import '../storage/token_storage.dart';

class AuthApi {
  final ApiClient _client = ApiClient();

  // OAS 3.1: POST /api/uni/v1/auth/registration/initiation
  Future<Map<String, dynamic>> registerInitiation({
    required String firstName,
    String lastName = '',
    String department = '',
    required int registrationNumber,
    required String uniEmail,
    String personalEmail = '',
    required String phoneNumber,
    required String password,
  }) async {
    final response = await _client.dio.post(
      '/api/uni/v1/auth/registration/initiation',
      data: {
        'firstName': firstName,
        'lastName': lastName,
        'department': department,
        'registrationNumber': registrationNumber,
        'uniEmail': uniEmail,
        'personalEmail': personalEmail,
        'phoneNumber': phoneNumber,
        'password': password,
      },
    );
    return Map<String, dynamic>.from(response.data as Map);
  }

  // OAS 3.1: POST /api/uni/v1/auth/registration/verification
  Future<Map<String, dynamic>> verifyRegistration({
    required String uniEmail,
    required String token,
    required String otp,
  }) async {
    final response = await _client.dio.post(
      '/api/uni/v1/auth/registration/verification',
      data: {
        'uniEmail': uniEmail,
        'token': token,
        'otp': otp,
      },
    );
    return Map<String, dynamic>.from(response.data as Map);
  }

  // OAS 3.1: POST /api/uni/v1/auth/login
  Future<String> login({
    required String uniEmail,
    required String password,
  }) async {
    final response = await _client.dio.post(
      '/api/uni/v1/auth/login',
      data: {
        'uniEmail': uniEmail,
        'password': password,
      },
    );

    final data = response.data as Map<String, dynamic>;
    final token = data['accessToken']?.toString() ?? '';
    if (token.isNotEmpty) {
      await TokenStorage.saveAccessToken(token);
      await TokenStorage.saveUserEmail(uniEmail);
    }
    return token;
  }

  // OAS 3.1: POST /api/uni/v1/auth/refresh
  Future<String> refresh() async {
    final response = await _client.dio.post('/api/uni/v1/auth/refresh');
    final data = response.data as Map<String, dynamic>;
    final token = data['accessToken']?.toString() ?? '';
    if (token.isNotEmpty) {
      await TokenStorage.saveAccessToken(token);
    }
    return token;
  }

  // OAS 3.1: POST /api/uni/v1/auth/logout
  Future<void> logout() async {
    try {
      await _client.dio.post('/api/uni/v1/auth/logout');
    } catch (_) {
      // Best effort logout on backend
    } finally {
      await TokenStorage.clearAll();
    }
  }
}
