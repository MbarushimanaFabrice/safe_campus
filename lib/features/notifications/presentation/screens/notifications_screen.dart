import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/error_state.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../providers/notification_providers.dart';
import '../../../incidents/presentation/screens/incident_details_screen.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(userNotificationsProvider);
    final userData = ref.watch(currentUserDataProvider).value;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          notificationsAsync.when(
            data: (notifications) {
              final unreadCount = notifications.where((n) => !n.read).length;
              if (unreadCount == 0) return const SizedBox.shrink();

              return TextButton(
                onPressed: () async {
                  if (userData != null) {
                    await ref
                        .read(notificationRepositoryProvider)
                        .markAllAsRead(userData.uid);
                  }
                },
                child: const Text('Mark all read'),
              );
            },
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ],
      ),
      body: notificationsAsync.when(
        data: (notifications) {
          if (notifications.isEmpty) {
            return const EmptyState(
              icon: Icons.notifications_none,
              title: 'No notifications',
              message: 'You don\'t have any notifications yet.',
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(userNotificationsProvider);
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notification = notifications[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  color: notification.read
                      ? null
                      : Theme.of(context).colorScheme.primary.withOpacity(0.05),
                  child: ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.notifications,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    title: Text(
                      notification.title,
                      style: TextStyle(
                        fontWeight: notification.read ? FontWeight.normal : FontWeight.w600,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(notification.message),
                        const SizedBox(height: 4),
                        Text(
                          timeago.format(notification.createdAt),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    isThreeLine: true,
                    onTap: () async {
                      // Mark as read
                      if (!notification.read) {
                        await ref
                            .read(notificationRepositoryProvider)
                            .markAsRead(notification.id);
                      }

                      // Navigate to incident details
                      if (context.mounted) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => IncidentDetailsScreen(
                              incidentId: notification.incidentId,
                            ),
                          ),
                        );
                      }
                    },
                  ),
                );
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => ErrorState(
          message: 'Failed to load notifications',
          onRetry: () => ref.invalidate(userNotificationsProvider),
        ),
      ),
    );
  }
}
