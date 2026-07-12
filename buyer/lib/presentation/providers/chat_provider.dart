import 'package:flutter/foundation.dart';
import '../../domain/entities/message.dart';
import '../../core/utils/url_detector.dart';

class ChatProvider with ChangeNotifier {
  final ChatContact contact;
  final List<Message> _messages = [];
  bool _isTyping = false;

  ChatProvider({required this.contact});

  List<Message> get messages => List.unmodifiable(_messages);
  bool get isTyping => _isTyping;

  void addMessage(Message message) {
    _messages.add(message);
    notifyListeners();
  }

  void sendMessage(String text) {
    if (text.trim().isEmpty) return;

    final trimmedText = text.trim();
    
    // Check if message contains a URL
    if (UrlDetector.containsUrl(trimmedText)) {
      final url = UrlDetector.extractUrl(trimmedText);
      if (url != null) {
        final normalizedUrl = UrlDetector.normalizeUrl(url);
        final message = Message(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          text: trimmedText,
          timestamp: DateTime.now(),
          isSent: true,
          type: MessageType.link,
          linkUrl: normalizedUrl,
        );
        addMessage(message);
        return;
      }
    }

    final message = Message(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: trimmedText,
      timestamp: DateTime.now(),
      isSent: true,
    );

    addMessage(message);
  }

  void sendRichContentMessage(String text, RichContent richContent) {
    final message = Message(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: text.trim(),
      timestamp: DateTime.now(),
      isSent: true,
      type: MessageType.richContent,
      richContent: richContent,
    );

    addMessage(message);
  }

  void sendImageMessage(String text, String imagePath) {
    final message = Message(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: text.trim(),
      timestamp: DateTime.now(),
      isSent: true,
      type: MessageType.image,
      imagePath: imagePath,
    );

    addMessage(message);
  }

  void sendContactMessage(String text, SharedContact contact) {
    final message = Message(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: text.trim(),
      timestamp: DateTime.now(),
      isSent: true,
      type: MessageType.contact,
      sharedContact: contact,
    );

    addMessage(message);
  }

  void sendDocumentMessage(String text, SharedDocument document) {
    final message = Message(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: text.trim(),
      timestamp: DateTime.now(),
      isSent: true,
      type: MessageType.document,
      sharedDocument: document,
    );

    addMessage(message);
  }

  void setTyping(bool typing) {
    _isTyping = typing;
    notifyListeners();
  }

  void loadMessages() {
    // Load initial messages if needed
    // For now, we'll start with empty chat
  }
}