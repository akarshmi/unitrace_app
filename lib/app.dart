import 'package:flutter/material.dart';
import 'core/core.dart';
import 'features/auth/auth.dart';
import 'features/items/items.dart';
import 'features/moderator/moderator.dart';
import 'features/settings/settings.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class UniTraceApp extends StatelessWidget {
  final String initialRoute;

  const UniTraceApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      initialRoute: initialRoute,
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const HomeScreen(),
        '/settings': (context) => const SettingsScreen(),
        '/moderator/home': (context) => const ModeratorHomeScreen(),
        '/moderator/review': (context) => const ModeratorItemReviewScreen(),
        '/moderator/desk': (context) => const ModeratorDeskScreen(),
        '/moderator/profile': (context) => const ModeratorProfileScreen(),
      },
    );
  }
}
