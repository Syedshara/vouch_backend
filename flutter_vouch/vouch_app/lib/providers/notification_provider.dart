import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vouch/app_theme.dart';

// 1. Define the Notification model
class AppNotification {
  final String id;
  final String title;
  final String body;
  final DateTime createdAt;
  bool isRead;

  AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.createdAt,
    this.isRead = false,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'],
      title: json['title'],
      body: json['body'] ?? '',
      createdAt: DateTime.parse(json['created_at']),
      isRead: json['is_read'],
    );
  }
}

// 2. Create the Provider
class NotificationProvider with ChangeNotifier {
  final SupabaseClient _client = Supabase.instance.client;
  final GlobalKey<ScaffoldMessengerState> _messengerKey;

  List<AppNotification> _notifications = [];
  bool _isLoading = false;
  RealtimeChannel? _channel;

  List<AppNotification> get notifications => _notifications;
  bool get isLoading => _isLoading;
  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  NotificationProvider(this._messengerKey);

  // 3. Fetch all old notifications
  Future<void> fetchNotifications() async {
    _isLoading = true;
    notifyListeners();

    final response = await _client
        .from('notifications')
        .select()
        .order('created_at', ascending: false);

    _notifications = response.map((data) => AppNotification.fromJson(data)).toList();
    _isLoading = false;
    notifyListeners();
  }

  // 4. Listen for new notifications in real-time
  void listenForNotifications() {
    _channel?.unsubscribe();

    _channel = _client
        .channel('public:notifications')
        .onPostgresChanges(
      event: PostgresChangeEvent.insert,
      schema: 'public',
      table: 'notifications',
      callback: (payload) {
        final newNotification = AppNotification.fromJson(payload.newRecord);
        _notifications.insert(0, newNotification);
        _showNotificationSnackbar(newNotification);
        notifyListeners();
      },
    )
        .subscribe();
  }

  // 5. Show the snackbar
  void _showNotificationSnackbar(AppNotification notification) {
    _messengerKey.currentState?.showSnackBar(
      SnackBar(
        backgroundColor: AppTheme.surface,
        padding: const EdgeInsets.all(12),
        content: Row(
          children: [
            const Icon(Icons.shield_outlined, color: AppTheme.primary, size: 40),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    notification.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    notification.body,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  // --- MARK ALL AS READ FUNCTION ---
  Future<void> markAllAsRead() async {
    // 1. Find which notifications are unread
    final unreadIds = _notifications
        .where((n) => !n.isRead)
        .map((n) => n.id)
        .toList();

    // 2. If there are none, do nothing
    if (unreadIds.isEmpty) {
      return;
    }

    // 3. Update the app state immediately (Optimistic Update)
    for (var notification in _notifications) {
      if (!notification.isRead) {
        notification.isRead = true;
      }
    }
    notifyListeners();

    // 4. Update the database in the background
    try {
      await _client
          .from('notifications')
          .update({'is_read': true})
          .inFilter('id', unreadIds);
    } catch (e) {
      print("Error marking notifications as read: $e");
      // If this fails, the local state will be out of sync,
      // but it will be corrected on the next app load.
    }
  }
  // --- END MARK ALL AS READ FUNCTION ---

  @override
  void dispose() {
    _channel?.unsubscribe();
    super.dispose();
  }
}