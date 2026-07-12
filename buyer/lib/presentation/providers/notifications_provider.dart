import 'package:flutter/material.dart';

import '../../core/services/local_storage_service.dart';
import '../../data/datasources/remote/notifications_remote_data_source.dart';
import '../../domain/entities/notification_model.dart';

/// Buyer notification inbox, backed by GET /buyer/notifications.
///
/// The backend renders each item's title/body but does not persist read state,
/// so read/unread is tracked locally in [LocalStorageService] and overlaid onto
/// the fetched items here.
class NotificationsProvider extends ChangeNotifier {
  final NotificationsRemoteDataSource dataSource;
  final LocalStorageService storage;

  NotificationsProvider({required this.dataSource, required this.storage});

  bool _loaded = false;
  bool _loading = false;
  bool get isLoading => _loading;

  List<NotificationModel> _items = [];
  List<NotificationModel> get items => _items;

  int get unreadCount => _items.where((n) => !n.isRead).length;

  Future<void> ensureLoaded() async {
    if (_loaded || _loading) return;
    await reload();
  }

  Future<void> reload() async {
    _loading = true;
    notifyListeners();
    try {
      final fetched = await dataSource.getNotifications();
      final read = await storage.getReadNotificationIds();
      _items = fetched
          .map((n) => read.contains(n.id) ? n.copyWith(isRead: true) : n)
          .toList(growable: false)
        ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
      _loaded = true;
    } catch (_) {
      // Keep the last list on failure.
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> markRead(String id) async {
    await storage.markNotificationRead(id);
    final idx = _items.indexWhere((n) => n.id == id);
    if (idx < 0 || _items[idx].isRead) return;
    _items = List.of(_items)..[idx] = _items[idx].copyWith(isRead: true);
    notifyListeners();
  }

  Future<void> markAllRead() async {
    final unread = _items.where((n) => !n.isRead).map((n) => n.id);
    await storage.markAllNotificationsRead(unread);
    _items = _items.map((n) => n.copyWith(isRead: true)).toList(growable: false);
    notifyListeners();
  }
}
