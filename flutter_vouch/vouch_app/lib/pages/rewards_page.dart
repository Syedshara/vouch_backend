import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:vouch_app/providers/reward_provider.dart';
import 'package:vouch_app/app_theme.dart';
import 'package:vouch_app/pages/visit_history_page.dart';

class RewardsPage extends StatefulWidget {
  const RewardsPage({super.key});

  @override
  State<RewardsPage> createState() => _RewardsPageState();
}

// Added AutomaticKeepAliveClientMixin to preserve state
class _RewardsPageState extends State<RewardsPage> with AutomaticKeepAliveClientMixin<RewardsPage> {
  // This ensures the page state is kept alive
  @override
  bool get wantKeepAlive => true;

  int _selectedTab = 0; // 0: Active, 1: Used/Expired

  void _showQrDialog(BuildContext context, Reward reward) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Center(
            child: Text(
              reward.title,
              style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primary),
            )
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Show this QR code ${reward.business}',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[300]),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primary.withOpacity(0.3),
                          blurRadius: 20,
                          spreadRadius: 4,
                        )
                      ]
                  ),
                  child: QrImageView(
                    data: reward.qrData,
                    version: QrVersions.auto,
                    size: 200.0,
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Reward Details', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Expires:', style: TextStyle(fontSize: 11, color: Colors.grey[400])),
                          Text('30 Dec 2025', style: TextStyle(fontSize: 11, color: Colors.grey[300])),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Terms:', style: TextStyle(fontSize: 11, color: Colors.grey[400])),
                          Text('Valid once', style: TextStyle(fontSize: 11, color: Colors.grey[300])),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close', style: TextStyle(color: AppTheme.primary)),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // This is required by the AutomaticKeepAliveClientMixin
    super.build(context);

    final rewardProvider = context.watch<RewardProvider>();
    final claimedRewards = rewardProvider.claimedRewards;
    final pendingRewards = rewardProvider.pendingNotifications;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Rewards Wallet'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const VisitHistoryPage()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedTab = 0),
                    child: Column(
                      children: [
                        Text(
                          'Active (${claimedRewards.length})',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: _selectedTab == 0 ? AppTheme.primary : Colors.grey[400],
                          ),
                        ),
                        const SizedBox(height: 8),
                        if (_selectedTab == 0)
                          Container(
                            height: 2,
                            decoration: BoxDecoration(
                              color: AppTheme.primary,
                              borderRadius: BorderRadius.circular(1),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedTab = 1),
                    child: Column(
                      children: [
                        Text(
                          'Used/Expired (${pendingRewards.length})',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: _selectedTab == 1 ? AppTheme.primary : Colors.grey[400],
                          ),
                        ),
                        const SizedBox(height: 8),
                        if (_selectedTab == 1)
                          Container(
                            height: 2,
                            decoration: BoxDecoration(
                              color: AppTheme.primary,
                              borderRadius: BorderRadius.circular(1),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _selectedTab == 0
                ? claimedRewards.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.card_giftcard_outlined, size: 80, color: Colors.grey[700]),
                  const SizedBox(height: 16),
                  const Text('No Active Rewards', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text('Claimed rewards will appear here.', style: TextStyle(color: Colors.grey[500])),
                ],
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: claimedRewards.length,
              itemBuilder: (context, index) {
                final reward = claimedRewards[index];
                return Card(
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    leading: const Icon(Icons.qr_code_2, color: AppTheme.primary, size: 40),
                    title: Text(reward.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    subtitle: Text(reward.business, style: TextStyle(color: Colors.grey[400])),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () => _showQrDialog(context, reward),
                  ),
                );
              },
            )
                : pendingRewards.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle_outline, size: 80, color: Colors.grey[700]),
                  const SizedBox(height: 16),
                  const Text('No Used/Expired Rewards', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text('Your reward history will appear here.', style: TextStyle(color: Colors.grey[500])),
                ],
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: pendingRewards.length,
              itemBuilder: (context, index) {
                final reward = pendingRewards[index];
                return Card(
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    leading: Icon(Icons.qr_code_2, color: Colors.grey[600], size: 40),
                    title: Text(reward.title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.grey[500])),
                    subtitle: Text(reward.business, style: TextStyle(color: Colors.grey[600])),
                    trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[600]),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
