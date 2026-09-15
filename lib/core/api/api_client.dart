import 'package:dio/dio.dart';
import '../api/api_endpoints.dart';
import '../constants/app_constants.dart';
import '../storage/settings_storage.dart';
import '../storage/token_storage.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;

  late Dio dio;
  String baseUrl = kDefaultBaseUrl;
  void Function()? onUnauthorized;
  bool _isRefreshing = false;

  ApiClient._internal() {
    dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 12),
        receiveTimeout: const Duration(seconds: 12),
        headers: {
          'Accept': 'application/json',
        },
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await TokenStorage.getAccessToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException error, handler) async {
          if (error.response?.statusCode == 401 && !_isRefreshing) {
            final path = error.requestOptions.path;
            if (path.contains('/auth/login') || path.contains('/auth/refresh')) {
              return handler.next(error);
            }

            _isRefreshing = true;
            try {
              // Attempt silent refresh via /api/uni/v1/auth/refresh
              final refreshResponse = await dio.post(
                '$baseUrl${ApiEndpoints.refresh}',
                options: Options(
                  headers: {'Accept': 'application/json'},
                  extra: {'withCredentials': true},
                ),
              );

              if (refreshResponse.statusCode == 200 && refreshResponse.data != null) {
                final data = refreshResponse.data;
                final newAccessToken = data is Map ? data['accessToken']?.toString() : null;
                final newRole = data is Map ? data['role']?.toString() : null;

                if (newAccessToken != null && newAccessToken.isNotEmpty) {
                  await TokenStorage.saveAccessToken(newAccessToken);
                  if (newRole != null && newRole.isNotEmpty) {
                    await TokenStorage.saveUserRole(newRole);
                  }
                  _isRefreshing = false;

                  // Retry the original failed request
                  final retryOptions = error.requestOptions;
                  retryOptions.headers['Authorization'] = 'Bearer $newAccessToken';
                  final retryResponse = await dio.fetch(retryOptions);
                  return handler.resolve(retryResponse);
                }
              }
            } catch (e) {
              // Refresh failed
            } finally {
              _isRefreshing = false;
            }

            // Both attempt and refresh failed: clear storage and trigger logout callback
            await TokenStorage.clearAll();
            onUnauthorized?.call();
          }
          return handler.next(error);
        },
      ),
    );

    // Asynchronously load stored base URL
    _loadStoredBaseUrl();
  }

  Future<void> _loadStoredBaseUrl() async {
    final savedUrl = await SettingsStorage.getBaseUrl();
    updateBaseUrl(savedUrl);
  }

  void updateBaseUrl(String newUrl) {
    var cleaned = newUrl.trim();
    if (cleaned.endsWith('/')) {
      cleaned = cleaned.substring(0, cleaned.length - 1);
    }
    baseUrl = cleaned;
    dio.options.baseUrl = cleaned;
  }
}
