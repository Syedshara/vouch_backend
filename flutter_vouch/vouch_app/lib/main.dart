import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vouch_app/app_theme.dart';
import 'package:vouch_app/auth_gate.dart';
import 'package:vouch_app/providers/reward_provider.dart';
import 'package:vouch_app/providers/visit_provider.dart';
import 'package:vouch_app/providers/review_provider.dart';
import 'package:vouch_app/providers/location_provider.dart';
import 'package:vouch_app/providers/business_provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => RewardProvider()),
        ChangeNotifierProvider(create: (context) => VisitProvider()),
        ChangeNotifierProvider(create: (context) => ReviewProvider()),
        ChangeNotifierProvider(create: (context) => LocationProvider()),
        ChangeNotifierProvider(create: (context) => BusinessProvider()),
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
      title: 'Vouch',
      theme: AppTheme.theme,
      home: const AuthGate(),
    );
  }
}
