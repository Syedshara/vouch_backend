// lib/main.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vouch/app_theme.dart';
import 'package:vouch/auth_gate.dart';
import 'package:vouch/providers/reward_provider.dart';
import 'package:vouch/providers/visit_provider.dart';
import 'package:vouch/providers/review_provider.dart';
import 'package:vouch/providers/location_provider.dart';
import 'package:vouch/providers/business_provider.dart';
import 'package:vouch/providers/vouch_provider.dart';
import 'package:vouch/services/auth_service.dart';
import 'package:vouch/providers/notification_provider.dart';

final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
GlobalKey<ScaffoldMessengerState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://hviazayuwexvsmcemyzi.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imh2aWF6YXl1d2V4dnNtY2VteXppIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc2MTkxODM4MywiZXhwIjoyMDc3NDk0MzgzfQ.0qY71XQG-IwZrTWtIZgbC5i8CpI6WXAjN7GJ8Ux317g',
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthService()),

        ChangeNotifierProxyProvider<AuthService, RewardProvider>(
          create: (context) => RewardProvider(context.read<AuthService>()),
          update: (context, auth, previous) => RewardProvider(auth),
        ),

        ChangeNotifierProvider(create: (context) => VisitProvider()),

        ChangeNotifierProxyProvider<AuthService, ReviewProvider>(
          create: (context) => ReviewProvider(context.read<AuthService>()),
          update: (context, auth, previous) => ReviewProvider(auth),
        ),

        ChangeNotifierProvider(create: (context) => LocationProvider()),
        ChangeNotifierProvider(create: (context) => BusinessProvider()),

        ChangeNotifierProvider(
          create: (context) => NotificationProvider(scaffoldMessengerKey),
        ),

        // --- THIS IS THE FIX ---
        // We update this from ProxyProvider2 to ProxyProvider3
        // to give VouchProvider access to RewardProvider.
        ChangeNotifierProxyProvider3<LocationProvider, AuthService, RewardProvider, VouchProvider>(
          create: (context) => VouchProvider(
            context.read<LocationProvider>(),
            context.read<AuthService>(),
            context.read<RewardProvider>(), // <-- ADDED THIS
          ),
          update: (context, locationProvider, authService, rewardProvider, vouchProvider) =>
              vouchProvider ?? VouchProvider(locationProvider, authService, rewardProvider), // <-- FIX: Reuse existing instance
        ),
        // --- END FIX ---
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      scaffoldMessengerKey: scaffoldMessengerKey,
      title: 'Vouch',
      theme: AppTheme.theme,
      home: const AuthGate(),
    );
  }
}