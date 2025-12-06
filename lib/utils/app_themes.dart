import 'package:flutter/material.dart';

class AppThemes {
  // Light Theme Colors
  static const Color primaryColor = Color(0xFF00C853); // أخضر نيون
  static const Color secondaryColor = Color(0xFF2196F3); // أزرق
  static const Color accentColor = Color(0xFFFF9800); // برتقالي
  static const Color errorColor = Color(0xFFF44336); // أحمر
  static const Color successColor = Color(0xFF4CAF50); // أخضر
  static const Color warningColor = Color(0xFFFFC107); // أصفر
  static const Color infoColor = Color(0xFF2196F3); // أزرق
  
  static const Color lightBackground = Color(0xFFF8F9FA);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightTextPrimary = Color(0xFF212121);
  static const Color lightTextSecondary = Color(0xFF757575);
  static const Color lightDivider = Color(0xFFE0E0E0);
  
  // Dark Theme Colors
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkTextPrimary = Color(0xFFFFFFFF);
  static const Color darkTextSecondary = Color(0xFFB0B0B0);
  static const Color darkDivider = Color(0xFF333333);
  
  // Gradients
  static const Gradient primaryGradient = LinearGradient(
    colors: [Color(0xFF00C853), Color(0xFF64DD17)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  // Text Styles
  static const TextStyle headingLarge = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    height: 1.3,
  );
  
  static const TextStyle headingMedium = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    height: 1.3,
  );
  
  static const TextStyle headingSmall = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 1.3,
  );
  
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );
  
  static const TextStyle bodyMedium = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );
  
  static const TextStyle bodySmall = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );
  
  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.4,
  );
  
  // Light Theme
  static ThemeData get lightTheme {
    return ThemeData(
      // Colors
      brightness: Brightness.light,
      primaryColor: primaryColor,
      colorScheme: const ColorScheme.light(
        primary: primaryColor,
        secondary: secondaryColor,
        surface: lightSurface,
        background: lightBackground,
        error: errorColor,
      ),
      
      // Typography
      fontFamily: 'Cairo',
      textTheme: TextTheme(
        displayLarge: headingLarge.copyWith(color: lightTextPrimary),
        displayMedium: headingMedium.copyWith(color: lightTextPrimary),
        displaySmall: headingSmall.copyWith(color: lightTextPrimary),
        bodyLarge: bodyLarge.copyWith(color: lightTextPrimary),
        bodyMedium: bodyMedium.copyWith(color: lightTextPrimary),
        bodySmall: bodySmall.copyWith(color: lightTextSecondary),
        labelLarge: bodyMedium.copyWith(fontWeight: FontWeight.w600),
        labelMedium: bodySmall.copyWith(fontWeight: FontWeight.w600),
        labelSmall: caption,
      ),
      
      // Components
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: lightSurface,
        foregroundColor: lightTextPrimary,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: lightTextPrimary,
          fontFamily: 'Cairo',
        ),
      ),
      
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            fontFamily: 'Cairo',
          ),
        ),
      ),
      
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: lightSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: errorColor, width: 1),
        ),
        contentPadding: const EdgeInsets.all(16),
        hintStyle: const TextStyle(color: lightTextSecondary),
      ),
      
      cardTheme: CardTheme(
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        color: lightSurface,
      ),
      
      dividerTheme: const DividerThemeData(
        color: lightDivider,
        thickness: 1,
        space: 1,
      ),
    );
  }
  
  // Dark Theme
  static ThemeData get darkTheme {
    return lightTheme.copyWith(
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: primaryColor,
        secondary: secondaryColor,
        surface: darkSurface,
        background: darkBackground,
        error: errorColor,
      ),
      scaffoldBackgroundColor: darkBackground,
      cardColor: darkSurface,
      textTheme: TextTheme(
        displayLarge: headingLarge.copyWith(color: darkTextPrimary),
        displayMedium: headingMedium.copyWith(color: darkTextPrimary),
        displaySmall: headingSmall.copyWith(color: darkTextPrimary),
        bodyLarge: bodyLarge.copyWith(color: darkTextPrimary),
        bodyMedium: bodyMedium.copyWith(color: darkTextPrimary),
        bodySmall: bodySmall.copyWith(color: darkTextSecondary),
        labelLarge: bodyMedium.copyWith(fontWeight: FontWeight.w600),
        labelMedium: bodySmall.copyWith(fontWeight: FontWeight.w600),
        labelSmall: caption.copyWith(color: darkTextSecondary),
      ),
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: darkSurface,
        foregroundColor: darkTextPrimary,
      ),
      inputDecorationTheme: lightTheme.inputDecorationTheme.copyWith(
        fillColor: darkSurface,
        hintStyle: const TextStyle(color: darkTextSecondary),
      ),
      dividerTheme: const DividerThemeData(
        color: darkDivider,
        thickness: 1,
        space: 1,
      ),
    );
  }
  
  // Shadows
  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: Colors.black.withOpacity(0.05),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];
  
  static List<BoxShadow> get elevatedShadow => [
    BoxShadow(
      color: Colors.black.withOpacity(0.1),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ];
  
  // Border Radius
  static const double borderRadiusSmall = 8;
  static const double borderRadiusMedium = 12;
  static const double borderRadiusLarge = 16;
  static const double borderRadiusXLarge = 24;
}
