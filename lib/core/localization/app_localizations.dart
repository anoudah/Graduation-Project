import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(Locale locale) {
    return AppLocalizations(locale);
  }

  // Home Screen
  String get home => locale.languageCode == 'ar' ? 'الرئيسية' : 'Home';
  String get search => locale.languageCode == 'ar' ? 'بحث' : 'Search';
  String get categories => locale.languageCode == 'ar' ? 'الفئات' : 'Categories';
  String get happeningNow => locale.languageCode == 'ar' ? 'يحدث الآن' : 'Happening Now';
  String get nearYou => locale.languageCode == 'ar' ? 'بالقرب منك' : 'Near You';
  String get recommended => locale.languageCode == 'ar' ? 'موصى به' : 'Recommended';
  
  // Navigation
  String get menu => locale.languageCode == 'ar' ? 'القائمة' : 'Menu';
  String get profile => locale.languageCode == 'ar' ? 'الملف الشخصي' : 'Profile';
  String get favorites => locale.languageCode == 'ar' ? 'المفضلة' : 'Favorites';
  String get logout => locale.languageCode == 'ar' ? 'تسجيل الخروج' : 'Logout';
  
  // Language
  String get language => locale.languageCode == 'ar' ? 'اللغة' : 'Language';
  String get englishOption => locale.languageCode == 'ar' ? 'English (الإنجليزية)' : 'English';
  String get arabicOption => locale.languageCode == 'ar' ? 'العربية' : 'Arabic (العربية)';
  String get switchLanguage => locale.languageCode == 'ar' ? 'تبديل إلى العربية' : 'Switch to English';
  String get login => locale.languageCode == 'ar' ? 'دخول' : 'Log in';
  String get signup => locale.languageCode == 'ar' ? 'إنشاء حساب' : 'Sign up';
  
  // Events
  String get eventDetails => locale.languageCode == 'ar' ? 'تفاصيل الحدث' : 'Event Details';
  String get noEventsFound => locale.languageCode == 'ar' ? 'لم يتم العثور على أحداث' : 'No Events Found';
  String get loadingEvents => locale.languageCode == 'ar' ? 'جاري تحميل الأحداث...' : 'Loading Events...';
  
  // Actions
  String get save => locale.languageCode == 'ar' ? 'حفظ' : 'Save';
  String get cancel => locale.languageCode == 'ar' ? 'إلغاء' : 'Cancel';
  String get delete => locale.languageCode == 'ar' ? 'حذف' : 'Delete';
  String get edit => locale.languageCode == 'ar' ? 'تعديل' : 'Edit';
  String get add => locale.languageCode == 'ar' ? 'إضافة' : 'Add';
  String get close => locale.languageCode == 'ar' ? 'إغلاق' : 'Close';
  String get seeMore => locale.languageCode == 'ar' ? 'عرض المزيد' : 'See more';
  
  // Messages
  String get welcome => locale.languageCode == 'ar' ? 'أهلا وسهلا' : 'Welcome';
  String get error => locale.languageCode == 'ar' ? 'خطأ' : 'Error';
  String get success => locale.languageCode == 'ar' ? 'نجاح' : 'Success';
  String get loading => locale.languageCode == 'ar' ? 'جاري التحميل...' : 'Loading...';
  
  // Chat
  String get chat => locale.languageCode == 'ar' ? 'محادثة' : 'Chat';
  String get sendMessage => locale.languageCode == 'ar' ? 'إرسال رسالة' : 'Send Message';
  String get typeYourMessage => locale.languageCode == 'ar' ? 'اكتب رسالتك...' : 'Type your message...';
  
  // Tours
  String get smartTour => locale.languageCode == 'ar' ? 'الجولة الذكية' : 'Smart Tour';
  String get viewTour => locale.languageCode == 'ar' ? 'عرض الجولة' : 'View Tour';
  String get letsGo => locale.languageCode == 'ar' ? 'هيا بنا' : "Let's go";
  
  // Contact
  String get contactUs => locale.languageCode == 'ar' ? 'اتصل بنا' : 'Contact Us';
  String get email => locale.languageCode == 'ar' ? 'البريد الإلكتروني' : 'Email';
  String get phone => locale.languageCode == 'ar' ? 'الهاتف' : 'Phone';
}
