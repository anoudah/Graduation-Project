# Bilingual Support Guide (English & Arabic)

## Overview
Your Wasel app now supports both English and Arabic with automatic Right-to-Left (RTL) support for Arabic. The language preference is saved using SharedPreferences, so it persists across app sessions.

## Key Files Created/Modified

### 1. **Language Provider** (`lib/application/providers/language_provider.dart`)
- Manages the current language state
- Provides methods to change language
- Persists language preference to device storage
- Accessible through Provider package

### 2. **Localization Strings** (`lib/core/localization/app_localizations.dart`)
- Contains all English and Arabic translations
- Organized by feature (Home, Navigation, Events, Actions, Messages, Chat, Tours, Contact)
- Easy to add new translations

### 3. **Localization Extension** (`lib/core/localization/localization_extension.dart`)
- Provides convenient access to localization throughout the app
- Usage: `context.loc.home` instead of `AppLocalizations.of(...).home`
- Also provides `context.isArabic` and `context.isEnglish` helper properties

### 4. **Updated Main App** (`lib/main.dart`)
- Added `flutter_localizations` support
- Added LanguageProvider to MultiProvider
- Configured MaterialApp with locale settings
- Enables RTL for Arabic automatically

### 5. **Language Toggle Button** (`lib/presentation/widgets/home_top_bar.dart`)
- Added globe icon button in the top bar
- Clicking toggles between English and Arabic
- Shows tooltip with target language

## How to Use Localization in Your Screens

### Method 1: Using the Extension (Recommended)
```dart
import 'package:wasel/core/localization/localization_extension.dart';

// In your build method or anywhere with BuildContext access:
Text(context.loc.home)  // Instead of "Home" text
Text(context.loc.welcome)  // Instead of "Welcome" text

// Check current language
if (context.isArabic) {
  // Do something for Arabic
}
```

### Method 2: Using AppLocalizations Directly
```dart
import 'package:wasel/core/localization/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:wasel/application/providers/language_provider.dart';

// In your build method:
final languageProvider = context.read<LanguageProvider>();
final localizations = AppLocalizations.of(languageProvider.currentLocale);

Text(localizations.home)
```

## Adding New Translations

### Step 1: Add to `app_localizations.dart`
```dart
class AppLocalizations {
  // ... existing code ...
  
  // Add your new translation getter
  String get myNewString => locale.languageCode == 'ar' 
    ? 'النص العربي' 
    : 'English Text';
}
```

### Step 2: Use in Your Widget
```dart
Text(context.loc.myNewString)
```

## RTL Support
Arabic displays automatically in Right-to-Left (RTL) direction because:
- Flutter's `Locale('ar')` automatically enables RTL
- Material design localizations handle RTL layouts
- Text direction is handled automatically by Flutter

## Current Translations Available

### Home Screen
- `home` - الرئيسية / Home
- `search` - بحث / Search
- `categories` - الفئات / Categories
- `happeningNow` - يحدث الآن / Happening Now
- `nearYou` - بالقرب منك / Near You
- `recommended` - موصى به / Recommended

### Navigation
- `menu` - القائمة / Menu
- `profile` - الملف الشخصي / Profile
- `favorites` - المفضلة / Favorites
- `logout` - تسجيل الخروج / Logout

### Language
- `language` - اللغة / Language
- `englishOption` - English (الإنجليزية)
- `arabicOption` - العربية / Arabic (العربية)
- `switchLanguage` - تبديل إلى العربية / Switch to English

### Events
- `eventDetails` - تفاصيل الحدث / Event Details
- `noEventsFound` - لم يتم العثور على أحداث / No Events Found
- `loadingEvents` - جاري تحميل الأحداث... / Loading Events...

### Actions
- `save` - حفظ / Save
- `cancel` - إلغاء / Cancel
- `delete` - حذف / Delete
- `edit` - تعديل / Edit
- `add` - إضافة / Add
- `close` - إغلاق / Close

### Messages
- `welcome` - أهلا وسهلا / Welcome
- `error` - خطأ / Error
- `success` - نجاح / Success
- `loading` - جاري التحميل... / Loading...

### Chat
- `chat` - محادثة / Chat
- `sendMessage` - إرسال رسالة / Send Message
- `typeYourMessage` - اكتب رسالتك... / Type your message...

### Tours
- `smartTour` - الجولة الذكية / Smart Tour
- `viewTour` - عرض الجولة / View Tour

### Contact
- `contactUs` - اتصل بنا / Contact Us
- `email` - البريد الإلكتروني / Email
- `phone` - الهاتف / Phone

## Screens That Have Been Updated

### Partially Updated (Language Toggle Available)
- **Home Top Bar** - Language toggle button added
- **App Drawer** - Welcome message and menu items use localization

### Need to Update (Add localization strings)
To use localization in other screens, simply:
1. Add `import 'package:wasel/core/localization/localization_extension.dart';`
2. Replace hardcoded text with `context.loc.translation_key`

Example screens to update:
- Profile screen
- Favorites screen
- Event details screen
- Search screen
- And others...

## Dependencies Added
- `flutter_localizations` - Flutter's built-in localization support
- No additional external packages needed!

## Testing the Localization

1. **Run the app**: `flutter run`
2. **Click the globe icon** in the top bar
3. **App should:**
   - Switch between English and Arabic
   - Display Arabic text right-to-left
   - Show Arabic layout (menu items, buttons should align right)
   - Persist language preference on restart

## Troubleshooting

### Language isn't changing?
- Make sure the app is wrapped with `MultiProvider` that includes `LanguageProvider`
- Check that widgets are using `Consumer<LanguageProvider>` or similar to rebuild

### Text isn't displaying right-to-left?
- Verify locale is `Locale('ar')` not a custom locale
- Flutter handles RTL automatically when using proper locales

### Missing translation string?
- Add it to `app_localizations.dart` following the pattern:
```dart
String get myString => locale.languageCode == 'ar' 
  ? 'العربية' 
  : 'English';
```

## Next Steps
1. ✅ Core bilingual support implemented
2. ✅ Language toggle button added to home
3. ⏳ Update all screens to use localization strings (replace hardcoded text)
4. ⏳ Test on actual Arabic device/emulator for RTL rendering
5. ⏳ Consider adding more languages if needed

## Need Help?
Refer to the Flutter Localization documentation:
https://docs.flutter.dev/ui/accessibility-and-localization/internationalization
