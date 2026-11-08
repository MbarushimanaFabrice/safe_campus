import '../constants/app_constants.dart';

class Validators {
  static String? email(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email';
    }
    
    return null;
  }

  static String? institutionalEmail(String? value) {
    final formatError = email(value);
    if (formatError != null) return formatError;

    if (UserRole.fromInstitutionalEmail(value!) == null) {
      return 'Use an @alustudent.com or @alueducation.com email';
    }

    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    
    return null;
  }

  static String? confirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    
    if (value != password) {
      return 'Passwords do not match';
    }
    
    return null;
  }

  static String? name(String? value) {
    if (value == null || value.isEmpty) {
      return 'Name is required';
    }
    
    if (value.trim().length < 2) {
      return 'Name must be at least 2 characters';
    }
    
    return null;
  }

  static String? required(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  static String? title(String? value) {
    if (value == null || value.isEmpty) {
      return 'Title is required';
    }
    
    if (value.length < AppConstants.titleMinLength) {
      return 'Title must be at least ${AppConstants.titleMinLength} characters';
    }
    
    if (value.length > AppConstants.titleMaxLength) {
      return 'Title must not exceed ${AppConstants.titleMaxLength} characters';
    }
    
    return null;
  }

  static String? description(String? value) {
    if (value == null || value.isEmpty) {
      return 'Description is required';
    }
    
    if (value.length < AppConstants.descriptionMinLength) {
      return 'Description must be at least ${AppConstants.descriptionMinLength} characters';
    }
    
    if (value.length > AppConstants.descriptionMaxLength) {
      return 'Description must not exceed ${AppConstants.descriptionMaxLength} characters';
    }
    
    return null;
  }

  static String? phone(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Optional
    }
    
    final phoneRegex = RegExp(r'^\+?[\d\s-]{10,}$');
    
    if (!phoneRegex.hasMatch(value)) {
      return 'Please enter a valid phone number';
    }
    
    return null;
  }
}
