import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../data/datasources/remote/chat_remote_data_source.dart';

/// A single broker↔buyer chat thread for a lead, backed by
/// `/brokers/me/leads/{lead_id}/messages`.
class ChatProvider with ChangeNotifier {
  final ChatRemoteDataSource dataSource;
  final String leadId;

  /// The backend has no push/websocket, so an open thread polls for replies.
  static const Duration _pollInterval = Duration(seconds: 5);

  ChatProvider({required this.dataSource, required this.leadId});

  final List<ChatMessageModel> _messages = [];
  List<ChatMessageModel> get messages => List.unmodifiable(_messages);

  bool _loading = false;
  bool _sending = false;
  String? _counterpartName;
  String? _error;
  Timer? _poll;

  bool get isLoading => _loading;
  bool get isSending => _sending;
  String? get counterpartName => _counterpartName;
  String? get errorMessage => _error;

  Future<void> load() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final thread = await dataSource.getThread(leadId);
      _counterpartName = thread.counterpartName;
      _messages
        ..clear()
        ..addAll(thread.messages);
    } catch (e) {
      _error = 'Could not load messages.';
    } finally {
      _loading = false;
      notifyListeners();
    }
    dataSource.markRead(leadId);
    _startPolling();
  }

  void _startPolling() {
    _poll?.cancel();
    _poll = Timer.periodic(_pollInterval, (_) => _refresh());
  }

  /// Appends only messages we haven't seen (matched by server id), so the local
  /// optimistic echo is never duplicated.
  Future<void> _refresh() async {
    if (_sending || _loading) return;
    try {
      final thread = await dataSource.getThread(leadId);
      _counterpartName = thread.counterpartName;
      final known = _messages.map((m) => m.id).toSet();
      final fresh = thread.messages.where((m) => !known.contains(m.id)).toList();
      if (fresh.isEmpty) return;
      _messages.addAll(fresh);
      notifyListeners();
      // We're looking at the thread — new arrivals are read.
      dataSource.markRead(leadId);
    } catch (_) {
      // Transient; the next tick retries.
    }
  }

  /// Sends a message with an optimistic echo, then reconciles with the server.
  Future<void> send(String text) async {
    final body = text.trim();
    if (body.isEmpty || _sending) return;

    final tempId = 'tmp_${DateTime.now().microsecondsSinceEpoch}';
    _messages.add(ChatMessageModel(
      id: tempId,
      senderRole: 'broker',
      body: body,
      createdAt: DateTime.now(),
      readAt: null,
    ));
    _sending = true;
    notifyListeners();

    try {
      final sent = await dataSource.sendMessage(leadId, body);
      final i = _messages.indexWhere((m) => m.id == tempId);
      if (i >= 0) _messages[i] = sent;
    } catch (_) {
      // Leave the optimistic message so the text isn't lost.
    } finally {
      _sending = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _poll?.cancel();
    _poll = null;
    super.dispose();
  }
}
