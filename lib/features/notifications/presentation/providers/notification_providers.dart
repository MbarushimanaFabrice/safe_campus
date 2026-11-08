import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/firebase_providers.dart';
import '../../../../core/utils/stream_first_event_timeout.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../data/models/notification_model.dart';
import '../../data/repositories/notification_repository.dart';

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  return FirebaseNotificationRepository(
    firestore: ref.watch(firebaseFirestoreProvider),
  );
});

final userNotificationsProvider = StreamProvider<List<NotificationModel>>((ref) {
  final userData = ref.watch(currentUserDataProvider);
  
  return userData.when(
    data: (user) {
      if (user == null) return Stream.value([]);
      return withFirstEventTimeout(
        ref.watch(notificationRepositoryProvider).getUserNotifications(user.uid),
        message: 'Timed out waiting for notifications from Firestore.',
      );
    },
    loading: () => Stream.value([]),
    error: (_, __) => Stream.value([]),
  );
});

final unreadNotificationCountProvider = StreamProvider<int>((ref) {
  final userData = ref.watch(currentUserDataProvider);
  
  return userData.when(
    data: (user) {
      if (user == null) return Stream.value(0);
      return withFirstEventTimeout(
        ref.watch(notificationRepositoryProvider).getUnreadCount(user.uid),
        message: 'Timed out waiting for the notification count from Firestore.',
      );
    },
    loading: () => Stream.value(0),
    error: (_, __) => Stream.value(0),
  );
});
