import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app_localizations.dart';
import '../../application/providers/language_provider.dart';

extension LocalizationExtension on BuildContext {
  /// Easy access to localization strings
  /// Usage: context.loc.home (instead of AppLocalizations.of(...).home)
  AppLocalizations get loc {
    final languageProvider = read<LanguageProvider>();
    return AppLocalizations.of(languageProvider.currentLocale);
  }
  
  /// Check if current language is Arabic
  bool get isArabic => read<LanguageProvider>().isArabic;
  
  /// Check if current language is English
  bool get isEnglish => read<LanguageProvider>().isEnglish;
}
