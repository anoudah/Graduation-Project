import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'home_screen.dart';
import '../../core/theme.dart';
import '../../core/localization/app_localizations.dart';

/// A simple data model to pair a unique database ID with a localized label.
/// 
/// Using a model instead of a raw Map makes the code type-safe and prevents
/// typos when accessing the [id] or [label] during rendering or database saves.
class InterestItem {
  final String id;
  final String label;
  InterestItem({required this.id, required this.label});
}

/// The Onboarding Screen where new users select their cultural interests.
/// 
/// This screen uses a responsive, split-pane layout (branding on the left, 
/// interactive grid on the right) and saves the user's selections directly 
/// to their Firestore profile before navigating to the Home Screen.
class InterestsScreen extends StatefulWidget {
  const InterestsScreen({super.key});

  @override
  State<InterestsScreen> createState() => _InterestsScreenState();
}

class _InterestsScreenState extends State<InterestsScreen> {
  /// Stores the unique [id]s of the interests the user has tapped.
  /// A [Set] is used instead of a List to guarantee no duplicate entries.
  final Set<String> _selectedIds = {};
  
  /// Controls the loading state of the "Continue" button to prevent double-submissions.
  bool _isLoading = false;

  /// Finalizes the account creation process by saving data to Firestore.
  /// 
  /// 1. Verifies the user is logged in.
  /// 2. Merges the selected interests into the user's existing Firestore document.
  /// 3. Navigates the user to the [HomeScreen], removing this setup screen from the navigation stack.
  Future<void> _finishAccountCreation(AppLocalizations loc) async {
    final user = FirebaseAuth.instance.currentUser;
    
    // Safety check: Prevent database writes if the session expired
    if (user == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(loc.pleaseLoginFirst)),
        );
      }
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Write the data to the 'Users' collection matching the specific user's UID
      await FirebaseFirestore.instance.collection('Users').doc(user.uid).set({
        'selected_interests': _selectedIds.toList(), // Convert Set back to List for JSON
        'Selection_Date': FieldValue.serverTimestamp(),
        'setup_complete': true,
      }, SetOptions(merge: true)); // merge: true protects existing data like Name/Email

      if (!mounted) return;

      // Navigate to Home and clear the back-history so the user can't swipe back to onboarding
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("${loc.databaseError}: $e")),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// Adds or removes an interest ID from the user's current selection.
  void _toggleInterest(String id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
      } else {
        _selectedIds.add(id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    // Initialize the list using the dynamic localized strings from the app's context.
    // The 'id' is what goes to the database, the 'label' is what the user sees.
    final List<InterestItem> categories = [
      InterestItem(id: 'museums', label: loc.museums),
      InterestItem(id: 'libraries', label: loc.libraries),
      InterestItem(id: 'heritage', label: loc.heritage),
      InterestItem(id: 'arts', label: loc.arts),
      InterestItem(id: 'technology', label: loc.technology),
      InterestItem(id: 'conferences', label: loc.conferences),
      InterestItem(id: 'food', label: loc.traditionalFood),
      InterestItem(id: 'festivals', label: loc.festivals),
    ];

    return Scaffold(
      backgroundColor: AppColors.white,
      body: Row(
        children: [
          // =================================================================
          // LEFT SECTION: Branding & Onboarding Progress
          // Occupies 30% of the screen width (flex: 3).
          // =================================================================
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center, // Keeps all text perfectly centered
                children: [
                  const Text(
                    "WASEL",
                    style: TextStyle(
                      fontSize: 42, 
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                      letterSpacing: 8,
                    ),
                  ),
                  const SizedBox(height: 40),
                  Text(
                    loc.welcomeToWasel,
                    textAlign: TextAlign.center, 
                    style: const TextStyle(
                      fontSize: 32, 
                      fontWeight: FontWeight.w900,
                      color: AppColors.textMain,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "STEP 02",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                      color: AppColors.primary.withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    loc.pickYourInterests,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16, 
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // =================================================================
          // VERTICAL DIVIDER: Visual separator between branding and action
          // =================================================================
          Container(
            width: 1.5,
            color: AppColors.divider.withValues(alpha: 0.5),
            height: MediaQuery.of(context).size.height * 0.7,
          ),

          // =================================================================
          // RIGHT SECTION: The Interactive Selection Grid
          // Occupies 70% of the screen width (flex: 7).
          // =================================================================
          Expanded(
            flex: 7,
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                // SingleChildScrollView prevents the "RenderFlex overflow" yellow tape error
                // if the screen is resized vertically.
                : SingleChildScrollView( 
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 40),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Interests",
                            style: TextStyle(
                              fontSize: 42,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textMain,
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            "Select multiple options to personalize your Riyadh experience.",
                            style: TextStyle(fontSize: 18, color: AppColors.textSecondary),
                          ),
                          const SizedBox(height: 48),
                          
                          // --- THE GRID ---
                          // ConstrainedBox prevents the grid from stretching infinitely on ultra-wide monitors
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 600), 
                            child: GridView.builder(
                              shrinkWrap: true, // Forces the GridView to size itself to its children
                              physics: const NeverScrollableScrollPhysics(), // Let the parent SingleChildScrollView handle scrolling
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2, // 2 columns
                                crossAxisSpacing: 20, // Horizontal gap
                                mainAxisSpacing: 20, // Vertical gap
                                mainAxisExtent: 70, // FIXED HEIGHT: Stops buttons from becoming massive vertically
                              ),
                              itemCount: categories.length,
                              itemBuilder: (context, index) {
                                final item = categories[index];
                                final isSelected = _selectedIds.contains(item.id);
                                return _buildModernCard(item, isSelected);
                              },
                            ),
                          ),
                          const SizedBox(height: 60),
                          
                          // --- ACTION BUTTON ---
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 600), // Aligns perfectly with the grid above
                            child: SizedBox(
                              width: double.infinity,
                              height: 56, // Fixed UI height for the button
                              child: ElevatedButton(
                                // Disable the button (returns null) if no interests are selected
                                onPressed: _selectedIds.isNotEmpty 
                                    ? () => _finishAccountCreation(loc) 
                                    : null,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: AppColors.white,
                                  disabledBackgroundColor: Colors.grey.shade200, 
                                  disabledForegroundColor: Colors.grey.shade500, 
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                child: Text(
                                  loc.continueToHome,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  /// Builds the individual selectable interest cards.
  /// 
  /// Uses an [AnimatedContainer] to provide smooth, premium color transitions 
  /// when the user taps on a card to select or deselect it.
  Widget _buildModernCard(InterestItem item, bool isSelected) {
    return GestureDetector(
      onTap: () => _toggleInterest(item.id),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.divider,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected 
                  ? AppColors.primary.withValues(alpha: 0.2) 
                  : Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Text(
          item.label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isSelected ? AppColors.white : AppColors.textMain,
            fontSize: 16,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}