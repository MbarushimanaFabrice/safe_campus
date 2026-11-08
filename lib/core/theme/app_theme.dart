import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Orange Identity
  static const Color primary = Color(0xFFF97316);
  static const Color primaryDark = Color(0xFFC2410C);
  static const Color primaryLight = Color(0xFFFFEDD5);
  static const Color accent = Color(0xFFFB923C);
  
  // Backgrounds
  static const Color background = Color(0xFFFFFAF5);
  static const Color surface = Color(0xFFFFFFFF);
  
  // Text
  static const Color textPrimary = Color(0xFF1F1A17);
  static const Color textSecondary = Color(0xFF7A6F66);
  
  // Borders
  static const Color border = Color(0xFFF1E4D8);
  
  // Status Colors
  static const Color submittedBg = Color(0xFFFEF3C7);
  static const Color submittedText = Color(0xFFF59E0B);
  
  static const Color inProgressBg = Color(0xFFDBEAFE);
  static const Color inProgressText = Color(0xFF2563EB);
  
  static const Color resolvedBg = Color(0xFFDCFCE7);
  static const Color resolvedText = Color(0xFF16A34A);
  
  // Priority Colors
  static const Color lowPriority = Color(0xFF9CA3AF);
  static const Color mediumPriority = Color(0xFFF59E0B);
  static const Color highPriority = Color(0xFFDC2626);
  
  // Dark Theme
  static const Color darkBackground = Color(0xFF1C1917);
  static const Color darkSurface = Color(0xFF292524);
  static const Color darkTextPrimary = Color(0xFFFAFAF9);
  static const Color darkTextSecondary = Color(0xFFA8A29E);
  static const Color darkBorder = Color(0xFF44403C);
}

@immutable
class StatusColors extends ThemeExtension<StatusColors> {
  final Color submittedBg;
  final Color submittedText;
  final Color inProgressBg;
  final Color inProgressText;
  final Color resolvedBg;
  final Color resolvedText;
  final Color lowPriority;
  final Color mediumPriority;
  final Color highPriority;

  const StatusColors({
    required this.submittedBg,
    required this.submittedText,
    required this.inProgressBg,
    required this.inProgressText,
    required this.resolvedBg,
    required this.resolvedText,
    required this.lowPriority,
    required this.mediumPriority,
    required this.highPriority,
  });

  @override
  StatusColors copyWith({
    Color? submittedBg,
    Color? submittedText,
    Color? inProgressBg,
    Color? inProgressText,
    Color? resolvedBg,
    Color? resolvedText,
    Color? lowPriority,
    Color? mediumPriority,
    Color? highPriority,
  }) {
    return StatusColors(
      submittedBg: submittedBg ?? this.submittedBg,
      submittedText: submittedText ?? this.submittedText,
      inProgressBg: inProgressBg ?? this.inProgressBg,
      inProgressText: inProgressText ?? this.inProgressText,
      resolvedBg: resolvedBg ?? this.resolvedBg,
      resolvedText: resolvedText ?? this.resolvedText,
      lowPriority: lowPriority ?? this.lowPriority,
      mediumPriority: mediumPriority ?? this.mediumPriority,
      highPriority: highPriority ?? this.highPriority,
    );
  }

  @override
  StatusColors lerp(ThemeExtension<StatusColors>? other, double t) {
    if (other is! StatusColors) return this;
    return StatusColors(
      submittedBg: Color.lerp(submittedBg, other.submittedBg, t)!,
      submittedText: Color.lerp(submittedText, other.submittedText, t)!,
      inProgressBg: Color.lerp(inProgressBg, other.inProgressBg, t)!,
      inProgressText: Color.lerp(inProgressText, other.inProgressText, t)!,
      resolvedBg: Color.lerp(resolvedBg, other.resolvedBg, t)!,
      resolvedText: Color.lerp(resolvedText, other.resolvedText, t)!,
      lowPriority: Color.lerp(lowPriority, other.lowPriority, t)!,
      mediumPriority: Color.lerp(mediumPriority, other.mediumPriority, t)!,
      highPriority: Color.lerp(highPriority, other.highPriority, t)!,
    );
  }

  static const light = StatusColors(
    submittedBg: AppColors.submittedBg,
    submittedText: AppColors.submittedText,
    inProgressBg: AppColors.inProgressBg,
    inProgressText: AppColors.inProgressText,
    resolvedBg: AppColors.resolvedBg,
    resolvedText: AppColors.resolvedText,
    lowPriority: AppColors.lowPriority,
    mediumPriority: AppColors.mediumPriority,
    highPriority: AppColors.highPriority,
  );

  static const dark = light;
}

