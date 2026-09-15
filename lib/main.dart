import 'package:flutter/material.dart';
import 'app.dart';
import 'core/core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Configure ApiClient unauthorized 401 callback to redirect to Login
  ApiClient().onUnauthorized = () {
    navigatorKey.currentState?.pushNamedAndRemoveUntil('/login', (route) => false);
  };

  final existingToken = await TokenStorage.getAccessToken();
  final existingRole = await TokenStorage.getUserRole();

  String initialRoute = '/login';
  if (existingToken != null && existingToken.isNotEmpty) {
    if (existingRole == 'MODERATOR' || existingRole == 'ADMIN') {
      initialRoute = '/moderator/home';
    } else {
      initialRoute = '/home';
    }
  }

  runApp(UniTraceApp(initialRoute: initialRoute));
}
