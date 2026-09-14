import 'package:dio/dio.dart';
import '../constants.dart';
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
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
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
            // Avoid looping on refresh or login endpoint
            final path = error.requestOptions.path;
            if (path.contains('/auth/login') || path.contains('/auth/refresh')) {
              return handler.next(error);
            }

            _isRefreshing = true;
            try {
              // Attempt silent refresh via /auth/refresh (cookie based)
              final refreshResponse = await dio.post(
                '$baseUrl/auth/refresh',
                options: Options(
                  headers: {'Accept': 'application/json'},
                  extra: {'withCredentials': true},
                ),
              );

              if (refreshResponse.statusCode == 200 && refreshResponse.data != null) {
                final newAccessToken = refreshResponse.data['accessToken'] as String?;
                if (newAccessToken != null && newAccessToken.isNotEmpty) {
                  await TokenStorage.saveAccessToken(newAccessToken);
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
  }

  void updateBaseUrl(String newUrl) {
    baseUrl = newUrl;
    dio.options.baseUrl = newUrl;
  }
}
