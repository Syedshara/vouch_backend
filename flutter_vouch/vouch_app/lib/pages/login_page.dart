// lib/pages/login_page.dart
import 'package:flutter/material.dart';
import 'package:vouch_app/pages/dashboard_page.dart'; // THIS IS THE FIX
import 'package:vouch_app/pages/signup_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isLoading = false;

  void _handleLogin() async {
    setState(() { _isLoading = true; });
    await Future.delayed(const Duration(seconds: 2));
    setState(() { _isLoading = false; });

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const DashboardPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    // ... (Your existing UI code for the login page remains the same)
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
              TextFormField(decoration: const InputDecoration(labelText: 'Email'), keyboardType: TextInputType.emailAddress),
              const SizedBox(height: 16),
              TextFormField(decoration: const InputDecoration(labelText: 'Password'), obscureText: true),
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
          ),
        ),
      ),
    );
  }
}