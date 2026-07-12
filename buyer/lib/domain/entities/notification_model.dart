class NotificationModel {
  final String id;
  final String title;
  final String message;
  final String? imageUrl;
  final DateTime timestamp;
  final NotificationType type;
  final bool isRead;

  /// Deep-link payload — only set for types that navigate somewhere.
  final String? saleId;
  final String? visitId;
  final String? projectId;

  const NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    this.imageUrl,
    required this.timestamp,
    required this.type,
    this.isRead = false,
    this.saleId,
    this.visitId,
    this.projectId,
  });

  NotificationModel copyWith({bool? isRead}) => NotificationModel(
        id: id,
        title: title,
        message: message,
        imageUrl: imageUrl,
        timestamp: timestamp,
        type: type,
        isRead: isRead ?? this.isRead,
        saleId: saleId,
        visitId: visitId,
        projectId: projectId,
      );
}

enum NotificationType {
  offer,
  visit,
  interest,
  system,
}
