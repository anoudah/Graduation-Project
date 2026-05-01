import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app_localizations.dart';
import '../../application/providers/language_provider.dart';

extension LocalizationExtension on BuildContext {
  /// Easy access to localization strings
  /// Usage: context.loc.home (instead of AppLocalizations.of(...).home)
  AppLocalizations get loc {
    // 1. We must use 'watch' so the UI rebuilds when the user changes the language!
    watch<LanguageProvider>(); 
    
    // 2. Standard AppLocalizations usually takes the context ('this'), not the locale.
    return AppLocalizations.of(this);
    return AppLocalizations.of(this);
  }
  
  /// Check if current language is Arabic
  bool get isArabic => watch<LanguageProvider>().isArabic;
  
  /// Check if current language is English
  bool get isEnglish => watch<LanguageProvider>().isEnglish;
}