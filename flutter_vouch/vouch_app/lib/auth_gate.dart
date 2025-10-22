import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:vouch_app/pages/login_page.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  final LocalAuthentication auth = LocalAuthentication();

  @override
  void initState() {
    super.initState();
    // We can't call async code directly in initState, so we call it after the first frame.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _authenticate();
    });
  }

  Future<void> _authenticate() async {
    try {
      final bool canAuthenticate = await auth.canCheckBiometrics && await auth.isDeviceSupported();

      if (!canAuthenticate) {
        // If the device doesn't support biometrics or a lock screen, we can't proceed securely.
        // For this app, we'll navigate to login, but a real finance app might show an error and exit.
        _navigateToLogin();
        return;
      }

      // This is the crucial call.
      // We do NOT set biometricOnly: true. This allows the OS to fall back
      // to the device's PIN, pattern, or password if biometrics fail.
      final bool didAuthenticate = await auth.authenticate(
        localizedReason: 'Please authenticate to open Vouch',
        options: const AuthenticationOptions(
          stickyAuth: true, // Keep the authentication dialog open until it's resolved.
        ),
      );

      if (didAuthenticate && mounted) {
        // Authentication successful, navigate to the main app.
        _navigateToLogin();
      } else {
        // User cancelled authentication. For security, exit the app.
        SystemNavigator.pop();
      }
    } on PlatformException catch (e) {
      // Handle exceptions like no enrolled biometrics or no device lock screen.
      print('Authentication error: $e');
      // In case of an error (e.g., user has no lock screen set up), exit the app.
      SystemNavigator.pop();
    }
  }

  void _navigateToLogin() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Show a simple loading/waiting screen while the native authentication prompt is displayed.
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lock_outline, color: Theme.of(context).primaryColor, size: 80),
            const SizedBox(height: 20),
            const Text('Unlocking Vouch...', style: TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }
}

