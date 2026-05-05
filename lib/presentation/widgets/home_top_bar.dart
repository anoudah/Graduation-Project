import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../application/providers/language_provider.dart';
import '../../core/localization/localization_extension.dart';
import '../screens/search.dart';
import '../screens/login_screen.dart'; 
import '../screens/signup_screen.dart';
import '../screens/profile.dart'; 

/// A universal, responsive top navigation bar for the Wasel application.
/// 
/// This widget acts as the primary control center for the user, providing access to:
/// 1. The side navigation menu (Drawer).
/// 2. The global search functionality.
/// 3. App-wide language toggling (Arabic/English).
/// 4. Dynamic authentication states (Login/Signup vs. User Profile).
///
/// It uses a [Column] layout to prominently display the Wasel branding centered 
/// above the interactive controls.
class HomeTopBar extends StatelessWidget {
  const HomeTopBar({super.key});

  @override
  Widget build(BuildContext context) {
    // We wrap the entire bar in a Consumer to instantly rebuild the UI 
    // whenever the user switches between English and Arabic.
    return Consumer<LanguageProvider>(
      builder: (context, languageProvider, _) {
        
        // =================================================================
        // RESPONSIVE DESIGN CHECK
        // Determines if the user is on a small screen (phone) or large screen (web/tablet).
        // We use 600 pixels as the standard breakpoint for mobile interfaces.
        // =================================================================
        bool isMobile = MediaQuery.of(context).size.width < 600;

        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
          // We use a Column here to stack the Branding Text on top of the Action Buttons.
          // MainAxisSize.min ensures the column doesn't stretch and take up the whole screen.
          child: Column(
            mainAxisSize: MainAxisSize.min, 
            children: [
              
              // =================================================================
              // 1. BRANDING HEADER
              // =================================================================
              Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: const Text(
                  "W A S E L", 
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: AppColors.primary,
                    letterSpacing: 4.0, // Widens the text for a premium, airy aesthetic
                  ),
                ),
              ),
              
              // =================================================================
              // 2. THE INTERACTIVE ACTION ROW
              // Contains the Menu, Search, Language, and Auth controls side-by-side.
              // =================================================================
              Row(
                children: [
                  
                  // --- A. THE HAMBURGER MENU ---
                  // We MUST wrap this in a Builder. The Scaffold (which holds the Drawer) 
                  // is created further up the widget tree. The Builder gives us the correct 
                  // context to "reach up" and tell the Scaffold to open the menu.
                  Builder(
                    builder: (context) => IconButton(
                      icon: const Icon(Icons.menu, color: AppColors.textMain, size: 28),
                      onPressed: () => Scaffold.of(context).openDrawer(),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(), // Removes excess default padding
                    ),
                  ),
                  const SizedBox(width: 16),

                  // --- B. THE SEARCH BAR ---
                  // Wrapped in an Expanded widget so it takes up all remaining horizontal 
                  // space between the menu icon and the buttons on the right.
                  Expanded(
                    child: GestureDetector(
                      // Tapping anywhere on the bar pushes the user to the dedicated Search Screen
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SearchScreen())),
                      child: Container(
                        height: 40, // Fixed height for a sleek look
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 2))],
                        ),
                        // IgnorePointer prevents the keyboard from popping up on this screen;
                        // we only want it to act as a button that takes them to the *real* search page.
                        child: IgnorePointer(
                          child: Builder(
                            builder: (context) => TextField(
                              readOnly: true,
                              decoration: InputDecoration(
                                hintText: context.loc.search, // Localized hint text
                                hintStyle: const TextStyle(color: AppColors.textHint, fontSize: 14),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(vertical: 12), 
                                prefixIcon: const Icon(Icons.search, color: AppColors.iconGrey, size: 20),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  
                  // --- C. LANGUAGE TOGGLE ---
                  Tooltip(
                    message: languageProvider.isArabic ? 'English' : 'العربية',
                    child: IconButton(
                      icon: const Icon(Icons.language, color: AppColors.textMain, size: 24),
                      onPressed: () {
                        languageProvider.toggleLanguage();
                      },
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  
                  // --- D. DYNAMIC AUTHENTICATION SECTION ---
                  // StreamBuilder continuously listens to Firebase. If the user logs in 
                  // or logs out, this specific piece of the UI updates instantly without 
                  // needing to reload the whole page.
                  StreamBuilder<User?>(
                    stream: FirebaseAuth.instance.authStateChanges(),
                    builder: (context, snapshot) {
                      
                      // SCENARIO 1: User is Successfully Logged In
                      // Show their profile picture/avatar.
                      if (snapshot.hasData && snapshot.data != null) {
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context, 
                              MaterialPageRoute(builder: (context) => ProfilePage(uid: snapshot.data!.uid))
                            );
                          },
                          child: const CircleAvatar(
                            radius: 16, 
                            backgroundColor: AppColors.primary,
                            child: Icon(Icons.person, color: Colors.white, size: 18),
                          ),
                        );
                      }

                      // SCENARIO 2: Guest User on a Mobile Phone
                      // Space is tight, so we only show a small Login Icon.
                      if (isMobile) {
                        return IconButton(
                          icon: const Icon(Icons.login, color: AppColors.primary, size: 24),
                          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginScreen())),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        );
                      }

                      // SCENARIO 3: Guest User on a Desktop/Tablet
                      // We have plenty of room, so we show full text buttons for Login and Sign Up.
                      return Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginScreen())),
                            style: TextButton.styleFrom(
                              minimumSize: Size.zero,
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: Builder(
                              builder: (context) => Text(
                                context.loc.login,
                                style: const TextStyle(color: AppColors.textMain, fontWeight: FontWeight.bold, fontSize: 12)
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          ElevatedButton(
                            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SignUpScreen())),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: AppColors.white,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: Builder(
                              builder: (context) => Text(context.loc.signup, style: const TextStyle(fontSize: 12)),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}