import 'package:firebase_auth/firebase_auth.dart';
import '../../data/models/user_model.dart';

abstract class IAuthRepository {
  // Auth state
  Stream<User?> get authStateChanges;
  User? get currentUser;
  
  // Sign in / Sign up
  Future<UserModel> signInWithEmailPassword(String email, String password);
  Future<UserModel> signUpWithEmailPassword({
    required String email,
    required String password,
    required String fullName,
    required String department,
    String? phone,
  });
  
  // Password management
  Future<void> resetPassword(String email);
  Future<void> changePassword(String newPassword);
  
  // User data
  Future<UserModel?> getUserData(String uid);
  Stream<UserModel?> getUserDataStream(String uid);
  Future<void> updateUserProfile({
    String? fullName,
    String? department,
    String? phone,
    String? photoUrl,
  });
  
  // Sign out
  Future<void> signOut();
}
