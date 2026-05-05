import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart'; // NEW: Added Firebase Auth
import '../../core/theme.dart';
import '../../application/providers/language_provider.dart';
import '../../core/localization/app_localizations.dart';

// --- Screen Imports ---
import '../screens/profile.dart';
import '../screens/bookings_screen.dart';
import '../screens/favorites_screen.dart';
import '../screens/reminders.dart';
import '../screens/faq.dart';
import '../screens/contactus.dart';
import '../screens/login_screen.dart'; // NEW: Needed to redirect logged-out users

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageProvider>(
      builder: (context, languageProvider, _) {
        final localizations = AppLocalizations(languageProvider.currentLocale);
        return Drawer(
          backgroundColor: AppColors.background,
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              // The top colored part of the drawer
              DrawerHeader(
                decoration: const BoxDecoration(color: AppColors.primary),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const CircleAvatar(
                      radius: 30,
                      backgroundColor: AppColors.white,
                      child: Icon(
                        Icons.person,
                        size: 35,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      localizations.welcome,
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              // --- Navigation Menu Items ---

              // 1. SECURED PROFILE BUTTON
              ListTile(
                leading: const Icon(
                  Icons.person_outline,
                  color: AppColors.textMain,
                ),
                title: Text(
                  localizations.profile,
                  style: const TextStyle(
                    color: AppColors.textMain,
                    fontSize: 16,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context); // Closes the drawer first

                  final user = FirebaseAuth.instance.currentUser;

                  if (user == null) {
                    // SCENARIO A: Logged Out -> Show warning and go to Login
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Please log in to view your profile"),
                        backgroundColor: AppColors.primary,
                      ),
                    );
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginScreen(),
                      ),
                    );
                  } else {
                    // SCENARIO B: Logged In -> Go to Profile with their unique ID
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProfilePage(uid: user.uid),
                      ),
                    );
                  }
                },
              ),

              _buildSecuredDrawerTile(
                context,
                Icons.confirmation_number_outlined,
                'Bookings',
                const BookingsScreen(),
                'Please log in to view your bookings',
              ),

              // 2. STANDARD MENU BUTTONS
              _buildDrawerTile(
                context,
                Icons.favorite_border,
                localizations.favorites,
                const FavoritesScreen(),
              ),
              // In AppDrawer.dart
              _buildDrawerTile(
                context,
                Icons.notifications_none,
                localizations
                    .yourReminders, // Use 'yourReminders', not 'reminders'
                const RemindersScreen(),
              ),
              const Divider(),

              _buildDrawerTile(
                context,
                Icons.help_outline,
                localizations.faq,
                const FAQPage(),
              ),
              _buildDrawerTile(
                context,
                Icons.mail_outline,
                localizations.contactUs,
                const ContactUsScreen(),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Helper method to build a drawer button quickly
  Widget _buildDrawerTile(
    BuildContext context,
    IconData icon,
    String title,
    Widget destination,
  ) {
    return ListTile(
      leading: Icon(icon, color: AppColors.textMain),
      title: Text(
        title,
        style: const TextStyle(color: AppColors.textMain, fontSize: 16),
      ),
      onTap: () {
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => destination),
        );
      },
    );
  }

  Widget _buildSecuredDrawerTile(
    BuildContext context,
    IconData icon,
    String title,
    Widget destination,
    String loginMessage,
  ) {
    return ListTile(
      leading: Icon(icon, color: AppColors.textMain),
      title: Text(
        title,
        style: const TextStyle(color: AppColors.textMain, fontSize: 16),
      ),
      onTap: () {
        Navigator.pop(context);

        final user = FirebaseAuth.instance.currentUser;
        if (user == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(loginMessage),
              backgroundColor: AppColors.primary,
            ),
          );
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const LoginScreen()),
          );
          return;
        }

        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => destination),
        );
      },
    );
  }
}
