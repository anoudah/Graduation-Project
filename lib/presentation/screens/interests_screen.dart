import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'home_screen.dart';
import '../../core/theme.dart';
import '../../core/localization/app_localizations.dart';

/// --- DATA LAYER ---
/// [InterestItem] acts as a structured model for onboarding categories.
/// 
/// Using a dedicated model instead of raw Maps ensures type safety across 
/// the application and prevents typo-driven bugs when mapping localized 
/// UI strings to backend database IDs.
class InterestItem {
  final String id;
  final String label;
  InterestItem({required this.id, required this.label});
}

/// --- PRESENTATION LAYER ---
/// [InterestsScreen] acts as the final step in the user onboarding funnel.
/// 
/// **Key Responsibilities:**
/// 1. **Responsive Architecture**: Dynamically shifts between a split-pane layout 
///    for wide screens (>800px) and a stacked scrollable layout for mobile.
/// 2. **State Management**: Tracks user selections locally before committing to the DB.
/// 3. **Firebase Integration**: Merges the selected array into the user's existing profile.
class InterestsScreen extends StatefulWidget {
  const InterestsScreen({super.key});

  @override
  State<InterestsScreen> createState() => _InterestsScreenState();
}

class _InterestsScreenState extends State<InterestsScreen> {
  // --- STATE VARIABLES ---
  
  /// Stores the unique [id]s of the interests the user has tapped.
  /// Utilizing a [Set] guarantees optimal O(1) lookups and naturally prevents duplicate entries.
  final Set<String> _selectedIds = {};
  
  /// Manages the UI loading state during asynchronous database writes to prevent 
  /// double-submissions and provide visual feedback.
  bool _isLoading = false;

  /// --- DATABASE LOGIC ---
  /// Finalizes the account setup by writing the selected interests to Firestore.
  Future<void> _finishAccountCreation(AppLocalizations loc) async {
    final user = FirebaseAuth.instance.currentUser;
    
    // Auth Gatekeeper: Ensure the session is still valid before attempting writes.
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
      // DB Write: Target the specific user document.
      // CRITICAL: SetOptions(merge: true) is used so we only update the specific 
      // 'selected_interests' fields without accidentally deleting their Name or Email.
      await FirebaseFirestore.instance.collection('Users').doc(user.uid).set({
        'selected_interests': _selectedIds.toList(), // Convert Set to List for JSON compatibility
        'Selection_Date': FieldValue.serverTimestamp(),
        'setup_complete': true,
      }, SetOptions(merge: true)); 

      if (!mounted) return;

      // Routing: Push to Home and destroy the navigation history.
      // This prevents the user from using the physical Android back button to return to onboarding.
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

  /// Toggles the selection state of an interest card.
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
    
    // --- RESPONSIVE BREAKPOINT LOGIC ---
    // Evaluates the screen width to determine the rendering path (Mobile vs Web/Tablet).
    final bool isMobile = MediaQuery.of(context).size.width < 800;

    // Bilingual Data Source initialization.
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
      // Render Tree Branching:
      // If Mobile (<800px): Render a single vertically scrolling column.
      // If Web (>800px): Render a side-by-side Row layout.
      body: isMobile
          ? SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 40),
                    _buildBrandingSection(loc, isMobile),
                    const SizedBox(height: 30),
                    // Horizontal Divider for vertical mobile flow
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40.0),
                      child: Divider(color: AppColors.divider.withValues(alpha: 0.5), thickness: 1.5),
                    ),
                    _buildGridSection(loc, categories, isMobile),
                  ],
                ),
              ),
            )
          : Row(
              children: [
                Expanded(
                  flex: 3,
                  child: _buildBrandingSection(loc, isMobile),
                ),
                // Vertical Divider for horizontal wide-screen flow
                Container(
                  width: 1.5,
                  color: AppColors.divider.withValues(alpha: 0.5),
                  height: MediaQuery.of(context).size.height * 0.7,
                ),
                Expanded(
                  flex: 7,
                  child: SingleChildScrollView(
                    child: _buildGridSection(loc, categories, isMobile),
                  ),
                ),
              ],
            ),
    );
  }

  /// Builds the left-hand branding panel (or top panel on mobile).
  /// Dynamically adjusts font sizes and padding based on the [isMobile] flag.
  Widget _buildBrandingSection(AppLocalizations loc, bool isMobile) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 24.0 : 40.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            "WASEL",
            style: TextStyle(
              fontSize: isMobile ? 32 : 42, 
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
              letterSpacing: 8,
            ),
          ),
          SizedBox(height: isMobile ? 20 : 40),
          Text(
            loc.welcomeToWasel,
            textAlign: TextAlign.center, 
            style: TextStyle(
              fontSize: isMobile ? 24 : 32, 
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
          SizedBox(height: isMobile ? 16 : 32),
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
    );
  }

  /// Builds the interactive selection grid and submit button.
  /// Uses [ConstrainedBox] to prevent infinite stretching on ultra-wide web monitors.
  Widget _buildGridSection(AppLocalizations loc, List<InterestItem> categories, bool isMobile) {
    // Show a loading spinner during database writes
    if (_isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(40.0),
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 24 : 60, 
        vertical: isMobile ? 20 : 40,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Interests",
            style: TextStyle(
              fontSize: isMobile ? 32 : 42,
              fontWeight: FontWeight.bold,
              color: AppColors.textMain,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            "Select multiple options to personalize your Riyadh experience.",
            style: TextStyle(fontSize: 18, color: AppColors.textSecondary),
          ),
          SizedBox(height: isMobile ? 30 : 48),
          
          // --- THE GRID ---
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600), 
            child: GridView.builder(
              shrinkWrap: true, // Forces GridView to size itself to its children
              physics: const NeverScrollableScrollPhysics(), // Delegates scrolling to the parent SingleChildScrollView
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, 
                crossAxisSpacing: 16, 
                mainAxisSpacing: 16, 
                mainAxisExtent: 70, // Fixed height prevents buttons from vertically expanding
              ),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final item = categories[index];
                final isSelected = _selectedIds.contains(item.id);
                return _buildModernCard(item, isSelected);
              },
            ),
          ),
          SizedBox(height: isMobile ? 40 : 60),
          
          // --- ACTION BUTTON ---
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600), 
            child: SizedBox(
              width: double.infinity,
              height: 56, 
              child: ElevatedButton(
                // Logic: Disable the button (returns null) if no interests are selected
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
    );
  }

  /// Renders individual interactive category cards.
  /// 
  /// Utilizes [AnimatedContainer] to provide smooth, premium color and shadow 
  /// transitions when the user taps to select or deselect an item.
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
            // Adds depth when selected to make it "pop"
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