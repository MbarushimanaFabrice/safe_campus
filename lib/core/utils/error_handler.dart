import 'package:firebase_auth/firebase_auth.dart';

class ErrorHandler {
  static String getFirebaseAuthErrorMessage(dynamic error) {
    if (error is FirebaseException && error is! FirebaseAuthException) {
      switch (error.code) {
        case 'permission-denied':
          return 'Firebase blocked account setup. Deploy the updated Firestore rules, then try again.';
        case 'unavailable':
          return 'Firebase is unavailable. Check your internet connection and try again.';
        default:
          return error.message ?? 'Firebase account setup failed. Please try again.';
      }
    }

    if (error is! FirebaseAuthException) {
      if (error.toString().contains('User data not found')) {
        return 'Your account profile is missing. Contact the app administrator to repair it.';
      }
      return 'An unexpected error occurred. Please try again.';
    }

    switch (error.code) {
      case 'user-not-found':
        return 'No account found with this email. Please register first.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'invalid-email':
        return 'Use an @alustudent.com or @alueducation.com email.';
      case 'user-disabled':
        return 'This account has been disabled. Please contact support.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'operation-not-allowed':
        return 'Email/password sign in is not enabled. Please contact support.';
      case 'weak-password':
        return 'The password is too weak. Please use a stronger password.';
      case 'too-many-requests':
        return 'Too many failed attempts. Please try again later.';
      case 'network-request-failed':
        return 'Network error. Please check your internet connection.';
      case 'invalid-credential':
        return 'The provided credentials are invalid. Please try again.';
      default:
        return error.message ?? 'An error occurred. Please try again.';
    }
  }

  static String getFirestoreErrorMessage(dynamic error) {
    final errorString = error.toString().toLowerCase();
    
    if (errorString.contains('permission') || errorString.contains('denied')) {
      return 'You do not have permission to perform this action.';
    }
    
    if (errorString.contains('network') || errorString.contains('unavailable')) {
      return 'Network error. Please check your internet connection.';
    }
    
    if (errorString.contains('not-found')) {
      return 'The requested resource was not found.';
    }
    
    return 'An error occurred. Please try again.';
  }

  static String getCloudinaryErrorMessage(dynamic error) {
    final errorString = error.toString().toLowerCase();
    
    if (errorString.contains('network') || errorString.contains('connection')) {
      return 'Network error. Please check your internet connection and try again.';
    }
    
    if (errorString.contains('size') || errorString.contains('large')) {
      return 'Image size is too large. Please select a smaller image.';
    }
    
    if (errorString.contains('format') || errorString.contains('type')) {
      return 'Invalid image format. Please select a JPG or PNG image.';
    }
    
    return 'Failed to upload image. Please try again.';
  }
}
