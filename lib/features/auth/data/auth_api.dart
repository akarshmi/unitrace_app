import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../../../core/storage/token_storage.dart';
import '../models/user.dart';

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
      ApiEndpoints.registerInitiation,
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

    final data = Map<String, dynamic>.from(response.data as Map);
    final token = data['token']?.toString() ?? '';
    if (token.isNotEmpty) {
      await TokenStorage.savePendingVerification(
        token: token,
        email: uniEmail,
      );
    }
    return data;
  }

  // OAS 3.1: POST /api/uni/v1/auth/registration/verification
  Future<Map<String, dynamic>> verifyRegistration({
    required String uniEmail,
    required String token,
    required String otp,
  }) async {
    final response = await _client.dio.post(
      ApiEndpoints.registerVerification,
      data: {
        'uniEmail': uniEmail,
        'token': token,
        'otp': otp,
      },
    );

    await TokenStorage.clearPendingVerification();
    return Map<String, dynamic>.from(response.data as Map);
  }

  // OAS 3.1: POST /api/uni/v1/auth/login -> returns TokenResponse with role
  Future<TokenResponse> login({
    required String uniEmail,
    required String password,
  }) async {
    final response = await _client.dio.post(
      ApiEndpoints.login,
      data: {
        'uniEmail': uniEmail,
        'password': password,
      },
    );

    final data = Map<String, dynamic>.from(response.data as Map);
    final tokenResponse = TokenResponse.fromJson(data);

    if (tokenResponse.accessToken.isNotEmpty) {
      await TokenStorage.saveAccessToken(tokenResponse.accessToken);
      await TokenStorage.saveUserRole(tokenResponse.role);
      await TokenStorage.saveUserEmail(uniEmail);
      if (tokenResponse.user != null) {
        if (tokenResponse.user!.id.isNotEmpty) {
          await TokenStorage.saveUserId(tokenResponse.user!.id);
        }
        if (tokenResponse.user!.firstName != null) {
          final fullName = '${tokenResponse.user!.firstName} ${tokenResponse.user!.lastName ?? ''}'.trim();
          await TokenStorage.saveUserName(fullName);
        }
      }
    }
    return tokenResponse;
  }

  // OAS 3.1: POST /api/uni/v1/auth/refresh -> returns TokenResponse with role
  Future<TokenResponse> refresh() async {
    final response = await _client.dio.post(ApiEndpoints.refresh);
    final data = Map<String, dynamic>.from(response.data as Map);
    final tokenResponse = TokenResponse.fromJson(data);

    if (tokenResponse.accessToken.isNotEmpty) {
      await TokenStorage.saveAccessToken(tokenResponse.accessToken);
      await TokenStorage.saveUserRole(tokenResponse.role);
    }
    return tokenResponse;
  }

  // OAS 3.1: POST /api/uni/v1/auth/logout
  Future<void> logout() async {
    try {
      await _client.dio.post(ApiEndpoints.logout);
    } catch (_) {
      // Best effort backend session invalidation
    } finally {
      await TokenStorage.clearAll();
    }
  }
}
