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
  
  // Categories
  String get libraries => locale.languageCode == 'ar' ? 'المكتبات' : 'Libraries';
  String get heritageTradition => locale.languageCode == 'ar' ? 'التراث والتقاليد' : 'Heritage and\nTradition';
  String get museums => locale.languageCode == 'ar' ? 'المتاحف' : 'Museums';
  String get conferencesForums => locale.languageCode == 'ar' ? 'المؤتمرات والمنتديات' : 'Conferences\nand Forums';
  String get culturalInstitutions => locale.languageCode == 'ar' ? 'المؤسسات الثقافية' : 'Cultural\nInstitutions';
  String get exhibitionConvention => locale.languageCode == 'ar' ? 'المعارض والمؤتمرات' : 'Exhibition and\nConvention';
  
  // Full category names
  String get librariesFull => locale.languageCode == 'ar' ? 'المكتبات' : 'Libraries';
  String get heritageTraditionFull => locale.languageCode == 'ar' ? 'التراث والتقاليد' : 'Heritage and Tradition';
  String get museumsFull => locale.languageCode == 'ar' ? 'المتاحف' : 'Museums';
  String get conferencesForumsFull => locale.languageCode == 'ar' ? 'المؤتمرات والمنتديات' : 'Conferences and Forums';
  String get culturalInstitutionsFull => locale.languageCode == 'ar' ? 'المؤسسات الثقافية' : 'Cultural Institutions';
  String get exhibitionConventionFull => locale.languageCode == 'ar' ? 'مركز المعارض والمؤتمرات' : 'Exhibition and Convention Centre';
  
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
  String get resetPassword => locale.languageCode == 'ar' ? 'إعادة تعيين كلمة المرور' : 'Reset Password';
  String get resetPasswordInstructions => locale.languageCode == 'ar' ? 'أدخل بريدك الإلكتروني لتلقي رابط إعادة تعيين كلمة المرور.' : 'Enter your email to receive a password reset link.';
  String get forgotPassword => locale.languageCode == 'ar' ? 'نسيت كلمة المرور؟' : 'Forgot Password?';
  String get send => locale.languageCode == 'ar' ? 'إرسال' : 'Send';
  String get resetLinkSent => locale.languageCode == 'ar' ? 'تم إرسال رابط إعادة التعيين! راجع بريدك الإلكتروني.' : 'Reset link sent! Check your email.';
  String get emailAddress => locale.languageCode == 'ar' ? 'البريد الإلكتروني' : 'Email Address';
  String get welcomeBack => locale.languageCode == 'ar' ? 'مرحبًا بعودتك!' : 'Welcome Back!';
  String get loginToYourAccount => locale.languageCode == 'ar' ? 'سجل الدخول إلى حسابك' : 'Login to your account';
  String get dontHaveAnAccount => locale.languageCode == 'ar' ? 'لا تملك حساباً؟' : "Don't have an account?";
  String get requiredField => locale.languageCode == 'ar' ? 'حقل مطلوب' : 'Required field';
  String get noUserFound => locale.languageCode == 'ar' ? 'لم يتم العثور على مستخدم بهذا البريد الإلكتروني' : 'No user found with this email';
  String get wrongPasswordProvided => locale.languageCode == 'ar' ? 'كلمة المرور المدخلة خاطئة' : 'Wrong password provided';
  String get stepOne => locale.languageCode == 'ar' ? 'الخطوة الأولى' : 'Step One';
  String get fillInYourInformation => locale.languageCode == 'ar' ? 'املأ معلوماتك' : 'Fill in your information';
  String get fullName => locale.languageCode == 'ar' ? 'الاسم الكامل' : 'Full Name';
  String get password => locale.languageCode == 'ar' ? 'كلمة المرور' : 'Password';
  String get confirmPassword => locale.languageCode == 'ar' ? 'تأكيد كلمة المرور' : 'Confirm Password';
  String get referralCodeOptional => locale.languageCode == 'ar' ? 'رمز الإحالة (اختياري)' : 'Referral Code (Optional)';
  String get declareInfoTrue => locale.languageCode == 'ar' ? 'أقر بأن المعلومات المقدمة صحيحة ودقيقة' : 'I declare that the information provided is true and correct';
  String get agreeToTermsPrivacy => locale.languageCode == 'ar' ? 'لقد قرأت ووافقت على الشروط والأحكام وسياسة الخصوصية' : 'I have read and agree to the Terms & Conditions and Privacy Policy';
  String get pleaseAgreeToTerms => locale.languageCode == 'ar' ? 'يرجى الموافقة على الشروط والأحكام' : 'Please agree to the terms and conditions';
  String get passwordsDoNotMatch => locale.languageCode == 'ar' ? 'كلمات المرور غير متطابقة' : 'Passwords do not match';
  String get next => locale.languageCode == 'ar' ? 'التالي' : 'Next';
  String get alreadyHaveAnAccount => locale.languageCode == 'ar' ? 'هل لديك حساب بالفعل؟' : 'Already have an account?';
  
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
