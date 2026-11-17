import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../models/app_notification.dart';
import '../../repositories/notification_repository.dart';
import '../../theme/app_theme.dart';

class NotificationPanel extends StatelessWidget {
  const NotificationPanel({
    super.key,
    required this.platforms,
    required this.onClose,
    required this.width,
    required this.maxHeight,
  });

  final List<String> platforms;
  final VoidCallback onClose;
  final double width;
  final double maxHeight;

  @override
  Widget build(BuildContext context) {
    final panelHeight = math.max(190.0, maxHeight);

    return Material(
      color: Colors.transparent,
      elevation: 12,
      child: Container(
        width: width,
        height: panelHeight,
        decoration: BoxDecoration(
          color: const Color(0xFFD8B9E5),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFB98ACF), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.24),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            _buildHeader(),
            const Divider(height: 1, color: Color(0xFFAD83C0)),
            Expanded(
              child: ValueListenableBuilder<List<AppNotification>>(
                valueListenable: NotificationRepository.items,
                builder: (context, notifications, child) {
                  final subscribedPlatforms = platforms.toSet();
                  final visibleNotifications = notifications
                      .where((notification) => subscribedPlatforms
                          .contains(notification.platform))
                      .toList()
                    ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

                  if (platforms.isEmpty) {
                    return const _EmptyNotifications(
                      message:
                          'Informe suas plataformas assinadas na personalização para receber notificações.',
                    );
                  }

                  if (visibleNotifications.isEmpty) {
                    return const _EmptyNotifications(
                      message:
                          'Você ainda não tem notificações para as plataformas selecionadas.',
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 7,
                    ),
                    itemCount: visibleNotifications.length,
                    separatorBuilder: (_, _) => const Divider(
                      height: 1,
                      color: Color(0xFFB58BC7),
                    ),
                    itemBuilder: (context, index) {
                      final notification = visibleNotifications[index];
                      return _NotificationTile(
                        notification: notification,
                        onTap: () => NotificationRepository.markAsRead(
                          notification.id,
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.only(left: 12, right: 5, top: 7, bottom: 5),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              'Notificações',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: AppColors.button,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          IconButton(
            tooltip: 'Marcar todas como lidas',
            visualDensity: VisualDensity.compact,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints.tightFor(width: 30, height: 30),
            onPressed: () => NotificationRepository.markAllAsRead(platforms),
            icon: const Icon(
              Icons.done_all,
              color: AppColors.button,
              size: 17,
            ),
          ),
          IconButton(
            tooltip: 'Fechar notificações',
            visualDensity: VisualDensity.compact,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints.tightFor(width: 27, height: 30),
            onPressed: onClose,
            icon: const Icon(
              Icons.close,
              color: AppColors.button,
              size: 18,
            ),
          ),
        ],
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({
    required this.notification,
    required this.onTap,
  });

  final AppNotification notification;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isAdded =
        notification.changeType == NotificationChangeType.added;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 2),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 22,
                  height: 22,
                  decoration: const BoxDecoration(
                    color: AppColors.logoCircle,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isAdded ? Icons.add : Icons.remove,
                    color: Colors.white,
                    size: 15,
                  ),
                ),
                if (!notification.isRead)
                  Positioned(
                    top: -2,
                    left: -2,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Color(0xFFE21D3D),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notification.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppColors.button,
                      fontSize: 11,
                      fontWeight: notification.isRead
                          ? FontWeight.w500
                          : FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    notification.message,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF392044),
                      fontSize: 10,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${notification.platform} • ${_formatDate(notification.createdAt)}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF694B78),
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final difference = DateTime.now().difference(date);
    if (difference.inMinutes < 1) return 'agora';
    if (difference.inHours < 1) return 'há ${difference.inMinutes} min';
    if (difference.inDays < 1) return 'há ${difference.inHours} h';
    if (difference.inDays == 1) return 'ontem';
    return 'há ${difference.inDays} dias';
  }
}

class _EmptyNotifications extends StatelessWidget {
  const _EmptyNotifications({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.notifications_none,
              color: AppColors.logoCircle,
              size: 28,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.button,
                fontSize: 11,
                height: 1.35,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
