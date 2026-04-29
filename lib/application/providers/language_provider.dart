import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider extends ChangeNotifier {
  Locale _currentLocale = const Locale('en');
  
  Locale get currentLocale => _currentLocale;
  
  String get currentLanguage => _currentLocale.languageCode;
  
  bool get isArabic => _currentLocale.languageCode == 'ar';
  
  bool get isEnglish => _currentLocale.languageCode == 'en';

  LanguageProvider() {
    _loadLanguagePreference();
  }

  Future<void> _loadLanguagePreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedLanguage = prefs.getString('language_code') ?? 'en';
      _currentLocale = Locale(savedLanguage);
      notifyListeners();
    } catch (e) {
      print('Error loading language preference: $e');
    }
  }

  Future<void> setLanguage(String languageCode) async {
    if (languageCode != _currentLocale.languageCode) {
      try {
        _currentLocale = Locale(languageCode);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('language_code', languageCode);
        notifyListeners();
      } catch (e) {
        print('Error setting language: $e');
      }
    }
  }

  void toggleLanguage() {
    setLanguage(_currentLocale.languageCode == 'en' ? 'ar' : 'en');
  }
}
