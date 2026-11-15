enum NotificationChangeType {
  added,
  removed,
}

class AppNotification {
  const AppNotification({
    required this.id,
    required this.platform,
    required this.title,
    required this.message,
    required this.changeType,
    required this.createdAt,
    this.isRead = false,
  });

  final String id;
  final String platform;
  final String title;
  final String message;
  final NotificationChangeType changeType;
  final DateTime createdAt;
  final bool isRead;

  AppNotification copyWith({bool? isRead}) {
    return AppNotification(
      id: id,
      platform: platform,
      title: title,
      message: message,
      changeType: changeType,
      createdAt: createdAt,
      isRead: isRead ?? this.isRead,
    );
  }
}
