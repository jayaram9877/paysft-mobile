import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'chat_page.dart';
import '../../domain/entities/message.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_string_constants.dart';
import '../../core/theme/theme_manager.dart';
import '../providers/chat_provider.dart';
import '../providers/chat_list_provider.dart';
import '../widgets/meetings/meetings_view.dart';
import '../../core/di/injection_container.dart' as di;

class ChatListPage extends StatefulWidget {
  const ChatListPage({super.key});

  @override
  State<ChatListPage> createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearchMode = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _toggleSearchMode(ChatListProvider? provider) {
    setState(() {
      _isSearchMode = !_isSearchMode;
      if (!_isSearchMode) {
        _searchController.clear();
        provider?.performSearch('');
      } else {
        // Focus search field after a frame when entering search mode
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            FocusScope.of(context).requestFocus(FocusNode());
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => di.sl<ChatListProvider>()..load(),
      child: DefaultTabController(
        length: 2,
        child: Consumer<ChatListProvider>(
          builder: (context, provider, child) => Scaffold(
            backgroundColor: AppColors.backgroundWhite,
            appBar: _buildAppBar(context, provider),
            body: TabBarView(
              children: [
                _buildChatsBody(),
                const MeetingsView(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChatsBody() {
    return Consumer<ChatListProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading && provider.allChats.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        // Check if we have any chats at all (before filtering)
        final hasAnyChats = provider.allChats.isNotEmpty;

        if (!hasAnyChats && provider.searchQuery.isEmpty) {
          return _buildEmptyState();
        }

        return provider.chats.isEmpty && provider.searchQuery.isNotEmpty
            ? _buildNoSearchResults()
            : ListView.builder(
                itemCount: provider.chats.length,
                itemBuilder: (context, index) {
                  final contact = provider.chats[index];
                  return _buildChatItem(context, contact);
                },
              );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, ChatListProvider provider) {
    final themeManager = ThemeManager();
    return AppBar(
      backgroundColor: AppColors.backgroundWhite,
      elevation: 0,
      leading: _isSearchMode
          ? IconButton(
              icon: const Icon(Icons.arrow_back, color: AppColors.textPrimaryDark),
              onPressed: () => _toggleSearchMode(provider),
            )
          : null,
      title: _isSearchMode
          ? TextField(
              controller: _searchController,
              autofocus: true,
              onChanged: (value) {
                provider.performSearch(value);
              },
              style: themeManager.titleMediumStyle.copyWith(color: AppColors.textPrimaryDark),
              decoration: InputDecoration(
                hintText: AppStrings.search,
                hintStyle: themeManager.titleMediumStyle.copyWith(color: AppColors.textSecondaryGray),
                border: InputBorder.none,
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: AppColors.textSecondaryGray),
                        onPressed: () {
                          _searchController.clear();
                          provider.performSearch('');
                        },
                      )
                    : null,
              ),
            )
          : Align(
              alignment: Alignment.centerLeft,
              child: Text(
                AppStrings.messages,
                style: themeManager.titleMediumStyle.copyWith(color: AppColors.textPrimaryDark),
              ),
            ),
      bottom: const TabBar(
        labelColor: AppColors.primaryBlue,
        unselectedLabelColor: AppColors.textSecondaryGray,
        indicatorColor: AppColors.primaryBlue,
        indicatorWeight: 3,
        labelStyle: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        unselectedLabelStyle: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        tabs: [
          Tab(text: 'Chats'),
          Tab(text: 'Meetings'),
        ],
      ),
      actions: _isSearchMode
          ? null
          : [
              IconButton(
                icon: SvgPicture.asset(
                  "assets/images/search.svg",
                  colorFilter: const ColorFilter.mode(AppColors.textDark, BlendMode.srcIn),
                ),
                onPressed: () => _toggleSearchMode(provider),
              ),
              IconButton(
                icon: const Icon(Icons.more_vert, color: AppColors.textIconGray, size: 22),
                color: AppColors.textDark,
                onPressed: () => _showSortOptions(context, provider),
              ),
              const SizedBox(width: 8),
            ],
    );
  }

  Widget _buildEmptyState() {
    final themeManager = ThemeManager();
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset("assets/images/no_chats.svg", width: 120, height: 120),
          const SizedBox(height: 24),
          Text(
            AppStrings.noMessages,
            textAlign: TextAlign.center,
            style: themeManager.headingStyle.copyWith(color: AppColors.textDark, height: 26 / 21),
          ),
          const SizedBox(height: 8),
          Text(
            AppStrings.noActiveChats,
            textAlign: TextAlign.center,
            style: themeManager.bodyStyle.copyWith(color: AppColors.textGrayMedium, height: 18 / 15),
          ),
        ],
      ),
    );
  }

  Widget _buildNoSearchResults() {
    final themeManager = ThemeManager();
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset("assets/images/search_no_results.svg", width: 120, height: 120),
          const SizedBox(height: 24),
          Text(
            AppStrings.noResultsFound,
            style: themeManager.titleMediumStyle.copyWith(color: AppColors.textPrimaryDark),
          ),
        ],
      ),
    );
  }

  Widget _buildChatItem(BuildContext context, ChatContact contact) {
    return InkWell(
      onTap: () {
        // Opening the thread reads it — drop the badge right away.
        context.read<ChatListProvider>().markConversationRead(contact.id);
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ChangeNotifierProvider(
              create: (_) => ChatProvider(dataSource: di.sl(), contact: contact),
              child: ChatPage(contact: contact),
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.borderDivider, width: 0.5)),
        ),
        child: Row(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: AppColors.avatarBackground,
                  backgroundImage: contact.profileImageUrl != null ? NetworkImage(contact.profileImageUrl!) : null,
                  child: contact.profileImageUrl == null
                      ? Text(
                          contact.name[0].toUpperCase(),
                          style: ThemeManager().titleStyle.copyWith(
                            color: AppColors.textPrimaryDark,
                            fontSize: 24,
                            fontWeight: FontWeight.w500,
                          ),
                        )
                      : null,
                ),
                if (contact.isOnline)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: AppColors.statusOnline,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.backgroundWhite, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          contact.name,
                          style: ThemeManager().bodyMediumStyle.copyWith(
                            color: AppColors.textPrimaryDark,
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        _getLastMessageTime(contact),
                        style: ThemeManager().bodySmallStyle.copyWith(color: AppColors.textSecondaryGray),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          contact.lastMessage ?? AppStrings.noMessagesYet,
                          style: ThemeManager().bodySmallStyle.copyWith(color: AppColors.textSecondaryGray),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                      if (contact.unreadCount > 0) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.primaryBlue,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            contact.unreadCount > 99 ? '99+' : contact.unreadCount.toString(),
                            textAlign: TextAlign.center,
                            style: ThemeManager().labelStyle.copyWith(
                              color: AppColors.textWhite,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              height: 1.0,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getLastMessageTime(ChatContact contact) {
    if (contact.lastMessageTimestamp == null) {
      return '';
    }

    final now = DateTime.now();
    final messageTime = contact.lastMessageTimestamp!;
    final difference = now.difference(messageTime);

    if (difference.inMinutes < 1) {
      return AppStrings.justNow;
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}${AppStrings.minutesAgo}';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}${AppStrings.hoursAgo}';
    } else if (difference.inDays == 1) {
      return AppStrings.chatYesterday;
    } else if (difference.inDays < 7) {
      return '${difference.inDays}${AppStrings.daysAgo}';
    } else {
      return '${messageTime.day}/${messageTime.month}/${messageTime.year}';
    }
  }

  void _showSortOptions(BuildContext context, ChatListProvider provider) {
    final themeManager = ThemeManager();
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.backgroundWhite.withOpacity(0),
      isScrollControlled: false,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: AppColors.backgroundWhite,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(color: AppColors.borderDivider, borderRadius: BorderRadius.circular(2)),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  AppStrings.sortOptions,
                  style: themeManager.titleMediumStyle.copyWith(color: AppColors.textPrimaryDark),
                ),
              ),
              _buildSortOption(
                context,
                AppStrings.unreadFirst,
                ChatSortOption.unreadFirst,
                provider.sortOption == ChatSortOption.unreadFirst,
                provider,
              ),
              _buildSortOption(
                context,
                AppStrings.readChatsFirst,
                ChatSortOption.readFirst,
                provider.sortOption == ChatSortOption.readFirst,
                provider,
              ),
              _buildSortOption(
                context,
                AppStrings.orderByName,
                ChatSortOption.orderByName,
                provider.sortOption == ChatSortOption.orderByName,
                provider,
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSortOption(
    BuildContext context,
    String title,
    ChatSortOption option,
    bool isSelected,
    ChatListProvider provider,
  ) {
    final themeManager = ThemeManager();
    return InkWell(
      onTap: () {
        provider.setSortOption(option);
        Navigator.pop(context);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: themeManager.bodyMediumStyle.copyWith(
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected ? AppColors.primaryBlue : AppColors.textPrimaryDark,
                ),
              ),
            ),
            if (isSelected) const Icon(Icons.check, color: AppColors.primaryBlue),
          ],
        ),
      ),
    );
  }
}
