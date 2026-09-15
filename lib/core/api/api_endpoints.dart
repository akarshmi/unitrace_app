/// OAS 3.1 Backend Endpoints Specification for UniTrace
class ApiEndpoints {
  ApiEndpoints._();

  static const String basePrefix = '/api/uni/v1';

  // Auth
  static const String registerInitiation = '$basePrefix/auth/registration/initiation';
  static const String registerVerification = '$basePrefix/auth/registration/verification';
  static const String login = '$basePrefix/auth/login';
  static const String refresh = '$basePrefix/auth/refresh';
  static const String logout = '$basePrefix/auth/logout';

  // Items
  static const String items = '$basePrefix/items';
  static String itemById(String id) => '$basePrefix/items/$id';
  static String itemStatus(String id) => '$basePrefix/items/$id/status';
}
