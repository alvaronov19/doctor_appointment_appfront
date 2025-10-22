import 'package:flutter/material.dart';
import 'home_page.dart';
import 'profile_page.dart';
import 'login_page.dart';
import 'messages.dart';
import 'info_page.dart';
import 'profile_form_page.dart';

class Routes {
  static const String login = '/login';
  static const String home = '/home';
  static const String profile = '/profile';
  static const String messages = '/messages';
  static const String infoPage = '/info';
  static const String profileForm = '/profileForm';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return MaterialPageRoute(builder: (_) => LoginPage());
      case home:
        return MaterialPageRoute(builder: (_) => const HomePage());
      case profile:
        return MaterialPageRoute(builder: (_) => const ProfilePage());
      case messages:
        return MaterialPageRoute(builder: (_) => const MessagesPage());
      case profileForm:
        return MaterialPageRoute(builder: (_) => const ProfileFormPage());
      case infoPage: 
        final args = settings.arguments as Map<String, String>;
        return MaterialPageRoute(
          builder: (_) => InfoPage(
            title: args['title']!,
            content: args['content']!,
          ),
        );
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}