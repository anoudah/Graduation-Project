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
    fontFamily: 'Poppins', // Add your font family here if you are using one!
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