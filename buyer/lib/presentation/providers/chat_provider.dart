import 'dart:async';

import 'package:flutter/foundation.dart';
import '../../domain/entities/message.dart';
import '../../data/datasources/remote/chat_remote_data_source.dart';
import '../../core/utils/url_detector.dart';

/// Buyer↔broker chat for a single lead, backed by
/// `/buyer/leads/{lead_id}/messages`. [contact.id] is the lead id.
class ChatProvider with ChangeNotifier {
  final ChatRemoteDataSource dataSource;
  final ChatContact contact;

  final List<Message> _messages = [];
  bool _isTyping = false;
  bool _isLoading = false;
  bool _sending = false;
  String? _counterpartName;

  ChatProvider({required this.dataSource, required this.contact});

  String get leadId => contact.id;
  List<Message> get messages => List.unmodifiable(_messages);
  bool get isTyping => _isTyping;
  bool get isLoading => _isLoading;
  bool get isSending => _sending;
  String? get counterpartName => _counterpartName;

  void addMessage(Message message) {
    _messages.add(message);
    notifyListeners();
  }

  /// Loads the real thread from the backend and marks it read.
  Future<void> loadMessages() async {
    _isLoading = true;
    notifyListeners();
    try {
      final thread = await dataSource.getThread(leadId);
      _counterpartName = thread.counterpartName;
      _messages
        ..clear()
        ..addAll(thread.messages.map(
          (m) => _message(m.id, m.body, m.createdAt, m.fromBuyer),
        ));
    } catch (_) {
      // Keep whatever we have; the UI can retry via pull/refresh.
    } finally {
      _isLoading = false;
      notifyListeners();
    }
    // Fire-and-forget read receipt.
    dataSource.markRead(leadId);
  }

  /// Sends a text message: echo it optimistically, then persist via the API and
  /// reconcile with the server copy.
  Future<void> sendMessage(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty || _sending) return;

    final optimistic = _message(
      'tmp_${DateTime.now().microsecondsSinceEpoch}',
      trimmed,
      DateTime.now(),
      true,
    );
    _messages.add(optimistic);
    _sending = true;
    notifyListeners();

    try {
      final sent = await dataSource.sendMessage(leadId, trimmed);
      final idx = _messages.indexWhere((m) => m.id == optimistic.id);
      final real = _message(sent.id, sent.body, sent.createdAt, sent.fromBuyer);
      if (idx >= 0) {
        _messages[idx] = real;
      }
    } catch (_) {
      // Leave the optimistic message in place so text isn't lost.
    } finally {
      _sending = false;
      notifyListeners();
    }
  }

  /// Builds a [Message], tagging it as a link when it contains a URL.
  Message _message(String id, String body, DateTime ts, bool isSent) {
    if (UrlDetector.containsUrl(body)) {
      final url = UrlDetector.extractUrl(body);
      if (url != null) {
        return Message(
          id: id,
          text: body,
          timestamp: ts.toLocal(),
          isSent: isSent,
          type: MessageType.link,
          linkUrl: UrlDetector.normalizeUrl(url),
        );
      }
    }
    return Message(id: id, text: body, timestamp: ts.toLocal(), isSent: isSent);
  }

  // --- Local-only attachments (the text API doesn't persist media yet) -------

  void sendRichContentMessage(String text, RichContent richContent) {
    addMessage(Message(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: text.trim(),
      timestamp: DateTime.now(),
      isSent: true,
      type: MessageType.richContent,
      richContent: richContent,
    ));
  }

  void sendImageMessage(String text, String imagePath) {
    addMessage(Message(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: text.trim(),
      timestamp: DateTime.now(),
      isSent: true,
      type: MessageType.image,
      imagePath: imagePath,
    ));
  }

  void sendContactMessage(String text, SharedContact contact) {
    addMessage(Message(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: text.trim(),
      timestamp: DateTime.now(),
      isSent: true,
      type: MessageType.contact,
      sharedContact: contact,
    ));
  }

  void sendDocumentMessage(String text, SharedDocument document) {
    addMessage(Message(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: text.trim(),
      timestamp: DateTime.now(),
      isSent: true,
      type: MessageType.document,
      sharedDocument: document,
    ));
  }

  void setTyping(bool typing) {
    _isTyping = typing;
    notifyListeners();
  }
}
