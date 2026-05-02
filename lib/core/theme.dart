import 'package:flutter/material.dart';

/// Centralized color palette for the Wasel App.
/// Call these using AppColors.primary, AppColors.background, etc.
class AppColors {
  // Brand Colors
  static const Color primary = Color(0xFF6B4B8A);       // Deep Purple
  static const Color primaryLight = Color(0xFFE8DDF5);  // Light Purple (used for Category avatars)
  static const Color background = Color(0xFFF6F0F0);    // Main scaffold background

  // Text Colors
  static const Color textMain = Color(0xFF333333);      // Dark grey/black for primary text
  static const Color textSecondary = Color(0xFF999999); // Medium grey for subtitles/descriptions
  static const Color textHint = Color(0xFFB0B0B0);      // Light grey for search bar hints
  static const Color white = Colors.white;

  // UI Element Colors
  static const Color iconGrey = Color(0xFF666666);      // Standard grey for unselected icons
  static const Color divider = Color(0xFFD0D0D0);       // For dividing lines and unselected slider dots
  static const Color avatarBg = Color(0xFFDDDDDD);      // Grey circle behind the profile icon
}

/// Centralized Text Styles for the Wasel App.
class AppTextStyles {
  // Section Headers (e.g., "Categories", "Near you")
  static const TextStyle sectionTitle = TextStyle(
    fontSize: 24, 
    fontWeight: FontWeight.bold, 
    color: AppColors.textMain,
    // Removed Poppins here so Flutter defaults to its native font + Noto fallback
  );

  // Hero Slider Text (Desktop)
  static const TextStyle heroDesktop = TextStyle(
    fontSize: 48, 
    fontWeight: FontWeight.bold, 
    color: AppColors.textMain, 
    height: 1.3,
  );

  // Hero Slider Text (Mobile)
  static const TextStyle heroMobile = TextStyle(
    fontSize: 28, 
    fontWeight: FontWeight.bold, 
    color: AppColors.textMain, 
    height: 1.3,
  );

  // Subtitles / Distances
  static const TextStyle subtitle = TextStyle(
    fontSize: 14, 
    color: AppColors.textSecondary,
  );
  
  // Standard Button Text
  static const TextStyle buttonText = TextStyle(
    fontSize: 16, 
    fontWeight: FontWeight.bold,
  );
}

/// Global Theme Configuration for the Wasel App.
/// Apply this in your main.dart file inside the MaterialApp widget!
class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      // Set the main background color
      scaffoldBackgroundColor: AppColors.background,
      
      // Use the deep purple as the primary seed color
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
      ),

      // THE MAGIC FIX: Tells Flutter to use this font for Arabic and the ⃁ symbol
      fontFamilyFallback: const ['NotoSansArabic', 'NotoSansSymbols'],

      // Optional: Clean up standard Material styling to match your matte aesthetic
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.textMain),
        centerTitle: true,
      ),
    );
  }
}