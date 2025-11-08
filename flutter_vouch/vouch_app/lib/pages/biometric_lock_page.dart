// lib/pages/biometric_lock_page.dart
import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:provider/provider.dart';
import 'package:vouch/services/auth_service.dart';
import 'package:vouch/app_theme.dart';

class BiometricLockPage extends StatefulWidget {
  const BiometricLockPage({super.key});

  @override
  State<BiometricLockPage> createState() => _BiometricLockPageState();
}

class _BiometricLockPageState extends State<BiometricLockPage> {
  final LocalAuthentication _auth = LocalAuthentication();
  bool _isAuthenticating = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // Automatically trigger authentication when page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _authenticate();
    });
  }

  Future<void> _authenticate() async {
    setState(() {
      _isAuthenticating = true;
      _errorMessage = null;
    });

    bool authenticated = false;
    try {
      bool canCheckBiometrics = await _auth.canCheckBiometrics;
      bool isDeviceSupported = await _auth.isDeviceSupported();

      if (canCheckBiometrics && isDeviceSupported) {
        authenticated = await _auth.authenticate(
          localizedReason: 'Please authenticate to access Vouch',
          options: const AuthenticationOptions(
            stickyAuth: true,
            biometricOnly: false, // Allows PIN/Password as well
          ),
        );
      } else {
        // Device doesn't support biometrics, just unlock
        authenticated = true;
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Authentication error: ${e.toString()}';
        _isAuthenticating = false;
      });
      return;
    }

    if (authenticated && mounted) {
      // Unlock the app in AuthService
      final authService = context.read<AuthService>();
      await authService.unlockWithBiometric();
      // AuthGate will automatically redirect to DashboardPage
    } else if (mounted) {
      // User cancelled or failed
      setState(() {
        _isAuthenticating = false;
        _errorMessage = 'Authentication failed. Please try again.';
      });
    }
  }

  Future<void> _handleLogout() async {
    final authService = context.read<AuthService>();
    await authService.signOut();
    // AuthGate will automatically redirect to LoginPage
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.lock_outline, size: 80, color: AppTheme.primary),
              const SizedBox(height: 20),
              const Text(
                'Vouch is Locked',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(
                'Please authenticate to continue',
                style: TextStyle(fontSize: 16, color: Colors.grey[400]),
              ),
              const SizedBox(height: 40),
              if (_isAuthenticating)
                const CircularProgressIndicator()
              else ...[
                ElevatedButton.icon(
                  onPressed: _authenticate,
                  icon: const Icon(Icons.fingerprint),
                  label: const Text('Unlock'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  ),
                ),
                if (_errorMessage != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ],
                const SizedBox(height: 32),
                TextButton(
                  onPressed: _handleLogout,
                  child: const Text('Sign in with different account'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}