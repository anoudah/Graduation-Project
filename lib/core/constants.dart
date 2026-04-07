//Stores fixed values to ensure consistency and maintainability.
//o	Example: const String appName = "Wasel App";
//o	Example: const String firebaseEventsCollection = "events";
import 'package:flutter/material.dart';
class AppConstants {
  //Wasel AI URL
  static const String aiBaseUrl = 'https://marilyn-sodless-margeret.ngrok-free.dev';
}
class AppColors {
  static const Color primaryPurple = Color(0xFF6B4B8A);
  static const Color background = Color(0xFFF6F0F0);
  static const Color textDark = Color(0xFF333333);
}

class AppStyles {
  static List<BoxShadow> commonShadow = [
    BoxShadow(
      color: Colors.black.withOpacity(0.05),
      blurRadius: 10,
      offset: const Offset(0, 4),
    ),
  ];
}

