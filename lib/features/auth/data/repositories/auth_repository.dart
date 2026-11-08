import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/constants/app_constants.dart';
import '../models/user_model.dart';

abstract class AuthRepository {
  User? get currentUser;
  Stream<User?> get authStateChanges;
  
  Future<UserModel> signIn(String email, String password);
  Future<UserModel> signUp({
    required String fullName,
    required String email,
    required String department,
    String? phone,
    required String password,
  });
  Future<void> signOut();
  Future<void> sendPasswordResetEmail(String email);
  Future<UserModel?> getCurrentUserData();
  Future<void> updateUserProfile({
    String? fullName,
    String? department,
    String? phone,
    String? photoUrl,
  });
}

class FirebaseAuthRepository implements AuthRepository {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  FirebaseAuthRepository({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  User? get currentUser => _auth.currentUser;

  @override
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  @override
  Future<UserModel> signIn(String email, String password) async {
    try {
      final normalizedEmail = email.trim().toLowerCase();
      final expectedRole = UserRole.fromInstitutionalEmail(normalizedEmail);
      if (expectedRole == null) {
        throw FirebaseAuthException(
          code: 'invalid-email',
          message: 'Use an @alustudent.com or @alueducation.com email.',
        );
      }

      final credential = await _auth.signInWithEmailAndPassword(
        email: normalizedEmail,
        password: password,
      );

      if (credential.user == null) {
        throw Exception('Sign in failed');
      }

      var userData = await _getUserData(credential.user!.uid);
      if (userData.role != expectedRole) {
        await _firestore
            .collection(AppConstants.usersCollection)
            .doc(userData.uid)
            .update({'role': expectedRole.value});
        userData = userData.copyWith(role: expectedRole);
      }
      return userData;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<UserModel> signUp({
    required String fullName,
    required String email,
    required String department,
    String? phone,
    required String password,
  }) async {
    try {
      final normalizedEmail = email.trim().toLowerCase();
      final role = UserRole.fromInstitutionalEmail(normalizedEmail);
      if (role == null) {
        throw FirebaseAuthException(
          code: 'invalid-email',
          message: 'Use an @alustudent.com or @alueducation.com email.',
        );
      }

      final credential = await _auth.createUserWithEmailAndPassword(
        email: normalizedEmail,
        password: password,
      );

      if (credential.user == null) {
        throw Exception('Sign up failed');
      }

      final user = UserModel(
        uid: credential.user!.uid,
        fullName: fullName,
        email: normalizedEmail,
        role: role,
        department: department,
        phone: phone,
        photoUrl: null,
        createdAt: DateTime.now(),
      );

      try {
        await _firestore
            .collection(AppConstants.usersCollection)
            .doc(user.uid)
            .set(user.toMap());
      } catch (_) {
        try {
          await credential.user!.delete();
        } catch (_) {
          await _auth.signOut();
        }
        rethrow;
      }

      return user;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> signOut() async {
    await _auth.signOut();
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  @override
  Future<UserModel?> getCurrentUserData() async {
    final user = currentUser;
    if (user == null) return null;

    return _getUserData(user.uid);
  }

  Future<UserModel> _getUserData(String uid) async {
    final doc = await _firestore
        .collection(AppConstants.usersCollection)
        .doc(uid)
        .get();

    if (!doc.exists) {
      throw Exception('User data not found');
    }

    return UserModel.fromFirestore(doc);
  }

  @override
  Future<void> updateUserProfile({
    String? fullName,
    String? department,
    String? phone,
    String? photoUrl,
  }) async {
    final user = currentUser;
    if (user == null) {
      throw Exception('No user signed in');
    }

    final updates = <String, dynamic>{};
    if (fullName != null) updates['fullName'] = fullName;
    if (department != null) updates['department'] = department;
    if (phone != null) updates['phone'] = phone;
    if (photoUrl != null) updates['photoUrl'] = photoUrl;

    if (updates.isEmpty) return;

    await _firestore
        .collection(AppConstants.usersCollection)
        .doc(user.uid)
        .update(updates);
  }
}
