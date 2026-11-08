import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../utils/stream_first_event_timeout.dart';

final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

final firebaseFirestoreProvider = Provider<FirebaseFirestore>((ref) {
  final firestore = FirebaseFirestore.instance;
  firestore.settings = const Settings(persistenceEnabled: true);
  return firestore;
});

final authStateChangesProvider = StreamProvider<User?>((ref) {
  return withFirstEventTimeout(
    ref.watch(firebaseAuthProvider).authStateChanges(),
    message: 'Firebase authentication did not initialize in time.',
  );
});
