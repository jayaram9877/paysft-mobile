import 'package:flutter/foundation.dart';

import '../../data/datasources/remote/broker_assignments_remote_data_source.dart';
import '../../data/datasources/remote/chat_remote_data_source.dart';

/// One row in the broker's Chats list — a client (accepted lead) the broker can
/// message.
class BrokerConversation {
  final String leadId;
  final String buyerName;
  final String subtitle; // project · unit
  final String initials;
  final int unread;

  const BrokerConversation({
    required this.leadId,
    required this.buyerName,
    required this.subtitle,
    required this.initials,
    required this.unread,
  });

  BrokerConversation copyWith({int? unread}) => BrokerConversation(
        leadId: leadId,
        buyerName: buyerName,
        subtitle: subtitle,
        initials: initials,
        unread: unread ?? this.unread,
      );
}

/// The broker's conversations. Each client (an accepted lead) is a thread with
/// that buyer; unread badges come from `/brokers/me/messages/unread-count`.
class ChatListProvider with ChangeNotifier {
  final BrokerAssignmentsRemoteDataSource assignmentsDataSource;
  final ChatRemoteDataSource chatDataSource;

  ChatListProvider({
    required this.assignmentsDataSource,
    required this.chatDataSource,
  });

  List<BrokerConversation> _conversations = [];
  List<BrokerConversation> get conversations => List.unmodifiable(_conversations);

  bool _loading = false;
  bool _loaded = false;
  bool get isLoading => _loading;
  bool get loadedOnce => _loaded;

  int get totalUnread =>
      _conversations.fold<int>(0, (sum, c) => sum + c.unread);

  Future<void> ensureLoaded() async {
    if (_loaded || _loading) return;
    await load();
  }

  Future<void> load() async {
    _loading = true;
    notifyListeners();
    try {
      final clients = await assignmentsDataSource.listClients();
      final unread = await chatDataSource.unreadPerLead();
      _conversations = clients
          .where((c) => c.leadId.isNotEmpty)
          .map((c) => BrokerConversation(
                leadId: c.leadId,
                buyerName: c.buyerFullName,
                subtitle: '${c.projectName} · ${c.unitLabel}',
                initials: c.initials,
                unread: unread[c.leadId] ?? 0,
              ))
          .toList();
      // Unread first, then by name.
      _conversations.sort((a, b) {
        if (a.unread > 0 && b.unread == 0) return -1;
        if (a.unread == 0 && b.unread > 0) return 1;
        return a.buyerName.compareTo(b.buyerName);
      });
      _loaded = true;
    } catch (_) {
      // Keep any previous list.
    }
    _loading = false;
    notifyListeners();
  }

  /// Clears a conversation's badge the moment it's opened (the thread marks it
  /// read server-side; this keeps the list in sync immediately).
  void markConversationRead(String leadId) {
    final i = _conversations.indexWhere((c) => c.leadId == leadId);
    if (i < 0 || _conversations[i].unread == 0) return;
    _conversations[i] = _conversations[i].copyWith(unread: 0);
    notifyListeners();
  }
}
