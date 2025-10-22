// lib/providers/reward_provider.dart
import 'package:flutter/material.dart';

class Reward {
  final String id;
  final String title;
  final String business;
  final String qrData;
  Reward({required this.id, required this.title, required this.business, required this.qrData});
}

class RewardProvider with ChangeNotifier {
  // Initially, all rewards are "pending" notifications.
  final List<Reward> _pendingNotifications = [
    Reward(id: '1', title: 'Free Filter Coffee', business: 'at Annapoorna', qrData: 'VOUCH_REWARD_12345'),
    Reward(id: '2', title: '10% Off Pastries', business: 'at The French Door', qrData: 'VOUCH_REWARD_67890'),
    Reward(id: '3', title: 'Free Parking', business: 'at Brookfields Mall', qrData: 'VOUCH_REWARD_ABCDE'),
  ];

  // This list will hold rewards after they are scratched and revealed.
  final List<Reward> _claimedRewards = [];

  List<Reward> get pendingNotifications => _pendingNotifications;
  List<Reward> get claimedRewards => _claimedRewards;

  // This is the core logic: move a reward from pending to claimed.
  void claimNotification(String rewardId) {
    final rewardIndex = _pendingNotifications.indexWhere((r) => r.id == rewardId);
    if (rewardIndex != -1) {
      final reward = _pendingNotifications.removeAt(rewardIndex);
      _claimedRewards.insert(0, reward); // Add to the top of the claimed list
      notifyListeners(); // This tells the UI to update
    }
  }
}