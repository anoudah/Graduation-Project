import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../screens/route_suggestion_screen.dart';
import '../../core/localization/localization_extension.dart';
import '../../application/providers/language_provider.dart';

class SmartTourBanner extends StatelessWidget {
  const SmartTourBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageProvider>(
      builder: (context, languageProvider, _) {
        return Padding(
          // Reduced outer padding slightly so the card has more room to breathe on screen
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            children: [
              const Divider(color: AppColors.divider, thickness: 1, height: 32),
              const SizedBox(height: 16),
              
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(24), // Softer, more modern corners
                  boxShadow: [
                    // Premium colored glow shadow instead of harsh black
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.08), 
                      blurRadius: 32, 
                      offset: const Offset(0, 12),
                    )
              ],
            ),
            child: Column(
              children: [
                // 1. THE FEATURE BADGE: Instantly tells the user this is a special/smart feature
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.auto_awesome, // The universal symbol for AI/Smart features
                    color: AppColors.primary, 
                    size: 32,
                  ),
                ),
                const SizedBox(height: 20),
                
                // 2. TYPOGRAPHY POLISH
                Builder(
                  builder: (context) => Text(
                    context.loc.smartTour, 
                    textAlign: TextAlign.center, 
                    style: const TextStyle(
                      fontSize: 22, 
                      fontWeight: FontWeight.w800, // Extra bold
                      letterSpacing: -0.5, // Tightened letter spacing looks very modern
                      color: AppColors.textMain,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Builder(
                  builder: (context) => Text(
                    context.loc.viewTour, 
                    textAlign: TextAlign.center, 
                    style: const TextStyle(
                      fontSize: 14, 
                      color: Colors.grey, 
                      height: 1.4, // Better line height for reading
                    ),
                  ),
                ),
                
                const SizedBox(height: 28),
                
                // 3. FULL-WIDTH CTA BUTTON
                SizedBox(
                  width: double.infinity, // Makes the button stretch the full width of the card
                  child: ElevatedButton.icon( // Changed to .icon to add an arrow!
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const RouteSuggestionScreen())),
                    icon: const Icon(Icons.arrow_forward_rounded, size: 20),
                    label: Builder(
                      builder: (context) => Text(
                        context.loc.letsGo, 
                        style: const TextStyle(
                          fontSize: 16, 
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary, 
                      foregroundColor: AppColors.white,
                      elevation: 0, // Removes the harsh button shadow to keep the matte look
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );      },
    );  }
}
