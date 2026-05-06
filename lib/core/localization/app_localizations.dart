import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return AppLocalizations(Localizations.localeOf(context));
  }

  // Home Screen
  String get home => locale.languageCode == 'ar' ? 'الرئيسية' : 'Home';
  String get search => locale.languageCode == 'ar' ? 'بحث' : 'Search';
  String get categories =>
      locale.languageCode == 'ar' ? 'الفئات' : 'Categories';
  String get happeningNow =>
      locale.languageCode == 'ar' ? 'يحدث الآن' : 'Happening Now';
  String get nearYou => locale.languageCode == 'ar' ? 'بالقرب منك' : 'Near You';
  String get recommended =>
      locale.languageCode == 'ar' ? 'موصى به' : 'Recommended';

  // Categories
  String get libraries =>
      locale.languageCode == 'ar' ? 'المكتبات' : 'Libraries';
  String get heritageTradition => locale.languageCode == 'ar'
      ? 'التراث والتقاليد'
      : 'Heritage and\nTradition';
  String get museums => locale.languageCode == 'ar' ? 'المتاحف' : 'Museums';
  String get conferencesForums => locale.languageCode == 'ar'
      ? 'المؤتمرات والمنتديات'
      : 'Conferences\nand Forums';
  String get culturalInstitutions => locale.languageCode == 'ar'
      ? 'المؤسسات الثقافية'
      : 'Cultural\nInstitutions';
  String get exhibitionConvention => locale.languageCode == 'ar'
      ? 'المعارض والمؤتمرات'
      : 'Exhibition and\nConvention';

  // Full category names
  String get librariesFull =>
      locale.languageCode == 'ar' ? 'المكتبات' : 'Libraries';
  String get heritageTraditionFull => locale.languageCode == 'ar'
      ? 'التراث والتقاليد'
      : 'Heritage and Tradition';
  String get museumsFull => locale.languageCode == 'ar' ? 'المتاحف' : 'Museums';
  String get conferencesForumsFull => locale.languageCode == 'ar'
      ? 'المؤتمرات والمنتديات'
      : 'Conferences and Forums';
  String get culturalInstitutionsFull => locale.languageCode == 'ar'
      ? 'المؤسسات الثقافية'
      : 'Cultural Institutions';
  String get exhibitionConventionFull => locale.languageCode == 'ar'
      ? 'مركز المعارض والمؤتمرات'
      : 'Exhibition and Convention Centre';

  // Navigation
  String get menu => locale.languageCode == 'ar' ? 'القائمة' : 'Menu';
  String get profile =>
      locale.languageCode == 'ar' ? 'الملف الشخصي' : 'Profile';
  String get favorites => locale.languageCode == 'ar' ? 'المفضلة' : 'Favorites';
  String get logout => locale.languageCode == 'ar' ? 'تسجيل الخروج' : 'Logout';

  // Language
  String get language => locale.languageCode == 'ar' ? 'اللغة' : 'Language';
  String get englishOption =>
      locale.languageCode == 'ar' ? 'English (الإنجليزية)' : 'English';
  String get arabicOption =>
      locale.languageCode == 'ar' ? 'العربية' : 'Arabic (العربية)';
  String get switchLanguage =>
      locale.languageCode == 'ar' ? 'تبديل إلى العربية' : 'Switch to English';
  String get login => locale.languageCode == 'ar' ? 'دخول' : 'Log in';
  String get signup => locale.languageCode == 'ar' ? 'إنشاء حساب' : 'Sign up';
  String get resetPassword => locale.languageCode == 'ar'
      ? 'إعادة تعيين كلمة المرور'
      : 'Reset Password';
  String get resetPasswordInstructions => locale.languageCode == 'ar'
      ? 'أدخل بريدك الإلكتروني لتلقي رابط إعادة تعيين كلمة المرور.'
      : 'Enter your email to receive a password reset link.';
  String get forgotPassword =>
      locale.languageCode == 'ar' ? 'نسيت كلمة المرور؟' : 'Forgot Password?';
  String get send => locale.languageCode == 'ar' ? 'إرسال' : 'Send';
  String get resetLinkSent => locale.languageCode == 'ar'
      ? 'تم إرسال رابط إعادة التعيين! راجع بريدك الإلكتروني.'
      : 'Reset link sent! Check your email.';
  String get emailAddress =>
      locale.languageCode == 'ar' ? 'البريد الإلكتروني' : 'Email Address';
  String get welcomeBack =>
      locale.languageCode == 'ar' ? 'مرحبًا بعودتك!' : 'Welcome Back!';
  String get loginToYourAccount => locale.languageCode == 'ar'
      ? 'سجل الدخول إلى حسابك'
      : 'Login to your account';
  String get dontHaveAnAccount => locale.languageCode == 'ar'
      ? 'لا تملك حساباً؟'
      : "Don't have an account?";
  String get requiredField =>
      locale.languageCode == 'ar' ? 'حقل مطلوب' : 'Required field';
  String get noUserFound => locale.languageCode == 'ar'
      ? 'لم يتم العثور على مستخدم بهذا البريد الإلكتروني'
      : 'No user found with this email';
  String get wrongPasswordProvided => locale.languageCode == 'ar'
      ? 'كلمة المرور المدخلة خاطئة'
      : 'Wrong password provided';
  String get stepOne =>
      locale.languageCode == 'ar' ? 'الخطوة الأولى' : 'Step One';
  String get fillInYourInformation => locale.languageCode == 'ar'
      ? 'املأ معلوماتك'
      : 'Fill in your information';
  String get fullName =>
      locale.languageCode == 'ar' ? 'الاسم الكامل' : 'Full Name';
  String get password =>
      locale.languageCode == 'ar' ? 'كلمة المرور' : 'Password';
  String get confirmPassword =>
      locale.languageCode == 'ar' ? 'تأكيد كلمة المرور' : 'Confirm Password';
  String get referralCodeOptional => locale.languageCode == 'ar'
      ? 'رمز الإحالة (اختياري)'
      : 'Referral Code (Optional)';
  String get declareInfoTrue => locale.languageCode == 'ar'
      ? 'أقر بأن المعلومات المقدمة صحيحة ودقيقة'
      : 'I declare that the information provided is true and correct';
  String get agreeToTermsPrivacy => locale.languageCode == 'ar'
      ? 'لقد قرأت ووافقت على الشروط والأحكام وسياسة الخصوصية'
      : 'I have read and agree to the Terms & Conditions and Privacy Policy';
  String get pleaseAgreeToTerms => locale.languageCode == 'ar'
      ? 'يرجى الموافقة على الشروط والأحكام'
      : 'Please agree to the terms and conditions';
  String get passwordsDoNotMatch => locale.languageCode == 'ar'
      ? 'كلمات المرور غير متطابقة'
      : 'Passwords do not match';
  String get next => locale.languageCode == 'ar' ? 'التالي' : 'Next';
  String get alreadyHaveAnAccount => locale.languageCode == 'ar'
      ? 'هل لديك حساب بالفعل؟'
      : 'Already have an account?';

  // Events
  String get eventDetails =>
      locale.languageCode == 'ar' ? 'تفاصيل الحدث' : 'Event Details';
  String get noEventsFound => locale.languageCode == 'ar'
      ? 'لم يتم العثور على أحداث'
      : 'No Events Found';
  String get loadingEvents => locale.languageCode == 'ar'
      ? 'جاري تحميل الأحداث...'
      : 'Loading Events...';

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
  String get loading =>
      locale.languageCode == 'ar' ? 'جاري التحميل...' : 'Loading...';

  // Chat
  String get chat => locale.languageCode == 'ar' ? 'محادثة' : 'Chat';
  String get sendMessage =>
      locale.languageCode == 'ar' ? 'إرسال رسالة' : 'Send Message';
  String get typeYourMessage =>
      locale.languageCode == 'ar' ? 'اكتب رسالتك...' : 'Type your message...';

  // Tours
  String get smartTour =>
      locale.languageCode == 'ar' ? 'الجولة الذكية' : 'Smart Tour';
  String get viewTour =>
      locale.languageCode == 'ar' ? 'عرض الجولة' : 'View Tour';
  String get letsGo => locale.languageCode == 'ar' ? 'هيا بنا' : "Let's go";

  // Contact
  String get contactUs =>
      locale.languageCode == 'ar' ? 'اتصل بنا' : 'Contact Us';
  String get faq => locale.languageCode == 'ar' ? 'الأسئلة الشائعة' : 'FAQ';
  String get email =>
      locale.languageCode == 'ar' ? 'البريد الإلكتروني' : 'Email';
  String get phone => locale.languageCode == 'ar' ? 'الهاتف' : 'Phone';
  String get getInTouch =>
      locale.languageCode == 'ar' ? 'تواصل معنا' : 'Get in touch';
  String get yourMessage =>
      locale.languageCode == 'ar' ? 'رسالتك' : 'Your Message';
  String get pleaseFillAllFields => locale.languageCode == 'ar'
      ? 'يرجى ملء جميع الحقول'
      : 'Please fill in all fields';
  String get messageSentSuccessfully => locale.languageCode == 'ar'
      ? 'تم إرسال رسالتك بنجاح!'
      : 'Your message has been sent successfully!';
  String get failedToSendMessage => locale.languageCode == 'ar'
      ? 'فشل في إرسال الرسالة'
      : 'Failed to send message';

  // FAQ
  String get noQuestionsAvailable => locale.languageCode == 'ar'
      ? 'لا توجد أسئلة متاحة في الوقت الحالي.'
      : 'No questions available at the moment.';

  // Near You
  String get couldNotLoadMapData => locale.languageCode == 'ar'
      ? 'تعذر تحميل بيانات الخريطة.'
      : 'Could not load map data.';
  String get locationUnavailable =>
      locale.languageCode == 'ar' ? 'الموقع غير متاح' : 'Location unavailable';
  String get navigate => locale.languageCode == 'ar' ? 'التنقل' : 'Navigate';
  String get unknownLocation =>
      locale.languageCode == 'ar' ? 'موقع غير معروف' : 'Unknown Location';

  // Smart Tour
  String get yourSmartTourPlan =>
      locale.languageCode == 'ar' ? 'خطة جولتك الذكية' : 'Your Smart Tour Plan';
  String get tourGeneratedByAI => locale.languageCode == 'ar'
      ? 'تم إنشاء هذه الجولة بواسطة الذكاء الاصطناعي بناءً على اهتمامك بالتراث والذكاء الاصطناعي.'
      : 'This tour was generated by AI based on your interest in Heritage and AI.';
  String get partOfTour =>
      locale.languageCode == 'ar' ? 'جزء من الجولة' : 'Part of Tour';
  String get regeneratePlan =>
      locale.languageCode == 'ar' ? 'إعادة إنشاء الخطة' : 'Regenerate Plan';

  // Categories
  String get waselAICalculatingCrowds => locale.languageCode == 'ar'
      ? 'يقوم ذكاء واصل بحساب الحشود الحية...'
      : 'Wasel AI is calculating live crowds...';
  String get noEventsFoundForCategory => locale.languageCode == 'ar'
      ? 'لم يتم العثور على أحداث لهذه الفئة.'
      : 'No events found for this category.';
  String get placesAvailable =>
      locale.languageCode == 'ar' ? 'أماكن متاحة' : 'places available';

  // Chat
  String get helloWaselGuide => locale.languageCode == 'ar'
      ? 'مرحبا! أنا دليلك الثقافي واصل. كيف يمكنني مساعدتك في استكشاف الرياض اليوم؟'
      : 'Hello! I am your Wasel cultural guide. How can I help you explore Riyadh today?';
  String get askWaselAI =>
      locale.languageCode == 'ar' ? 'اسأل ذكاء واصل' : 'Ask Wasel AI';
  String get lostConnection => locale.languageCode == 'ar'
      ? 'عذراً، فقدت الاتصال بالخادم.'
      : 'Sorry, I lost connection to the server.';

  // Event Details
  String get pleaseLoginToInteract => locale.languageCode == 'ar'
      ? 'يرجى تسجيل الدخول للتفاعل'
      : 'Please log in to interact';
  String get about => locale.languageCode == 'ar' ? 'حول' : 'About';
  String get details => locale.languageCode == 'ar' ? 'التفاصيل' : 'Details';
  String get schedule => locale.languageCode == 'ar' ? 'الجدول' : 'Schedule';
  String get price => locale.languageCode == 'ar' ? 'السعر' : 'Price';
  String get suggestRoute =>
      locale.languageCode == 'ar' ? 'اقتراح مسار' : 'Suggest a route';
  String get writeAReview =>
      locale.languageCode == 'ar' ? 'اكتب مراجعة' : 'Write a Review';
  String get shareYourExperience => locale.languageCode == 'ar'
      ? 'شارك تجربتك...'
      : 'Share your experience...';
  String get dateAndTime =>
      locale.languageCode == 'ar' ? 'التاريخ والوقت' : 'Date & Time';
  String get ticketPrice =>
      locale.languageCode == 'ar' ? 'سعر التذكرة' : 'Ticket Price';
  String get freeEntry =>
      locale.languageCode == 'ar' ? 'دخول مجاني' : 'Free Entry';
  String get location => locale.languageCode == 'ar' ? 'الموقع' : 'Location';
  String get navigateToEvent =>
      locale.languageCode == 'ar' ? 'التنقل إلى الحدث' : 'Navigate to Event';
  String get reviewSubmittedSuccessfully => locale.languageCode == 'ar'
      ? 'تم إرسال المراجعة بنجاح!'
      : 'Review submitted successfully!';
  String get attending => locale.languageCode == 'ar' ? 'حاضر' : 'Attending';
  String get imAttending =>
      locale.languageCode == 'ar' ? 'سأحضر' : 'I\'m attending';
  String get bookNow => locale.languageCode == 'ar' ? 'احجز الآن' : 'Book Now';
  String get noTitle =>
      locale.languageCode == 'ar' ? 'لا يوجد عنوان' : 'No Title';
  String get toBeAnnounced =>
      locale.languageCode == 'ar' ? 'سيتم الإعلان عنه' : 'To Be Announced';
  String get noDescription =>
      locale.languageCode == 'ar' ? 'لا يوجد وصف.' : 'No description.';

  // Month abbreviations
  String get jan => locale.languageCode == 'ar' ? 'يناير' : 'Jan';
  String get feb => locale.languageCode == 'ar' ? 'فبراير' : 'Feb';
  String get mar => locale.languageCode == 'ar' ? 'مارس' : 'Mar';
  String get apr => locale.languageCode == 'ar' ? 'أبريل' : 'Apr';
  String get may => locale.languageCode == 'ar' ? 'مايو' : 'May';
  String get jun => locale.languageCode == 'ar' ? 'يونيو' : 'Jun';
  String get jul => locale.languageCode == 'ar' ? 'يوليو' : 'Jul';
  String get aug => locale.languageCode == 'ar' ? 'أغسطس' : 'Aug';
  String get sep => locale.languageCode == 'ar' ? 'سبتمبر' : 'Sep';
  String get oct => locale.languageCode == 'ar' ? 'أكتوبر' : 'Oct';
  String get nov => locale.languageCode == 'ar' ? 'نوفمبر' : 'Nov';
  String get dec => locale.languageCode == 'ar' ? 'ديسمبر' : 'Dec';

  // Favorites
  String get myFavorites =>
      locale.languageCode == 'ar' ? 'مفضلتي' : 'My Favorites';
  String get pleaseLoginToSeeFavorites => locale.languageCode == 'ar'
      ? 'يرجى تسجيل الدخول لرؤية المفضلة'
      : 'Please login to see favorites';
  String get noFavoritesFound => locale.languageCode == 'ar'
      ? 'لم يتم العثور على مفضلة'
      : 'No favorites found';

  // Interests
  String get welcomeToWasel =>
      locale.languageCode == 'ar' ? 'مرحباً بك في واصل!' : 'Welcome to Wasel!';
  String get pickYourInterests => locale.languageCode == 'ar'
      ? 'اختر اهتماماتك للحصول على خطة جولة مخصصة بالذكاء الاصطناعي.'
      : 'Pick your interests to get a personalized AI tour plan.';
  String get heritage => locale.languageCode == 'ar' ? 'التراث' : 'Heritage';
  String get arts => locale.languageCode == 'ar' ? 'الفنون' : 'Arts';
  String get technology =>
      locale.languageCode == 'ar' ? 'التكنولوجيا' : 'Technology';
  String get conferences =>
      locale.languageCode == 'ar' ? 'المؤتمرات' : 'Conferences';
  String get traditionalFood =>
      locale.languageCode == 'ar' ? 'الطعام التقليدي' : 'Traditional Food';
  String get festivals =>
      locale.languageCode == 'ar' ? 'المهرجانات' : 'Festivals';
  String get pleaseLoginFirst => locale.languageCode == 'ar'
      ? 'يرجى تسجيل الدخول أولاً'
      : 'Please login first';
  String get databaseError =>
      locale.languageCode == 'ar' ? 'خطأ في قاعدة البيانات' : 'Database Error';
  String get continueToHome => locale.languageCode == 'ar'
      ? 'المتابعة إلى الرئيسية'
      : 'Continue to Home';

  // Museums
  String get museumsInRiyadh =>
      locale.languageCode == 'ar' ? 'المتاحف في الرياض' : 'Museums in Riyadh';
  String get connectionError =>
      locale.languageCode == 'ar' ? 'خطأ في الاتصال' : 'Connection Error';
  String get noMuseumsFound => locale.languageCode == 'ar'
      ? 'لم يتم العثور على متاحف في قاعدة البيانات في الوقت الحالي.'
      : 'No museums found in the database at this time.';
  String get unknownMuseum =>
      locale.languageCode == 'ar' ? 'متحف غير معروف' : 'Unknown Museum';
  String get noDescriptionAvailable => locale.languageCode == 'ar'
      ? 'لا يوجد وصف متاح.'
      : 'No description available.';
  String get checkWebsite =>
      locale.languageCode == 'ar' ? 'تحقق من الموقع' : 'Check Website';
  String get free => locale.languageCode == 'ar' ? 'مجاني' : 'Free';
  String get calculatingRoute => locale.languageCode == 'ar'
      ? 'حساب أفضل طريق إلى'
      : 'Calculating the best route to';

  // Profile
  String get gender => locale.languageCode == 'ar' ? 'الجنس' : 'Gender';
  String get male => locale.languageCode == 'ar' ? 'ذكر' : 'Male';
  String get female => locale.languageCode == 'ar' ? 'أنثى' : 'Female';
  String get saveChanges =>
      locale.languageCode == 'ar' ? 'حفظ التغييرات' : 'Save Changes';
  String get profileUpdatedSuccessfully => locale.languageCode == 'ar'
      ? 'تم تحديث الملف الشخصي بنجاح!'
      : 'Profile updated successfully!';
  String get couldNotSaveChanges => locale.languageCode == 'ar'
      ? 'خطأ: تعذر حفظ التغييرات'
      : 'Error: Could not save changes';

  // Recommended
  String get noRecommendationsFound => locale.languageCode == 'ar'
      ? 'لم يتم العثور على توصيات.'
      : 'No recommendations found.';

  // Reminders
  String get yourReminders =>
      locale.languageCode == 'ar' ? 'تذكيراتك' : 'Reminders';
  String get noRemindersCurrently => locale.languageCode == 'ar'
      ? 'لا توجد تذكيرات حالياً'
      : 'No reminders currently';
  String get scheduleNotSet =>
      locale.languageCode == 'ar' ? 'لم يتم تحديد وقت' : 'Not scheduled';
  String get unknownEvent =>
      locale.languageCode == 'ar' ? 'فعالية غير معروفة' : 'Unknown event';
  String get timeNotSet =>
      locale.languageCode == 'ar' ? 'لم يتم تحديد وقت' : 'Time not set';

  // Route Suggestion
  String get aiRouteGenerator => locale.languageCode == 'ar'
      ? 'مولد المسار بالذكاء الاصطناعي'
      : 'AI Route Generator';
  String get designYourPerfectEvening => locale.languageCode == 'ar'
      ? 'صمم مساءك المثالي'
      : 'Design your perfect evening';
  String get whatAreYouInTheMoodFor => locale.languageCode == 'ar'
      ? 'ما الذي تشعر بالرغبة فيه؟'
      : 'What are you in the mood for?';
  String get heritageAndTradition => locale.languageCode == 'ar'
      ? 'التراث والتقاليد'
      : 'Heritage and Tradition';
  String get conferencesAndForums => locale.languageCode == 'ar'
      ? 'المؤتمرات والمنتديات'
      : 'Conferences and Forums';
  String get exhibitionAndConvention => locale.languageCode == 'ar'
      ? 'مركز المعارض والمؤتمرات'
      : 'Exhibition and Convention Centre';
  String get startTime =>
      locale.languageCode == 'ar' ? 'وقت البدء' : 'Start Time';
  String get duration => locale.languageCode == 'ar' ? 'المدة' : 'Duration';
  String get selectTourDuration =>
      locale.languageCode == 'ar' ? 'اختر مدة الجولة' : 'Select Tour Duration';
  String get hours => locale.languageCode == 'ar' ? 'ساعات' : 'Hours';
  String get waselAICalculatingTour => locale.languageCode == 'ar'
      ? 'يقوم ذكاء واصل بحساب حركة المرور وصنع جولتك المثالية...'
      : 'Wasel AI is calculating traffic and crafting your perfect tour...';
  String get yourCustomTour =>
      locale.languageCode == 'ar' ? 'جولتك المخصصة' : 'Your Custom Tour';
  String get estimatedTime =>
      locale.languageCode == 'ar' ? 'الوقت المقدر' : 'Estimated time';
  String get couldNotGenerateTour => locale.languageCode == 'ar'
      ? 'تعذر إنشاء الجولة. يرجى المحاولة مرة أخرى.'
      : 'Could not generate tour. Please try again.';
  String get generateSmartRoute =>
      locale.languageCode == 'ar' ? 'إنشاء مسار ذكي' : 'Generate Smart Route';
  String get startOver =>
      locale.languageCode == 'ar' ? 'البدء من جديد' : 'Start Over';

  // Smart Tour Screen
  String get yourSmartRoute =>
      locale.languageCode == 'ar' ? 'مسارك الذكي' : 'Your Smart Route';
  String get transit => locale.languageCode == 'ar' ? 'التنقل' : 'Transit';
  String get movingToNextDestination => locale.languageCode == 'ar'
      ? 'الانتقال إلى الوجهة التالية'
      : 'Moving to next destination';
  String get estimatedTimeLabel =>
      locale.languageCode == 'ar' ? 'الوقت المقدر' : 'Estimated time';
  String get freeTour =>
      locale.languageCode == 'ar' ? 'جولة مجانية' : 'Free Tour';
  String get estCost =>
      locale.languageCode == 'ar' ? 'التكلفة المقدرة' : 'Est. Cost';
  String get eventAddedToFavorites => locale.languageCode == 'ar'
      ? 'تم إضافة الحدث إلى المفضلة!'
      : 'Event added to your favorites!';
  String get couldNotOpenMaps => locale.languageCode == 'ar'
      ? 'تعذر فتح الخرائط.'
      : 'Could not open maps.';
  String get coordinatesNotAvailable => locale.languageCode == 'ar'
      ? 'الإحداثيات غير متاحة لهذا الموقع.'
      : 'Coordinates not available for this location.';
  String get event => locale.languageCode == 'ar' ? 'الحدث' : 'Event';
  String get aiSelectedPath => locale.languageCode == 'ar'
      ? 'المسار المختار بالذكاء الاصطناعي'
      : 'AI Selected Path';

  // Search
  String get searchMuseumsEvents => locale.languageCode == 'ar'
      ? 'البحث عن المتاحف والأحداث...'
      : 'Search museums, events...';
  String get connectionErrorServer => locale.languageCode == 'ar'
      ? 'خطأ في الاتصال. تأكد من تشغيل خادم Python!'
      : 'Connection error. Make sure your Python server is running!';
  String get noEventsFoundFor => locale.languageCode == 'ar'
      ? 'لم يتم العثور على أحداث لـ'
      : 'No events found for';
  String get exploreCategories =>
      locale.languageCode == 'ar' ? 'استكشف الفئات' : 'Explore Categories';
  String get toggleView =>
      locale.languageCode == 'ar' ? 'تبديل العرض' : 'Toggle View';
  String get minutes => locale.languageCode == 'ar' ? 'دقائق' : 'Minutes';

  // Verification
  String get enterCode =>
      locale.languageCode == 'ar' ? 'أدخل الرمز' : 'Enter Code';
  String get verify => locale.languageCode == 'ar' ? 'تحقق' : 'Verify';
  String get submit => locale.languageCode == 'ar' ? 'إرسال' : 'Submit';
  String get incorrectCode =>
      locale.languageCode == 'ar' ? 'رمز غير صحيح!' : 'Incorrect Code!';
  String get errorOccurred =>
      locale.languageCode == 'ar' ? 'حدث خطأ' : 'Error occurred';

  //what's happening now
  String get seeWhatIsHappening => locale.languageCode == 'ar'
      ? 'شاهد ما يحدث هنا'
      : 'SEE WHAT IS HAPPENING HERE';
  // --- إضافة الكلمات الجديدة هنا لترتيب الحوسة ---

  // نصوص تقييم الحشود (الزحمة)
  String get low => locale.languageCode == 'ar' ? 'منخفضة' : 'Low';
  String get medium => locale.languageCode == 'ar' ? 'متوسطة' : 'Medium';
  String get high => locale.languageCode == 'ar' ? 'عالية' : 'High';

  // نصوص إضافية للتعليقات
  String get reviews => locale.languageCode == 'ar' ? 'التعليقات' : 'Reviews';
  String get noReviewsYet =>
      locale.languageCode == 'ar' ? 'لا توجد تعليقات بعد' : 'No reviews yet';
  String get crowdStatus =>
      locale.languageCode == 'ar' ? 'حالة الزحمة' : 'Crowd Status';
  // نصوص التقييم وكتابة التعليق
  String get rating => locale.languageCode == 'ar' ? 'التقييم' : 'Rating';
  String get writeComment =>
      locale.languageCode == 'ar' ? 'اكتب تعليق' : 'Write a comment';
  String get yourReview =>
      locale.languageCode == 'ar' ? 'مراجعتك' : 'Your Review';
  String get submitReview =>
      locale.languageCode == 'ar' ? 'إرسال التقييم' : 'Submit Review';
  String get aiDriveTo => locale.languageCode == 'ar' ? 'القيادة إلى' : 'Drive to';
  String get aiUserLocation => locale.languageCode == 'ar' ? 'موقعك الحالي' : 'User Location';
  String get aiStartAt => locale.languageCode == 'ar' ? 'البدء من' : 'Start at'; // NEW
  String get aiBackToStartingPoint => locale.languageCode == 'ar' ? 'العودة إلى نقطة البداية' : 'Back to Starting Point';
  String get aiBackToCityHall => locale.languageCode == 'ar' ? 'العودة إلى أمانة منطقة الرياض' : 'Back to Riyadh City Hall';
  String get aiStartingPointDesc => locale.languageCode == 'ar' ? 'نقطة انطلاق الجولة' : 'Starting point of the tour';
  String get aiApprox => locale.languageCode == 'ar' ? 'حوالي' : 'Approx.';
  String get aiMinDrive => locale.languageCode == 'ar' ? 'دقيقة بالسيارة' : 'min drive based on distance';
  String get aiLibraryTransit => locale.languageCode == 'ar' ? 'التنقل للمكتبة' : 'Library transit';
  String get aiRiyadhCulturalTour => locale.languageCode == 'ar' ? 'جولة الرياض الثقافية' : 'Riyadh Cultural Tour';
  String get aiMuseumTour => locale.languageCode == 'ar' ? 'جولة متاحف الرياض الثقافية' : 'Riyadh Cultural Museum Tour'; // NEW
  String get aiCulturalTour => locale.languageCode == 'ar' ? 'جولة ثقافية' : 'Cultural Tour';
}