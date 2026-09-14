import 'package:flutter/material.dart';
import 'api/api_client.dart';
import 'constants.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/home_screen.dart';
import 'storage/token_storage.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Configure ApiClient unauthorized 401 callback to redirect to Login
  ApiClient().onUnauthorized = () {
    navigatorKey.currentState?.pushNamedAndRemoveUntil('/login', (route) => false);
  };

  final existingToken = await TokenStorage.getAccessToken();
  final initialRoute = (existingToken != null && existingToken.isNotEmpty) ? '/home' : '/login';

  runApp(UniTraceApp(initialRoute: initialRoute));
}

class UniTraceApp extends StatelessWidget {
  final String initialRoute;

  const UniTraceApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'UniTrace',
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      initialRoute: initialRoute,
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const HomeScreen(),
      },
    );
  }
}
