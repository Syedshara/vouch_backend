// lib/services/auth_service.dart
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:vouch/api_config.dart'; // Make sure this path is correct

// --- NEW: Customer Model (Added) ---
class Customer {
  final String id;
  String name;
  final String email;
  String? phone;
  String? avatarUrl;

  Customer({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.avatarUrl,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id'],
      name: json['name'] ?? 'No Name',
      email: json['email'] ?? 'No Email',
      phone: json['phone'],
      avatarUrl: json['avatar_url'],
    );
  }
}
// --- END NEW ---

class AuthService with ChangeNotifier {
  final _storage = const FlutterSecureStorage();
  static const String _sessionKey = 'supabase_session';
  static const String _hasLoggedInBeforeKey = 'has_logged_in_before';

  final GoTrueClient _auth = Supabase.instance.client.auth;
  // --- NEW: Storage Client (Added) ---
  final SupabaseStorageClient _storageClient = Supabase.instance.client.storage;

  bool _isAuthenticated = false;
  bool get isAuthenticated => _isAuthenticated;

  bool _hasLoggedInBefore = false;
  bool get hasLoggedInBefore => _hasLoggedInBefore;

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  // --- NEW: Customer Profile State (Added) ---
  Customer? _customer;
  Customer? get customer {
    // If customer is null, try to create from current auth user
    if (_customer == null && _auth.currentUser != null) {
      final user = _auth.currentUser!;
      return Customer(
        id: user.id,
        name: user.userMetadata?['name'] ?? user.email?.split('@')[0] ?? 'User',
        email: user.email ?? '',
        phone: user.phone,
        avatarUrl: null,
      );
    }
    return _customer;
  }

  User? get currentUser => _auth.currentUser;
  bool _isLoadingProfile = false;
  bool get isLoadingProfile => _isLoadingProfile;
  // --- END NEW ---

  AuthService() {
    _loadSession();
  }

  Future<void> _loadSession() async {
    // Check if user has logged in before
    final hasLoggedInStr = await _storage.read(key: _hasLoggedInBeforeKey);
    _hasLoggedInBefore = hasLoggedInStr == 'true';

    print('DEBUG: Has logged in before: $_hasLoggedInBefore');
    print('DEBUG: hasLoggedInStr value: $hasLoggedInStr');

    // Don't auto-login, let login page handle biometric auth
    _isAuthenticated = false;
    _isInitialized = true;
    notifyListeners();
  }

  /// Ensure the service is initialized before using
  Future<void> ensureInitialized() async {
    if (!_isInitialized) {
      await _loadSession();
    }
  }

