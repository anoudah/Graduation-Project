import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // الإضافة الوحيدة هنا
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../application/providers/language_provider.dart';
import '../../core/localization/localization_extension.dart';
import '../screens/search.dart';
import '../screens/login_screen.dart'; 
import '../screens/signup_screen.dart';
import '../screens/profile.dart'; // تأكدي إن الاسم والمسار صح

class HomeTopBar extends StatelessWidget {
  const HomeTopBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          // 1. المنيو الجانبية (نفس كودك)
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu, color: AppColors.textMain, size: 28),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          ),
          const SizedBox(width: 16),

          // 2. شريط البحث (نفس كودك بالملي)
          Expanded(
            child: GestureDetector(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SearchScreen())),
              child: Container(
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
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        suffixIcon: const Icon(Icons.search, color: AppColors.iconGrey, size: 20),
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
                ),
              );
            },
          ),
          const SizedBox(width: 8),
          
          // 4. منطقة الأزرار (هنا أضفنا خاصية الإخفاء التلقائي)
          StreamBuilder<User?>(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (context, snapshot) {
              // لو سجل دخول: تروح الأزرار وتطلع أيقونة البروفايل
              if (snapshot.hasData && snapshot.data != null) {
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context, 
                      MaterialPageRoute(builder: (context) => ProfilePage(uid: snapshot.data!.uid))
                    );
                  },
                  child: const CircleAvatar(
                    radius: 18,
                    backgroundColor: AppColors.primary,
                    child: Icon(Icons.person, color: Colors.white, size: 20),
                  ),
                );
              }

              // لو ما سجل دخول: تطلع أزرارك الأصلية اللي في كودك
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