class AppTheme {
  static ThemeData lightTheme() {
    final textTheme = GoogleFonts.poppinsTextTheme();
    
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.accent,
        surface: AppColors.surface,
        background: AppColors.background,
        error: Colors.red,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: AppColors.textPrimary,
        onBackground: AppColors.textPrimary,
      ),
      scaffoldBackgroundColor: AppColors.background,
      textTheme: textTheme.copyWith(
        displayLarge: textTheme.displayLarge?.copyWith(color: AppColors.textPrimary),
        displayMedium: textTheme.displayMedium?.copyWith(color: AppColors.textPrimary),
        displaySmall: textTheme.displaySmall?.copyWith(color: AppColors.textPrimary),
        headlineLarge: textTheme.headlineLarge?.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w600),
        headlineMedium: textTheme.headlineMedium?.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w600),
        headlineSmall: textTheme.headlineSmall?.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w600),
        titleLarge: textTheme.titleLarge?.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w600),
        titleMedium: textTheme.titleMedium?.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w500),
        titleSmall: textTheme.titleSmall?.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w500),
        bodyLarge: textTheme.bodyLarge?.copyWith(color: AppColors.textPrimary),
        bodyMedium: textTheme.bodyMedium?.copyWith(color: AppColors.textPrimary),
        bodySmall: textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
        labelLarge: textTheme.labelLarge?.copyWith(color: AppColors.textPrimary),
        labelMedium: textTheme.labelMedium?.copyWith(color: AppColors.textSecondary),
        labelSmall: textTheme.labelSmall?.copyWith(color: AppColors.textSecondary),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.red),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.primaryLight,
        selectedColor: AppColors.primary,
        labelStyle: textTheme.labelMedium?.copyWith(color: AppColors.primary),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.border,
        thickness: 1,
      ),
      extensions: const <ThemeExtension<dynamic>>[
        StatusColors.light,
      ],
    );
  }

  static ThemeData darkTheme() {
    final textTheme = GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme);
    
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        secondary: AppColors.accent,
        surface: AppColors.darkSurface,
        background: AppColors.darkBackground,
        error: Colors.red,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: AppColors.darkTextPrimary,
        onBackground: AppColors.darkTextPrimary,
      ),
      scaffoldBackgroundColor: AppColors.darkBackground,
      textTheme: textTheme.copyWith(
        displayLarge: textTheme.displayLarge?.copyWith(color: AppColors.darkTextPrimary),
        displayMedium: textTheme.displayMedium?.copyWith(color: AppColors.darkTextPrimary),
        displaySmall: textTheme.displaySmall?.copyWith(color: AppColors.darkTextPrimary),
        headlineLarge: textTheme.headlineLarge?.copyWith(color: AppColors.darkTextPrimary, fontWeight: FontWeight.w600),
        headlineMedium: textTheme.headlineMedium?.copyWith(color: AppColors.darkTextPrimary, fontWeight: FontWeight.w600),
        headlineSmall: textTheme.headlineSmall?.copyWith(color: AppColors.darkTextPrimary, fontWeight: FontWeight.w600),
        titleLarge: textTheme.titleLarge?.copyWith(color: AppColors.darkTextPrimary, fontWeight: FontWeight.w600),
        titleMedium: textTheme.titleMedium?.copyWith(color: AppColors.darkTextPrimary, fontWeight: FontWeight.w500),
        titleSmall: textTheme.titleSmall?.copyWith(color: AppColors.darkTextPrimary, fontWeight: FontWeight.w500),
        bodyLarge: textTheme.bodyLarge?.copyWith(color: AppColors.darkTextPrimary),
        bodyMedium: textTheme.bodyMedium?.copyWith(color: AppColors.darkTextPrimary),
        bodySmall: textTheme.bodySmall?.copyWith(color: AppColors.darkTextSecondary),
        labelLarge: textTheme.labelLarge?.copyWith(color: AppColors.darkTextPrimary),
        labelMedium: textTheme.labelMedium?.copyWith(color: AppColors.darkTextSecondary),
        labelSmall: textTheme.labelSmall?.copyWith(color: AppColors.darkTextSecondary),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.darkSurface,
        foregroundColor: AppColors.darkTextPrimary,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          color: AppColors.darkTextPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.darkSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.darkBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.darkBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.red),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.darkSurface,
        selectedColor: AppColors.primary,
        labelStyle: textTheme.labelMedium?.copyWith(color: AppColors.darkTextPrimary),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.darkBorder,
        thickness: 1,
      ),
      extensions: const <ThemeExtension<dynamic>>[
        StatusColors.dark,
      ],
    );
  }
}
