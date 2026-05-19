

import 'package:flutter/material.dart';
import '../views/auth/login_screen.dart';
import '../views/student/home_screen.dart';
import '../views/student/application_form_screen.dart';
import '../views/student/application_detail_screen.dart';
import '../views/admin/admin_dashboard_screen.dart';
import '../models/application_model.dart';

class AppRoutes {
  static const String login           = '/login';
  static const String studentHome     = '/student/home';
  static const String applicationForm = '/student/apply';
  static const String applicationDetail = '/student/application';
  static const String adminDashboard  = '/admin/dashboard';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return _fadeRoute(const LoginScreen(), settings);
      case studentHome:
        return _slideRoute(const HomeScreen(), settings);
      case applicationForm:
        final args = settings.arguments as Map<String, dynamic>?;
        return _slideRoute(ApplicationFormScreen(existingApp: args?['application']), settings);
      case applicationDetail:
        final app = settings.arguments as ApplicationModel;
        return _slideRoute(ApplicationDetailScreen(application: app), settings);
      case adminDashboard:
        return _fadeRoute(const AdminDashboardScreen(), settings);
      default:
        return _fadeRoute(const LoginScreen(), settings);
    }
  }

  static PageRouteBuilder _slideRoute(Widget page, RouteSettings settings) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, animation, __, child) {
        final tween = Tween(begin: const Offset(1.0, 0.0), end: Offset.zero)
            .chain(CurveTween(curve: Curves.easeOutCubic));
        return SlideTransition(position: animation.drive(tween), child: child);
      },
      transitionDuration: const Duration(milliseconds: 300),
    );
  }

  static PageRouteBuilder _fadeRoute(Widget page, RouteSettings settings) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, animation, __, child) {
        return FadeTransition(opacity: animation, child: child);
      },
      transitionDuration: const Duration(milliseconds: 250),
    );
  }
}
