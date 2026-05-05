import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../screens/route_suggestion_screen.dart';
import '../../core/localization/localization_extension.dart';
import '../../application/providers/language_provider.dart';

/// --- PRESENTATION LAYER ---
/// [SmartTourBanner] is a highly reusable call-to-action (CTA) widget.
/// 
/// It is designed to be placed at the bottom of standard category lists. 
/// Its primary job is to entice the user to try the AI feature and seamlessly 
/// hand off their current context (via [categoryId]) to the AI route generator.
class SmartTourBanner extends StatelessWidget {
  
  /// The optional ID of the category this banner is placed under (e.g., "Heritage").
  /// If provided, this ID is passed to the AI engine to automatically filter 
  /// the suggested tour to match the user's current interests.
  final String? categoryId;

  const SmartTourBanner({super.key, this.categoryId});

  @override
  Widget build(BuildContext context) {
    // Consumer ensures the banner text instantly translates when the language toggles
    return Consumer<LanguageProvider>(
      builder: (context, languageProvider, _) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            children: [
              // Visual separator to distinguish the banner from the list above it
              const Divider(color: AppColors.divider, thickness: 1, height: 32),
              const SizedBox(height: 16),
              
              // =================================================================
              // BANNER CONTAINER
              // Uses a soft shadow to create depth, making it look clickable and premium.
              // =================================================================
              Container(
                padding: const EdgeInsets.all(24), 
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.08),
                      blurRadius: 32,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // --- AI SPARKLE BADGE ---
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.auto_awesome, // Universally recognized AI symbol
                        color: AppColors.primary,
                        size: 32,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // --- TYPOGRAPHY & MESSAGING ---
                    Text(
                      context.loc.smartTour,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                        color: AppColors.textMain,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      context.loc.viewTour,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                        height: 1.4, // Improves readability for multi-line descriptions
                      ),
                    ),

                    const SizedBox(height: 28),

                    // =================================================================
                    // ACTION BUTTON & CONTEXT HANDOFF
                    // =================================================================
                    SizedBox(
                      width: double.infinity, // Forces the button to span the full width
                      child: ElevatedButton.icon(
                        // Handoff logic: Navigates to the suggestion screen and passes 
                        // the current categoryId so the AI knows exactly what the user wants.
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => RouteSuggestionScreen(
                              filterCategoryId: categoryId, 
                            ),
                          ),
                        ),
                        icon: const Icon(Icons.arrow_forward_rounded, size: 20),
                        label: Text(
                          context.loc.letsGo,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.white,
                          elevation: 0,
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
        );
      },
    );
  }
}