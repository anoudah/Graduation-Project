import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../application/providers/language_provider.dart';

/// [BilingualHelper] serves as the bridge between the backend's flexible data
/// structure and the Flutter UI's requirement for static Strings.
class BilingualHelper {
  
  /// Resolves dynamic database fields into a locale-specific String.
  /// 
  /// Logic:
  /// 1. If [field] is a simple [String], it returns it (Backward Compatibility).
  /// 2. If [field] is a [Map], it checks the [LanguageProvider] state:
  ///    - Returns the 'ar' value if the app is in Arabic mode.
  ///    - Returns the 'en' value if the app is in English mode.
  /// 3. If a specific language key is missing, it falls back to the available language.
  static String getText(dynamic field, BuildContext context) {
    if (field == null) return "";

    // Handle legacy data or already-processed strings
    if (field is String) return field;

    // Handle the new 'Bilingual Map' structure from Firestore
    if (field is Map<String, dynamic> || field is Map<dynamic, dynamic>) {
      final isArabic = Provider.of<LanguageProvider>(context, listen: false).isArabic;

      // Prioritize the active locale, with secondary fallback logic
      if (isArabic && _isValid(field['ar'])) {
        return field['ar'].toString();
      } else if (_isValid(field['en'])) {
        return field['en'].toString();
      }
      
      // Safety: If preferred keys are missing, return the first available value
      return field.values.isNotEmpty ? field.values.first.toString() : "";
    }

    return field.toString();
  }

  /// Internal validation helper to ensure the map value is not empty or null.
  static bool _isValid(dynamic value) => 
      value != null && value.toString().trim().isNotEmpty;
}