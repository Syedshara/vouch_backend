// lib/providers/reward_provider.dart
import 'package:flutter/material.dart';
import 'package:vouch/api_config.dart';
import 'package:vouch/services/auth_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Reward {
  final String id;
  final String title;
  final String business;
  final String qrData; // This will be the unique_token from the server
  final String status; // 'active', 'redeemed', 'expired'
  final DateTime createdAt; // <-- ADDED THIS

  Reward({
    required this.id,
    required this.title,
    required this.business,
    required this.qrData,
    required this.status,
    required this.createdAt, // <-- ADDED THIS
  });

  factory Reward.fromJson(Map<String, dynamic> json) {
    return Reward(
      id: json['id'],
      title: json['title'] ?? 'Unnamed Reward',
      business: json['business'] ?? 'Unknown Business',
      qrData: json['qrData'],
      status: json['status'],
      createdAt: DateTime.parse(json['createdAt']), // <-- ADDED THIS
    );
  }
}

class RewardProvider with ChangeNotifier {
  final AuthService _authService;
  RewardProvider(this._authService); // AuthService is now required

  List<Reward> _allRewards = [];
  bool _isLoading = false;
  String? _error;

  // --- NEW: This list holds new rewards to be scratched ---
  final List<Reward> _pendingScratchCards = [];

  // Public getters
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<Reward> get activeRewards =>
      _allRewards.where((r) => r.status == 'active').toList();
  List<Reward> get usedRewards =>
      _allRewards.where((r) => r.status != 'active').toList();

  // --- This is no longer used by RewardsPage but is safe to keep ---
  List<Reward> get pendingNotifications => [];
  List<Reward> get claimedRewards => activeRewards;

  // --- NEW: Helper to get the next scratch card ---
  Reward? getNextScratchCard() {
    if (_pendingScratchCards.isEmpty) return null;
    return _pendingScratchCards.removeAt(0);
  }

  // --- UPDATED: Fetch Rewards logic ---
  Future<void> fetchRewards() async {
    if (_isLoading) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    final token = await _authService.getAuthToken();
    if (token == null) {
      _error = "You are not logged in.";
      _isLoading = false;
      notifyListeners();
      return;
    }

    // --- Store old reward IDs to find new ones ---
    final oldRewardIds = _allRewards.map((r) => r.id).toSet();

    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/my-rewards'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        // Update the main list
        _allRewards = data.map((json) => Reward.fromJson(json)).toList();

        // --- Find new rewards ---
        final newRewards = _allRewards.where((r) {
          // A "new" reward is one that:
          // 1. Is not in the old list.
          // 2. Is 'active' (not redeemed/expired).
          return !oldRewardIds.contains(r.id) && r.status == 'active';
        }).toList();

        // Add them to the pending scratch card queue
        _pendingScratchCards.addAll(newRewards);

      } else {
        final data = jsonDecode(response.body);
        _error = data['error'] ?? 'Failed to load rewards.';
      }
    } catch (e) {
      print("Error fetching rewards: $e");
      _error = "An error occurred. Please try again.";
    }

    _isLoading = false;
    notifyListeners();
  }
}