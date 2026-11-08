import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors - Orange Theme
  static const Color primary = Color(0xFFF97316);
  static const Color primaryDark = Color(0xFFC2410C);
  static const Color primaryLight = Color(0xFFFFEDD5);
  static const Color accent = Color(0xFFFB923C);
  
  // Background Colors
  static const Color background = Color(0xFFFFFAF5);
  static const Color surface = Color(0xFFFFFFFF);
  
  // Text Colors
  static const Color textPrimary = Color(0xFF1F1A17);
  static const Color textSecondary = Color(0xFF7A6F66);
  
  // Status Colors
  static const Color statusSubmitted = Color(0xFFF59E0B);
  static const Color statusSubmittedBg = Color(0xFFFEF3C7);
  
  static const Color statusInProgress = Color(0xFF2563EB);
  static const Color statusInProgressBg = Color(0xFFDBEAFE);
  
  static const Color statusResolved = Color(0xFF16A34A);
  static const Color statusResolvedBg = Color(0xFFDCFCE7);
  
  // Priority Colors
  static const Color priorityLow = Color(0xFF10B981);
  static const Color priorityMedium = Color(0xFFF59E0B);
  static const Color priorityHigh = Color(0xFFDC2626);
  
  // Category Colors
  static const Color categoryFacilities = Color(0xFF8B5CF6);
  static const Color categoryWater = Color(0xFF06B6D4);
  static const Color categoryElectricity = Color(0xFFF59E0B);
  static const Color categoryFurniture = Color(0xFF6366F1);
  static const Color categorySanitation = Color(0xFF10B981);
  static const Color categorySafety = Color(0xFFEF4444);
  
  // Utility Colors
  static const Color error = Color(0xFFDC2626);
  static const Color success = Color(0xFF16A34A);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = Color(0xFF2563EB);
  
  // Gradient
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient heroGradient = LinearGradient(
    colors: [Color(0xFFF97316), Color(0xFFC2410C)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
