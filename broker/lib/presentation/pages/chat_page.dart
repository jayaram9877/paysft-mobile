import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../data/datasources/remote/chat_remote_data_source.dart';
import '../providers/chat_provider.dart';

/// Broker↔buyer message thread for one lead.
class ChatPage extends StatefulWidget {
  final String buyerName;
  final String subtitle;

  const ChatPage({super.key, required this.buyerName, required this.subtitle});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _input = TextEditingController();
  final ScrollController _scroll = ScrollController();
  int _lastCount = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<ChatProvider>().load().then((_) => _toBottom());
    });
  }

  @override
  void dispose() {
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _toBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients) return;
      _scroll.animateTo(
        _scroll.position.maxScrollExtent,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    });
  }

  Future<void> _send() async {
    final text = _input.text.trim();
    if (text.isEmpty) return;
    _input.clear();
    await context.read<ChatProvider>().send(text);
    _toBottom();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ChatProvider>();
    final messages = provider.messages;

    // Auto-scroll when new messages arrive (e.g. from polling).
    if (messages.length != _lastCount) {
      _lastCount = messages.length;
      _toBottom();
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: AppColors.backgroundWhite,
        elevation: 0.5,
        foregroundColor: AppColors.textDark,
        titleSpacing: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              provider.counterpartName?.isNotEmpty == true
                  ? provider.counterpartName!
                  : widget.buyerName,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1D2939),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              widget.subtitle,
              style: const TextStyle(fontSize: 11, color: AppColors.textGray70),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: provider.isLoading && messages.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : messages.isEmpty
                    ? _empty(provider.errorMessage)
                    : ListView.builder(
                        controller: _scroll,
                        padding: const EdgeInsets.fromLTRB(12, 16, 12, 12),
                        itemCount: messages.length,
                        itemBuilder: (_, i) => _Bubble(message: messages[i]),
                      ),
          ),
          _inputBar(provider.isSending),
        ],
      ),
    );
  }

  Widget _empty(String? error) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.forum_outlined,
                  size: 44, color: AppColors.textGrayMedium),
              const SizedBox(height: 12),
              Text(
                error ?? 'No messages yet.\nSay hello to your client.',
                textAlign: TextAlign.center,
                style:
                    const TextStyle(color: AppColors.textGray70, fontSize: 14),
              ),
            ],
          ),
        ),
      );

  Widget _inputBar(bool sending) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
        decoration: const BoxDecoration(
          color: AppColors.backgroundWhite,
          border: Border(top: BorderSide(color: AppColors.borderGrayLight)),
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _input,
                minLines: 1,
                maxLines: 4,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _send(),
                decoration: InputDecoration(
                  hintText: 'Message…',
                  hintStyle: const TextStyle(color: AppColors.textGrayMedium),
                  filled: true,
                  fillColor: const Color(0xFFF4F6FB),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: sending ? null : _send,
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: sending
                      ? AppColors.bluePrimary.withOpacity(0.5)
                      : AppColors.bluePrimary,
                ),
                child: const Icon(Icons.send_rounded,
                    color: Colors.white, size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  final ChatMessageModel message;
  const _Bubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final mine = message.mine;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment:
            mine ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: mine ? AppColors.bluePrimary : AppColors.backgroundWhite,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(mine ? 16 : 4),
                  bottomRight: Radius.circular(mine ? 4 : 16),
                ),
                border:
                    mine ? null : Border.all(color: AppColors.borderGrayLight),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.body,
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.35,
                      color: mine ? Colors.white : AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _time(message.createdAt),
                    style: TextStyle(
                      fontSize: 10,
                      color: mine ? Colors.white70 : AppColors.textGray70,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _time(DateTime dt) {
    final l = dt.toLocal();
    final h = l.hour % 12 == 0 ? 12 : l.hour % 12;
    final m = l.minute.toString().padLeft(2, '0');
    return '$h:$m ${l.hour < 12 ? 'AM' : 'PM'}';
  }
}
