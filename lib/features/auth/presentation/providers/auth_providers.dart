import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/firebase_providers.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/auth_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return FirebaseAuthRepository(
    auth: ref.watch(firebaseAuthProvider),
    firestore: ref.watch(firebaseFirestoreProvider),
  );
});

final currentUserDataProvider = StreamProvider<UserModel?>((ref) {
  final authRepo = ref.watch(authRepositoryProvider);
  final authState = ref.watch(authStateChangesProvider);
  
  return authState.when(
    data: (user) {
      if (user == null) {
        return Stream.value(null);
      }
      return Stream.fromFuture(
        authRepo
        .getCurrentUserData()
        .timeout(const Duration(seconds: 20)),
      );
    },
    loading: () => Stream.value(null),
    error: (_, __) => Stream.value(null),
  );
});
