import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../application/providers/language_provider.dart';
import '../../core/localization/app_localizations.dart';

// --- Screen Imports ---
// We import these here so the drawer can navigate to them
import '../screens/profile.dart';
import '../screens/favorites_screen.dart';
import '../screens/Reminders.dart';
import '../screens/faq.dart';
import '../screens/contactus.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageProvider>(
      builder: (context, languageProvider, _) {
        final localizations = AppLocalizations.of(languageProvider.currentLocale);
        
        return Drawer(
          backgroundColor: AppColors.background,
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              // The top colored part of the drawer
              DrawerHeader(
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const CircleAvatar(
                      radius: 30,
                      backgroundColor: AppColors.white,
                      child: Icon(Icons.person, size: 35, color: AppColors.primary),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      localizations.welcome,
                      style: const TextStyle(
                        color: AppColors.white, 
                        fontSize: 18, 
                        fontWeight: FontWeight.bold
                      ),
                    ),
                  ],
                ),
              ),
              
              // --- Navigation Menu Items ---
              _buildDrawerTile(context, Icons.person_outline, localizations.profile, const ProfilePage()),
              _buildDrawerTile(context, Icons.favorite_border, localizations.favorites, const FavoritesScreen()),
              _buildDrawerTile(context, Icons.notifications_none, localizations.nearYou, const RemindersScreen()),
              
              const Divider(), // A subtle line to separate sections
              
              _buildDrawerTile(context, Icons.help_outline, localizations.contactUs, const FAQPage()),
              _buildDrawerTile(context, Icons.mail_outline, localizations.contactUs, const ContactUsScreen()),
            ],
          ),
        );
      },
    );
  }

  /// Helper method to build a drawer button quickly
  Widget _buildDrawerTile(BuildContext context, IconData icon, String title, Widget destination) {
    return ListTile(
      leading: Icon(icon, color: AppColors.textMain),
      title: Text(
        title, 
        style: const TextStyle(color: AppColors.textMain, fontSize: 16)
      ),
      onTap: () {
        Navigator.pop(context); // Closes the drawer before navigating
        Navigator.push(
          context, 
          MaterialPageRoute(builder: (context) => destination)
        );
      },
    );
  }
}