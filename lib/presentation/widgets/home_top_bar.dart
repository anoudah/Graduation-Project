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

class HomeTopBar extends StatelessWidget {
  const HomeTopBar({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. THE MAGIC RESPONSIVE CHECK
    bool isMobile = MediaQuery.of(context).size.width < 600;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          // 1. المنيو الجانبية
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu, color: AppColors.textMain, size: 28),
              onPressed: () => Scaffold.of(context).openDrawer(),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(), // Reduces default icon padding for more space
            ),
          ),
          const SizedBox(width: 16),

          // 2. شريط البحث
          Expanded(
            child: GestureDetector(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SearchScreen())),
              child: Container(
                height: 40, // Forces a nice compact height
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
                      // Center the text vertically by aligning contentPadding with the icon height
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
          
          // 3. Language Toggle Button
          Consumer<LanguageProvider>(
            builder: (context, languageProvider, _) {
              return Tooltip(
                message: languageProvider.isArabic ? 'English' : 'العربية',
                child: IconButton(
                  icon: const Icon(Icons.language, color: AppColors.textMain, size: 24),
                  onPressed: () {
                    languageProvider.toggleLanguage();
                  },
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              );
            },
          ),
          const SizedBox(width: 12),
          
          // 4. AUTH & RESPONSIVE BUTTONS
          StreamBuilder<User?>(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (context, snapshot) {
              // SCENARIO A: User IS logged in (Show Profile Picture)
              if (snapshot.hasData && snapshot.data != null) {
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context, 
                      MaterialPageRoute(builder: (context) => ProfilePage(uid: snapshot.data!.uid))
                    );
                  },
                  child: const CircleAvatar(
                    radius: 16, // Slightly smaller for mobile layout
                    backgroundColor: AppColors.primary,
                    child: Icon(Icons.person, color: Colors.white, size: 18),
                  ),
                );
              }

              // SCENARIO B: User is NOT logged in, AND is on a Phone
              if (isMobile) {
                return IconButton(
                  icon: const Icon(Icons.login, color: AppColors.primary, size: 24),
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginScreen())),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                );
              }

              // SCENARIO C: User is NOT logged in, AND is on the Web/Tablet
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
    );
  }
}