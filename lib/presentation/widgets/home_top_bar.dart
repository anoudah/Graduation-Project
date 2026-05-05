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
class HomeTopBar extends StatelessWidget {
  const HomeTopBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageProvider>(
      builder: (context, languageProvider, _) {
        
        bool isMobile = MediaQuery.of(context).size.width < 600;

        // =====================================================================
        // WIDGET DEFINITIONS
        // =====================================================================

        // 1. The Menu Button
        final Widget menuButton = Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: AppColors.textMain, size: 28),
            onPressed: () => Scaffold.of(context).openDrawer(),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(), 
          ),
        );

        // 2. The Wasel Branding (BILINGUAL & RESPONSIVE)
        final Widget branding = Text(
          languageProvider.isArabic ? "وَصِــــــــل" : "W A S E L", // Instantly swaps the text
          style: TextStyle(
            fontSize: isMobile ? 20 : 22, 
            fontWeight: FontWeight.w900,
            color: AppColors.primary,
            // Turns OFF spacing for Arabic so the letters connect properly
            letterSpacing: languageProvider.isArabic ? 0.0 : (isMobile ? 1.5 : 4.0), 
          ),
        );

        // 3. The Search Bar
        final Widget searchBar = Expanded(
          child: GestureDetector(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SearchScreen())),
            child: Container(
              height: 40, 
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 2))],
              ),
              child: IgnorePointer(
                child: Builder(
                  builder: (context) => TextField(
                    readOnly: true,
                    decoration: InputDecoration(
                      hintText: context.loc.search,
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
        );

        // 4. The Language Toggle
        final Widget languageToggle = Tooltip(
          message: languageProvider.isArabic ? 'English' : 'العربية',
          child: IconButton(
            icon: const Icon(Icons.language, color: AppColors.textMain, size: 24),
            onPressed: () => languageProvider.toggleLanguage(),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        );

        // 5. The Auth Section
        final Widget authSection = StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            if (snapshot.hasData && snapshot.data != null) {
              return GestureDetector(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ProfilePage(uid: snapshot.data!.uid))),
                child: CircleAvatar(
                  radius: isMobile ? 14 : 16, 
                  backgroundColor: AppColors.primary,
                  child: const Icon(Icons.person, color: Colors.white, size: 18),
                ),
              );
            }
            if (isMobile) {
              return IconButton(
                icon: const Icon(Icons.login, color: AppColors.primary, size: 24),
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginScreen())),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              );
            }
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
                  child: Builder(builder: (context) => Text(context.loc.login, style: const TextStyle(color: AppColors.textMain, fontWeight: FontWeight.bold, fontSize: 12))),
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
                  child: Builder(builder: (context) => Text(context.loc.signup, style: const TextStyle(fontSize: 12))),
                ),
              ],
            );
          },
        );

        // =====================================================================
        // RESPONSIVE LAYOUT ASSEMBLY
        // =====================================================================
        
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: isMobile 
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    branding, 
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        menuButton,
                        const SizedBox(width: 12),
                        searchBar, 
                        const SizedBox(width: 12),
                        languageToggle,
                        const SizedBox(width: 12),
                        authSection,
                      ],
                    ),
                  ],
                )
              : Row(
                  children: [
                    menuButton,
                    const SizedBox(width: 16),
                    branding,
                    const SizedBox(width: 24),
                    searchBar,
                    const SizedBox(width: 16),
                    languageToggle,
                    const SizedBox(width: 16),
                    authSection,
                  ],
                ),
        );
      },
    );
  }
}