// lib/pages/rewards_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:vouch/providers/reward_provider.dart';
import 'package:vouch/app_theme.dart';
import 'package:vouch/pages/visit_history_page.dart';
import 'package:vouch/components/scratch_card_modal.dart';

class RewardsPage extends StatefulWidget {
  const RewardsPage({super.key});

  @override
  State<RewardsPage> createState() => _RewardsPageState();
}

class _RewardsPageState extends State<RewardsPage>
    with AutomaticKeepAliveClientMixin<RewardsPage> {
  @override
  bool get wantKeepAlive => true;

  int _selectedTab = 0; // 0: Active, 1: Used/Expired
  Set<String> _scratchedRewards = {}; // Track which rewards have been scratched

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<RewardProvider>().fetchRewards();
      }
    });
  }

  // Function to show scratch card on tap (for first time)
  void _showScratchCard(Reward reward) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => ScratchCardModal(reward: reward),
    ).then((_) {
      // Mark this reward as scratched
      setState(() {
        _scratchedRewards.add(reward.id);
      });
    });
  }

  void _showQrDialog(BuildContext context, Reward reward) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width - 32,
            maxHeight: MediaQuery.of(context).size.height * 0.8,
          ),
          child: Card(
            color: AppTheme.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    reward.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primary,
                      fontSize: 18,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Show this QR code at ${reward.business}',
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
                      ],
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
                        const Text(
                          'Reward Details',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Expires:',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey[400],
                              ),
                            ),
                            Text(
                              '30 Dec 2025',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey[300],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Terms:',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey[400],
                              ),
                            ),
                            Text(
                              'Valid once',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey[300],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text(
                      'Close',
                      style: TextStyle(color: AppTheme.primary),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Decide whether to show scratch card or QR code
  void _handleRewardTap(Reward reward) {
    if (_scratchedRewards.contains(reward.id)) {
      // Already scratched, show QR code directly
      _showQrDialog(context, reward);
    } else {
      // First time, show scratch card
      _showScratchCard(reward);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final rewardProvider = context.watch<RewardProvider>();
    final activeRewards = rewardProvider.activeRewards;
    final usedRewards = rewardProvider.usedRewards;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Rewards Wallet'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const VisitHistoryPage(),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Tabs
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
                          'Active (${activeRewards.length})',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: _selectedTab == 0
                                ? AppTheme.primary
                                : Colors.grey[400],
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
                          'Used/Expired (${usedRewards.length})',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: _selectedTab == 1
                                ? AppTheme.primary
                                : Colors.grey[400],
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

          // Body content
          Expanded(
            child: rewardProvider.isLoading &&
                activeRewards.isEmpty &&
                usedRewards.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : rewardProvider.error != null
                ? Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Error: ${rewardProvider.error}',
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        context.read<RewardProvider>().fetchRewards();
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            )
                : _selectedTab == 0
            // Active Tab
                ? activeRewards.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.card_giftcard_outlined,
                    size: 80,
                    color: Colors.grey[700],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No Active Rewards',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Visit a shop to earn a reward!',
                    style: TextStyle(
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            )
                : RefreshIndicator(
              onRefresh: () async {
                await context
                    .read<RewardProvider>()
                    .fetchRewards();
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: activeRewards.length,
                itemBuilder: (context, index) {
                  final reward = activeRewards[index];
                  final isScratched = _scratchedRewards.contains(reward.id);

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      contentPadding:
                      const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      leading: Stack(
                        children: [
                          Icon(
                            isScratched ? Icons.qr_code_2 : Icons.card_giftcard,
                            color: AppTheme.primary,
                            size: 40,
                          ),
                          if (!isScratched)
                            Positioned(
                              top: 0,
                              right: 0,
                              child: Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                        ],
                      ),
                      title: Text(
                        reward.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            reward.business,
                            style: TextStyle(
                              color: Colors.grey[400],
                            ),
                          ),
                          if (!isScratched)
                            const SizedBox(height: 4),
                          if (!isScratched)
                            Text(
                              'Tap to reveal!',
                              style: TextStyle(
                                color: AppTheme.primary,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                        ],
                      ),
                      trailing: const Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                      ),
                      onTap: () => _handleRewardTap(reward),
                    ),
                  );
                },
              ),
            )
            // Used/Expired Tab
                : usedRewards.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    size: 80,
                    color: Colors.grey[700],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No Used/Expired Rewards',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Your reward history will appear here.',
                    style: TextStyle(
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: usedRewards.length,
              itemBuilder: (context, index) {
                final reward = usedRewards[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    contentPadding:
                    const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    leading: Icon(
                      reward.status == 'redeemed'
                          ? Icons.check_circle
                          : Icons.hourglass_disabled,
                      color: Colors.grey[600],
                      size: 40,
                    ),
                    title: Text(
                      reward.title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.grey[500],
                        decoration:
                        TextDecoration.lineThrough,
                      ),
                    ),
                    subtitle: Text(
                      reward.business,
                      style: TextStyle(
                        color: Colors.grey[600],
                      ),
                    ),
                    trailing: Text(
                      reward.status == 'redeemed'
                          ? 'Redeemed'
                          : 'Expired',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
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