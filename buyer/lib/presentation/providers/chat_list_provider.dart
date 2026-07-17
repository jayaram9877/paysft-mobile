import 'package:flutter/foundation.dart';
import '../../domain/entities/message.dart';
import '../../data/datasources/remote/chat_remote_data_source.dart';
import '../../data/datasources/remote/lead_remote_data_source.dart';

enum ChatSortOption { unreadFirst, readFirst, orderByName }

/// The buyer's chat conversations. Each conversation is a lead the buyer is
/// interested in; messaging is with the broker aligned to that lead. Titles use
/// the property (the list has no counterpart name — that appears in the thread).
class ChatListProvider with ChangeNotifier {
  final ChatRemoteDataSource chatDataSource;
  final LeadRemoteDataSource leadDataSource;

  ChatListProvider({
    required this.chatDataSource,
    required this.leadDataSource,
  });

  List<ChatContact> _allChats = [];
  List<ChatContact> _filteredChats = [];
  String _searchQuery = '';
  ChatSortOption _sortOption = ChatSortOption.unreadFirst;
  bool _loading = false;
  bool _loaded = false;

  List<ChatContact> get chats => _filteredChats;
  List<ChatContact> get allChats => List.unmodifiable(_allChats);
  String get searchQuery => _searchQuery;
  ChatSortOption get sortOption => _sortOption;
  bool get isLoading => _loading;

  Future<void> ensureLoaded() async {
    if (_loaded || _loading) return;
    await load();
  }

  Future<void> load() async {
    _loading = true;
    notifyListeners();
    try {
      final rows = await leadDataSource.getActiveLeadRows();
      final unread = await chatDataSource.unreadPerLead();
      _allChats = rows
          .map((r) {
            final id = '${r['id'] ?? ''}';
            final title =
                '${r['project_name'] ?? r['unit_title'] ?? 'Conversation'}';
            final img = '${r['cover_image_url'] ?? ''}';
            final unit = '${r['unit_title'] ?? r['unit_number'] ?? ''}';
            return ChatContact(
              id: id,
              name: title,
              profileImageUrl: img.isEmpty ? null : img,
              unreadCount: unread[id] ?? 0,
              lastMessage: unit.isEmpty ? null : unit,
            );
          })
          .where((c) => c.id.isNotEmpty)
          .toList();
      _loaded = true;
    } catch (_) {
      // Keep any previous list on failure.
    }
    _loading = false;
    _applyFilters();
    notifyListeners();
  }

  /// Clears a conversation's unread badge as soon as it's opened (the thread
  /// marks it read server-side; this keeps the list in sync immediately).
  void markConversationRead(String leadId) {
    final i = _allChats.indexWhere((c) => c.id == leadId);
    if (i < 0 || _allChats[i].unreadCount == 0) return;
    _allChats[i] = _allChats[i].copyWith(unreadCount: 0);
    _applyFilters();
    notifyListeners();
  }

  void performSearch(String query) {
    _searchQuery = query.toLowerCase().trim();
    _applyFilters();
    notifyListeners();
  }

  void setSortOption(ChatSortOption option) {
    _sortOption = option;
    _applySorting();
    notifyListeners();
  }

  void _applyFilters() {
    if (_searchQuery.isEmpty) {
      _filteredChats = List.from(_allChats);
    } else {
      _filteredChats = _allChats.where((chat) {
        final nameMatch = chat.name.toLowerCase().contains(_searchQuery);
        final messageMatch =
            chat.lastMessage?.toLowerCase().contains(_searchQuery) ?? false;
        return nameMatch || messageMatch;
      }).toList();
    }
    _applySorting();
  }

  void _applySorting() {
    switch (_sortOption) {
      case ChatSortOption.unreadFirst:
        _filteredChats.sort((a, b) {
          if (a.unreadCount > 0 && b.unreadCount == 0) return -1;
          if (a.unreadCount == 0 && b.unreadCount > 0) return 1;
          return a.name.compareTo(b.name);
        });
        break;
      case ChatSortOption.readFirst:
        _filteredChats.sort((a, b) {
          if (a.unreadCount == 0 && b.unreadCount > 0) return -1;
          if (a.unreadCount > 0 && b.unreadCount == 0) return 1;
          return a.name.compareTo(b.name);
        });
        break;
      case ChatSortOption.orderByName:
        _filteredChats.sort((a, b) => a.name.compareTo(b.name));
        break;
    }
  }
}
