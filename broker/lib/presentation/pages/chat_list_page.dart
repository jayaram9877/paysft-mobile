import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/di/injection_container.dart';
import '../providers/chat_list_provider.dart';
import '../providers/chat_provider.dart';
import 'chat_page.dart';

/// The broker's Chats tab — one conversation per client (accepted lead).
class ChatListPage extends StatefulWidget {
  const ChatListPage({super.key});

  @override
  State<ChatListPage> createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<ChatListProvider>().ensureLoaded();
    });
  }

  void _open(BuildContext context, BrokerConversation c) {
    // Opening the thread reads it — drop the badge right away.
    context.read<ChatListProvider>().markConversationRead(c.leadId);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider(
          create: (_) => ChatProvider(dataSource: sl(), leadId: c.leadId),
          child: ChatPage(buyerName: c.buyerName, subtitle: c.subtitle),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ChatListProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: AppColors.backgroundWhite,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'Chats',
          style: TextStyle(
            color: Color(0xFF1D2939),
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: false,
      ),
      body: provider.isLoading && !provider.loadedOnce
          ? const Center(child: CircularProgressIndicator())
          : provider.conversations.isEmpty
              ? _empty()
              : RefreshIndicator(
                  onRefresh: () => context.read<ChatListProvider>().load(),
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: provider.conversations.length,
                    separatorBuilder: (_, __) => const Divider(
                        height: 1, color: AppColors.borderGrayLight),
                    itemBuilder: (context, i) =>
                        _tile(context, provider.conversations[i]),
                  ),
                ),
    );
  }

  Widget _empty() => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.forum_outlined, size: 48, color: AppColors.textGrayMedium),
              SizedBox(height: 12),
              Text(
                'No conversations yet.\nAccept a lead to start chatting with a client.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textGray70, fontSize: 14),
              ),
            ],
          ),
        ),
      );

  Widget _tile(BuildContext context, BrokerConversation c) {
    return InkWell(
      onTap: () => _open(context, c),
      child: Container(
        color: AppColors.backgroundWhite,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: AppColors.backgroundBlueSelectedVeryLight,
                shape: BoxShape.circle,
              ),
              child: Text(
                c.initials,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.bluePrimary,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    c.buyerName,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF101828),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    c.subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textGray70,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (c.unread > 0) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.bluePrimary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  c.unread > 99 ? '99+' : '${c.unread}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
            const SizedBox(width: 6),
            const Icon(Icons.chevron_right,
                size: 18, color: AppColors.textGrayMedium),
          ],
        ),
      ),
    );
  }
}
