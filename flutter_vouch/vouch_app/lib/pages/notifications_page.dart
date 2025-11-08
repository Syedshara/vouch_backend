import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vouch/providers/notification_provider.dart';
import 'package:vouch/app_theme.dart';
import 'package:timeago/timeago.dart' as timeago;

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage>
    with AutomaticKeepAliveClientMixin<NotificationsPage> {

  @override
  bool get wantKeepAlive => true;

  // --- THIS IS THE NEW CODE ---
  @override
  void initState() {
    super.initState();
    // When this page loads, call the provider function
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<NotificationProvider>().markAllAsRead();
      }
    });
  }
  // --- END NEW CODE ---

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final notificationProvider = context.watch<NotificationProvider>();
    final notifications = notificationProvider.notifications;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inbox'),
        actions: [
          // This will now update and disappear
          if (notificationProvider.unreadCount > 0)
            Center(
              child: Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: Text(
                  '${notificationProvider.unreadCount} New',
                  style: const TextStyle(color: AppTheme.primary),
                ),
              ),
            ),
        ],
      ),
      body: notificationProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : notifications.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.notifications_off_outlined, size: 80, color: Colors.grey[700]),
            const SizedBox(height: 16),
            const Text(
              'No notifications yet',
              style: TextStyle(color: Colors.grey, fontSize: 18),
            ),
          ],
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final notification = notifications[index];
          return Card(
            // This color will change from purple-tint to normal
            color: notification.isRead
                ? AppTheme.surface
                : AppTheme.primary.withOpacity(0.1),
            child: ListTile(
              leading: const Icon(Icons.shield_outlined, color: AppTheme.primary),
              title: Text(
                notification.title,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(notification.body),
              trailing: Text(
                timeago.format(notification.createdAt),
                style: TextStyle(color: Colors.grey[500], fontSize: 12),
              ),
              onTap: () {
                // You can leave this tap handler for individual actions later
              },
            ),
          );
        },
      ),
    );
  }
}