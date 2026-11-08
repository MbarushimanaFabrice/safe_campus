class AppConstants {
  // App Info
  static const String appName = 'Safe Campus';
  static const String appTagline = 'Help make our campus safer. Report issues and track their resolution.';
  
  // Collections
  static const String usersCollection = 'users';
  static const String incidentsCollection = 'incidents';
  static const String notificationsCollection = 'notifications';
  
  // Departments
  static const List<String> departments = [
    'Software Engineering',
    'Entrepreneurial Leadership',
  ];
  
  // Locations
  static const List<String> locations = [
    'Block A',
    'Block B',
    'Block C',
    'Library',
    'Cafeteria',
    'Student Residence',
    'Computer Lab',
    'Sports Ground',
    'Parking',
    'Admin Building',
    'Other',
  ];
  
  // Limits
  static const int maxPhotosPerReport = 3;
  static const int maxPhotoSizeMB = 5;
  static const int titleMinLength = 5;
  static const int titleMaxLength = 80;
  static const int descriptionMinLength = 10;
  static const int descriptionMaxLength = 500;
  
  // Cloudinary
  static const String cloudinaryIncidentsFolder = 'safecampus/incidents';
  static const String cloudinaryProfilesFolder = 'safecampus/profiles';
  static const String cloudinaryThumbnailTransform = 'w_300,h_300,c_fill,q_auto,f_jpg';
}

enum UserRole {
  student('student'),
  staff('staff');

  final String value;
  const UserRole(this.value);

  static UserRole fromString(String value) {
    return UserRole.values.firstWhere(
      (e) => e.value == value,
      orElse: () => UserRole.student,
    );
  }

  static UserRole? fromInstitutionalEmail(String email) {
    final normalizedEmail = email.trim().toLowerCase();
    if (normalizedEmail.endsWith('@alustudent.com')) return UserRole.student;
    if (normalizedEmail.endsWith('@alueducation.com')) return UserRole.staff;
    return null;
  }
}

enum IncidentStatus {
  submitted('submitted', 'Submitted'),
  inProgress('in_progress', 'In Progress'),
  resolved('resolved', 'Resolved');

  final String value;
  final String displayName;
  const IncidentStatus(this.value, this.displayName);

  static IncidentStatus fromString(String value) {
    return IncidentStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => IncidentStatus.submitted,
    );
  }
}

enum IncidentCategory {
  facilities('facilities', 'Facilities', '🏢'),
  water('water', 'Water', '💧'),
  electricity('electricity', 'Electricity', '⚡'),
  safety('safety', 'Safety', '🛡️'),
  sanitation('sanitation', 'Sanitation', '🗑️'),
  furniture('furniture', 'Furniture', '🪑');

  final String value;
  final String displayName;
  final String emoji;
  const IncidentCategory(this.value, this.displayName, this.emoji);

  static IncidentCategory fromString(String value) {
    return IncidentCategory.values.firstWhere(
      (e) => e.value == value,
      orElse: () => IncidentCategory.facilities,
    );
  }
}

enum IncidentPriority {
  low('low', 'Low'),
  medium('medium', 'Medium'),
  high('high', 'High');

  final String value;
  final String displayName;
  const IncidentPriority(this.value, this.displayName);

  static IncidentPriority fromString(String value) {
    return IncidentPriority.values.firstWhere(
      (e) => e.value == value,
      orElse: () => IncidentPriority.medium,
    );
  }
}
