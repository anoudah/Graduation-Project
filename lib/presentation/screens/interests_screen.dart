import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'home_screen.dart';
import '../../core/theme.dart';
import '../../core/localization/app_localizations.dart';

/// Data model to handle localizations and selection logic together
class InterestItem {
  final String id;
  final String label;
  InterestItem({required this.id, required this.label});
}

class InterestsScreen extends StatefulWidget {
  const InterestsScreen({super.key});

  @override
  State<InterestsScreen> createState() => _InterestsScreenState();
}

class _InterestsScreenState extends State<InterestsScreen> {
  final Set<String> _selectedIds = {};
  bool _isLoading = false;

  /// Saves the selected interests to Firestore and navigates home
  Future<void> _finishAccountCreation(AppLocalizations loc) async {
    final user = FirebaseAuth.instance.currentUser;
    
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
      await FirebaseFirestore.instance.collection('Users').doc(user.uid).set({
        'selected_interests': _selectedIds.toList(),
        'Selection_Date': FieldValue.serverTimestamp(),
        'setup_complete': true,
      }, SetOptions(merge: true));

      if (!mounted) return;

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

    // Dynamic list based on your localizations
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
          // --- LEFT SECTION: BRANDING & PROGRESS ---
          Expanded(
            flex: 3,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "WASEL",
                  style: TextStyle(
                    fontSize: 56,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                    letterSpacing: 10,
                  ),
                ),
                const SizedBox(height: 60),
                Text(
                  loc.welcomeToWasel,
                  style: const TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textMain,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  "STEP 02",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                    color: AppColors.primary.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 48),
                Text(
                  loc.pickYourInterests,
                  style: const TextStyle(
                    fontSize: 20,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          // Vertical structural divider
          Container(
            width: 1.5,
            color: AppColors.divider.withOpacity(0.5),
            height: MediaQuery.of(context).size.height * 0.7,
          ),

          // --- RIGHT SECTION: INTERESTS GRID ---
          Expanded(
            flex: 7,
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                : Container(
                    padding: const EdgeInsets.symmetric(horizontal: 60),
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
                        
                        // --- GRID ---
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 800),
                          child: GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 24,
                              mainAxisSpacing: 24,
                              childAspectRatio: 2.8,
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
                          constraints: const BoxConstraints(maxWidth: 800),
                          child: SizedBox(
                            width: double.infinity,
                            height: 62,
                            child: ElevatedButton(
                              onPressed: _selectedIds.isNotEmpty 
                                  ? () => _finishAccountCreation(loc) 
                                  : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: Text(
                                loc.continueToHome,
                                style: const TextStyle(
                                  color: AppColors.white,
                                  fontSize: 20,
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
        ],
      ),
    );
  }

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
                  ? AppColors.primary.withOpacity(0.2) 
                  : Colors.black.withOpacity(0.03),
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