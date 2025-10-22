// lib/pages/notifications_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vouch_app/providers/reward_provider.dart';
import 'package:vouch_app/components/scratch_card_modal.dart';
import 'package:vouch_app/app_theme.dart';

// Converted to a StatefulWidget to preserve state
class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

// Added AutomaticKeepAliveClientMixin to preserve state
class _NotificationsPageState extends State<NotificationsPage> with AutomaticKeepAliveClientMixin<NotificationsPage> {
  // This ensures the page state is kept alive
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    // This is required by the AutomaticKeepAliveClientMixin
    super.build(context);

    // Listen to changes in our RewardProvider
    final rewardProvider = context.watch<RewardProvider>();
    final notifications = rewardProvider.pendingNotifications;

    return Scaffold(
      appBar: AppBar(title: const Text('Inbox')),
      body: notifications.isEmpty
          ? const Center(
        child: Text(
          'No new rewards yet.',
          style: TextStyle(color: Colors.grey),
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final notification = notifications[index];
          return Card(
            child: ListTile(
              leading: const Icon(Icons.card_giftcard, color: AppTheme.primary),
              title: const Text('You\'ve received a new reward!', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text('Click to reveal your offer'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                // Open the scratch card modal when tapped
                showDialog(
                  context: context,
                  builder: (_) => ScratchCardModal(reward: notification),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
