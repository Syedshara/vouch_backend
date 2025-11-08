// lib/pages/login_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:local_auth/local_auth.dart';
import 'package:vouch/pages/signup_page.dart';
import 'package:vouch/services/auth_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final LocalAuthentication _localAuth = LocalAuthentication();
  bool _isLoading = false;
  bool _showCredentialFields = false;

  @override
  void initState() {
    super.initState();
    // Use addPostFrameCallback to access context after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkForReturningUser();
    });
  }

  Future<void> _checkForReturningUser() async {
    if (!mounted) return;

    final authService = context.read<AuthService>();

    // Ensure service is initialized first
    await authService.ensureInitialized();

    print('DEBUG: Checking returning user...');
    print('DEBUG: hasLoggedInBefore = ${authService.hasLoggedInBefore}');

    final hasSession = await authService.hasValidSession();
    print('DEBUG: hasValidSession = $hasSession');

    // Check if user has logged in before and has a valid session
    if (authService.hasLoggedInBefore && hasSession) {
      // Returning user - try biometric authentication
      print('DEBUG: Returning user detected, showing biometric auth');
      if (mounted) {
        await _tryBiometricAuth();
      }
    } else {
      // First time user - show credential fields
      print('DEBUG: First time user or no valid session, showing credential fields');
      if (mounted) {
        setState(() {
          _showCredentialFields = true;
        });
      }
    }
  }

  Future<void> _tryBiometricAuth() async {
    setState(() { _isLoading = true; });

    try {
      bool canCheckBiometrics = await _localAuth.canCheckBiometrics;
      bool isDeviceSupported = await _localAuth.isDeviceSupported();

      if (canCheckBiometrics && isDeviceSupported) {
        bool authenticated = await _localAuth.authenticate(
          localizedReason: 'Please authenticate to access Vouch',
          options: const AuthenticationOptions(
            stickyAuth: true,
            biometricOnly: false, // Allows PIN/Password fallback
          ),
        );

        if (authenticated && mounted) {
          // Restore session
          final authService = context.read<AuthService>();
          bool restored = await authService.restoreSession();

          if (!restored && mounted) {
            // Session restore failed, show credential fields
            setState(() {
              _isLoading = false;
              _showCredentialFields = true;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Session expired. Please sign in again.'), backgroundColor: Colors.orange),
            );
          }
        } else if (mounted) {
          // Auth cancelled or failed, show credential fields
          setState(() {
            _isLoading = false;
            _showCredentialFields = true;
          });
        }
      } else {
        // Biometric not available, show credential fields
        setState(() {
          _isLoading = false;
          _showCredentialFields = true;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _showCredentialFields = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Authentication error: ${e.toString()}'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _handleLogin() async {
    setState(() { _isLoading = true; });
    final authService = context.read<AuthService>();

    final error = await authService.signIn(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
    );

    // If there is an error, stop loading and show it
    if (error != null && mounted) {
      setState(() { _isLoading = false; });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), backgroundColor: Colors.red),
      );
    }

    // If login is successful (error == null),
    // the AuthGate will automatically navigate to the DashboardPage.
    // We don't need to do anything here and we no longer show the dialog.
  }

  // --- The _showEnableBiometricsDialog() function has been removed ---

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Welcome Back', textAlign: TextAlign.center, style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 8),
              Text('Sign in to your Vouch account', textAlign: TextAlign.center, style: TextStyle(fontSize: 16, color: Colors.grey[400])),
              const SizedBox(height: 48),

              // Show loading or biometric prompt
              if (_isLoading && !_showCredentialFields) ...[
                const Icon(Icons.fingerprint, size: 80, color: Colors.white),
                const SizedBox(height: 20),
                const Text('Authenticate to continue', textAlign: TextAlign.center, style: TextStyle(fontSize: 16)),
                const SizedBox(height: 20),
                const CircularProgressIndicator(),
                const SizedBox(height: 32),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _isLoading = false;
                      _showCredentialFields = true;
                    });
                  },
                  child: const Text('Use Email & Password Instead'),
                ),
              ]
              // Show credential fields
              else if (_showCredentialFields) ...[
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(labelText: 'Password'),
                  obscureText: true,
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _isLoading ? null : _handleLogin,
                  child: _isLoading ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('Sign In', style: TextStyle(fontSize: 16)),
                ),
                const SizedBox(height: 24),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(builder: (context) => const SignupPage()));
                  },
                  child: Text("Don't have an account? Sign Up", style: TextStyle(color: Theme.of(context).primaryColor)),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}