import 'package:flutter/foundation.dart';
import '../../domain/entities/message.dart';

enum ChatSortOption { unreadFirst, readFirst, orderByName }

class ChatListProvider with ChangeNotifier {
  List<ChatContact> _allChats = [];
  List<ChatContact> _filteredChats = [];
  String _searchQuery = '';
  ChatSortOption _sortOption = ChatSortOption.unreadFirst;

  ChatListProvider({List<ChatContact>? initialChats}) {
    _allChats = initialChats ?? [];
    _filteredChats = List.from(_allChats);
    _applySorting();
  }

  List<ChatContact> get chats => _filteredChats;
  List<ChatContact> get allChats => List.unmodifiable(_allChats);
  String get searchQuery => _searchQuery;
  ChatSortOption get sortOption => _sortOption;

  void setChats(List<ChatContact> chats) {
    _allChats = chats;
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
        final messageMatch = chat.lastMessage?.toLowerCase().contains(_searchQuery) ?? false;
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
          if (a.lastMessageTimestamp != null && b.lastMessageTimestamp != null) {
            return b.lastMessageTimestamp!.compareTo(a.lastMessageTimestamp!);
          }
          if (a.lastMessageTimestamp != null) return -1;
          if (b.lastMessageTimestamp != null) return 1;
          return 0;
        });
        break;
      case ChatSortOption.readFirst:
        _filteredChats.sort((a, b) {
          if (a.unreadCount == 0 && b.unreadCount > 0) return -1;
          if (a.unreadCount > 0 && b.unreadCount == 0) return 1;
          if (a.lastMessageTimestamp != null && b.lastMessageTimestamp != null) {
            return b.lastMessageTimestamp!.compareTo(a.lastMessageTimestamp!);
          }
          if (a.lastMessageTimestamp != null) return -1;
          if (b.lastMessageTimestamp != null) return 1;
          return 0;
        });
        break;
      case ChatSortOption.orderByName:
        _filteredChats.sort((a, b) => a.name.compareTo(b.name));
        break;
    }
  }
}