  Future<String?> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      await _auth.signUp(
        email: email,
        password: password,
        data: {'role': 'customer', 'name': name},
      );
      return null; // Success
    } on AuthException catch (e) {
      return e.message;
    }
  }

  Future<String?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _auth.signInWithPassword(
        email: email,
        password: password,
      );
      if (response.session != null) {
        await _storage.write(key: _sessionKey, value: jsonEncode(response.session!.toJson()));
        await _storage.write(key: _hasLoggedInBeforeKey, value: 'true');
        _isAuthenticated = true;
        _hasLoggedInBefore = true;
        // --- FIX: Fetch profile on login ---
        await getCustomerProfile();
        notifyListeners();
        return null; // Success
      }
      return 'An unknown error occurred';
    } on AuthException catch (e) {
      return e.message;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    await _storage.delete(key: _sessionKey);
    // Keep _hasLoggedInBeforeKey so we know user has logged in before
    _isAuthenticated = false;
    // --- FIX: Clear profile on sign out ---
    _customer = null;
    notifyListeners();
  }

  /// Check if a valid session exists
  Future<bool> hasValidSession() async {
    final sessionString = await _storage.read(key: _sessionKey);
    if (sessionString == null) return false;

    try {
      final session = Session.fromJson(jsonDecode(sessionString));
      final expiresAt = session?.expiresAt;

      if (expiresAt != null && (expiresAt * 1000) > DateTime.now().millisecondsSinceEpoch) {
        return true;
      }
    } catch (e) {
      return false;
    }
    return false;
  }

  /// Restore session without credentials (after biometric auth)
  Future<bool> restoreSession() async {
    final sessionString = await _storage.read(key: _sessionKey);
    if (sessionString == null) return false;

    try {
      final session = Session.fromJson(jsonDecode(sessionString));
      final expiresAt = session?.expiresAt;

      if (expiresAt != null && (expiresAt * 1000) > DateTime.now().millisecondsSinceEpoch) {
        final response = await _auth.recoverSession(sessionString);
        if (response.session != null) {
          _isAuthenticated = true;
          // --- FIX: Fetch profile on session restore ---
          await getCustomerProfile();
          notifyListeners();
          return true;
        }
      }
    } catch (e) {
      return false;
    }
    return false;
  }

  Future<String?> getAuthToken() async {
    final sessionString = await _storage.read(key: _sessionKey);
    if (sessionString == null) return null;

    final session = Session.fromJson(jsonDecode(sessionString));
    final expiresAt = session?.expiresAt; // This is in SECONDS

    if (expiresAt == null || (expiresAt * 1000) <= DateTime.now().millisecondsSinceEpoch) {
      // Token is expired, try to refresh
      final response = await _auth.refreshSession();
      if (response.session != null) {
        await _storage.write(key: _sessionKey, value: jsonEncode(response.session!.toJson()));
        return response.session!.accessToken;
      }
      return null; // Refresh failed
    }

    return session?.accessToken;
  }

  // --- ALL NEW FUNCTIONS BELOW (Added) ---

  Future<void> getCustomerProfile() async {
    final user = _auth.currentUser;
    if (user == null) return;

    _isLoadingProfile = true;
    notifyListeners();

    try {
      // Try to get profile from Supabase customers table
      final response = await Supabase.instance.client
          .from('customers')
          .select()
          .eq('id', user.id)
          .single();

      if (response != null) {
        _customer = Customer.fromJson(response);
      } else {
        // If profile doesn't exist, create one from auth user data
        _customer = Customer(
          id: user.id,
          name: user.userMetadata?['name'] ?? 'User',
          email: user.email ?? '',
          phone: user.phone,
          avatarUrl: null,
        );
      }
    } catch (e) {
      print('Error getCustomerProfile: $e');
      // Fallback: use auth user data
      final user = _auth.currentUser;
      if (user != null) {
        _customer = Customer(
          id: user.id,
          name: user.userMetadata?['name'] ?? 'User',
          email: user.email ?? '',
          phone: user.phone,
          avatarUrl: null,
        );
      }
    }
    _isLoadingProfile = false;
    notifyListeners();
  }

  Future<String?> updateCustomerProfile(String name, String phone) async {
    final user = _auth.currentUser;
    if (user == null || _customer == null) return "Not authenticated";

    try {
      // Update profile in Supabase customers table
      final response = await Supabase.instance.client
          .from('customers')
          .update({'name': name, 'phone': phone})
          .eq('id', user.id)
          .select()
          .single();

      if (response != null) {
        _customer = Customer.fromJson(response);
        notifyListeners();
        return null; // Success
      } else {
        return 'Failed to update profile';
      }
    } catch (e) {
      print('Error updating profile: $e');
      return 'Error updating profile: $e';
    }
  }

  Future<String?> uploadProfileImage(File image) async {
    final user = _auth.currentUser;
    if (user == null || _customer == null) return "Not authenticated";

    try {
      final fileExtension = image.path.split('.').last.toLowerCase();
      final filePath = '${_customer!.id}/profile.$fileExtension';

      // 1. Upload image to Supabase Storage
      await _storageClient
          .from('avatars')
          .upload(
        filePath,
        image,
        fileOptions: const FileOptions(cacheControl: '3600', upsert: true),
      );

      // 2. Get the public URL
      final publicUrl = _storageClient
          .from('avatars')
          .getPublicUrl(filePath);

      // 3. Update the 'avatar_url' in our customers table
      final response = await Supabase.instance.client
          .from('customers')
          .update({'avatar_url': publicUrl})
          .eq('id', user.id)
          .select()
          .single();

      if (response != null) {
        _customer = Customer.fromJson(response);
        notifyListeners();
        return null; // Success
      } else {
        return 'Failed to update avatar URL';
      }
    } catch (e) {
      print('Error uploading image: $e');
      return 'Error uploading image: $e';
    }
  }
}