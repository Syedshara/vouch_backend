// lib/auth_gate.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vouch/pages/dashboard_page.dart';
import 'package:vouch/pages/login_page.dart';
import 'package:vouch/services/auth_service.dart';
import 'package:vouch/providers/notification_provider.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = context.watch<AuthService>();

    if (authService.isAuthenticated) {
      // User is authenticated, show dashboard
      final notificationProvider = context.read<NotificationProvider>();
      notificationProvider.fetchNotifications();
      notificationProvider.listenForNotifications();

      return const DashboardPage();
    } else {
      // Show login page (will handle biometric auth internally)
      return const LoginPage();
    }
  }
}