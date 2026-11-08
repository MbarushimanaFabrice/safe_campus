import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/firebase_providers.dart';
import '../../../../core/utils/stream_first_event_timeout.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../data/models/incident_model.dart';
import '../../data/repositories/incident_repository.dart';

final incidentRepositoryProvider = Provider<IncidentRepository>((ref) {
  return FirebaseIncidentRepository(
    firestore: ref.watch(firebaseFirestoreProvider),
  );
});

final userIncidentsProvider = StreamProvider<List<IncidentModel>>((ref) {
  final userData = ref.watch(currentUserDataProvider);
  
  return userData.when(
    data: (user) {
      if (user == null) return Stream.value([]);
      return withFirstEventTimeout(
        ref.watch(incidentRepositoryProvider).getUserIncidents(user.uid),
        message: 'Timed out waiting for incident reports from Firestore.',
      );
    },
    loading: () => Stream.value([]),
    error: (_, __) => Stream.value([]),
  );
});

final allIncidentsProvider = StreamProvider<List<IncidentModel>>((ref) {
  return withFirstEventTimeout(
    ref.watch(incidentRepositoryProvider).getAllIncidents(),
    message: 'Timed out waiting for incident reports from Firestore.',
  );
});

final incidentByIdProvider = StreamProvider.family<IncidentModel, String>((ref, id) {
  return withFirstEventTimeout(
    ref.watch(incidentRepositoryProvider).getIncidentById(id),
    message: 'Timed out waiting for this incident from Firestore.',
  );
});
