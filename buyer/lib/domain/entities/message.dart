class Message {
  final String id;
  final String text;
  final DateTime timestamp;
  final bool isSent;
  final MessageType type;
  final RichContent? richContent;
  final String? imagePath;
  final SharedContact? sharedContact;
  final SharedDocument? sharedDocument;
  final String? linkUrl;

  Message({
    required this.id,
    required this.text,
    required this.timestamp,
    required this.isSent,
    this.type = MessageType.text,
    this.richContent,
    this.imagePath,
    this.sharedContact,
    this.sharedDocument,
    this.linkUrl,
  });
}

enum MessageType {
  text,
  richContent,
  image,
  contact,
  document,
  link,
}

class RichContent {
  final String imageUrl;
  final String title;
  final String location;
  final String? linkText;
  final String? linkUrl;

  RichContent({
    required this.imageUrl,
    required this.title,
    required this.location,
    this.linkText,
    this.linkUrl,
  });
}

class ChatContact {
  final String id;
  final String name;
  final String? profileImageUrl;
  final bool isOnline;
  final String? lastSeen;
  final int unreadCount;
  final String? lastMessage;
  final DateTime? lastMessageTimestamp;

  ChatContact({
    required this.id,
    required this.name,
    this.profileImageUrl,
    this.isOnline = false,
    this.lastSeen,
    this.unreadCount = 0,
    this.lastMessage,
    this.lastMessageTimestamp,
  });
}

class SharedContact {
  final String name;
  final String? primaryPhone;
  final List<String> phoneNumbers;
  final String? email;
  final String? avatarUrl;
  final String? address;

  SharedContact({
    required this.name,
    this.primaryPhone,
    this.phoneNumbers = const [],
    this.email,
    this.avatarUrl,
    this.address,
  });
}

class SharedDocument {
  final String fileName;
  final String filePath;
  final String fileType;
  final int fileSize;
  final String? thumbnailPath;

  SharedDocument({
    required this.fileName,
    required this.filePath,
    required this.fileType,
    required this.fileSize,
    this.thumbnailPath,
  });
}