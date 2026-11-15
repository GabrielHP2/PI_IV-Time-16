import 'package:flutter/foundation.dart';

import '../models/app_notification.dart';

/// Repositório local de notificações.
///
/// Os itens abaixo são exemplos para a interface do frontend. Na integração
/// com o backend, a consulta deverá considerar o perfil autenticado e retornar
/// somente notificações relacionadas às plataformas assinadas por ele.
class NotificationRepository {
  NotificationRepository._();

  static final ValueNotifier<List<AppNotification>> items =
      ValueNotifier<List<AppNotification>>([
    AppNotification(
      id: 'notification-1',
      platform: 'Netflix',
      title: 'Conteúdo adicionado',
      message:
          'Um título relacionado aos seus interesses chegou ao catálogo.',
      changeType: NotificationChangeType.added,
      createdAt: DateTime.now().subtract(const Duration(minutes: 12)),
    ),
    AppNotification(
      id: 'notification-2',
      platform: 'Disney+',
      title: 'Conteúdo removido em breve',
      message:
          'Um conteúdo da sua lista de interesse sairá do catálogo em breve.',
      changeType: NotificationChangeType.removed,
      createdAt: DateTime.now().subtract(const Duration(hours: 3)),
    ),
    AppNotification(
      id: 'notification-3',
      platform: 'Prime Video',
      title: 'Conteúdo adicionado',
      message:
          'Uma novidade que combina com suas preferências está disponível.',
      changeType: NotificationChangeType.added,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    AppNotification(
      id: 'notification-4',
      platform: 'Max',
      title: 'Conteúdo removido em breve',
      message:
          'Um título que pode interessar a você deixará o catálogo em breve.',
      changeType: NotificationChangeType.removed,
      createdAt: DateTime.now().subtract(const Duration(days: 1, hours: 4)),
    ),
    AppNotification(
      id: 'notification-5',
      platform: 'Globoplay',
      title: 'Conteúdo adicionado',
      message: 'Uma novidade foi adicionada ao catálogo da plataforma.',
      changeType: NotificationChangeType.added,
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    AppNotification(
      id: 'notification-6',
      platform: 'Apple TV+',
      title: 'Conteúdo adicionado',
      message: 'Há uma nova opção no catálogo da sua plataforma.',
      changeType: NotificationChangeType.added,
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
    ),
  ]);

  static List<AppNotification> forPlatforms(Iterable<String> platforms) {
    final subscribed = platforms.toSet();
    if (subscribed.isEmpty) return [];

    return items.value
        .where((notification) => subscribed.contains(notification.platform))
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  static int unreadCountForPlatforms(Iterable<String> platforms) {
    return forPlatforms(platforms).where((item) => !item.isRead).length;
  }

  static void markAsRead(String notificationId) {
    items.value = items.value.map((notification) {
      if (notification.id == notificationId) {
        return notification.copyWith(isRead: true);
      }
      return notification;
    }).toList();
  }

  static void markAllAsRead(Iterable<String> platforms) {
    final subscribed = platforms.toSet();
    items.value = items.value.map((notification) {
      if (subscribed.contains(notification.platform)) {
        return notification.copyWith(isRead: true);
      }
      return notification;
    }).toList();
  }
}
