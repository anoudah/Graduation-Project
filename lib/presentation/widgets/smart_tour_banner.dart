import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../core/localization/localization_extension.dart';
import '../screens/smart_tour_screen.dart';

class SmartTourBanner extends StatelessWidget {
  const SmartTourBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          // Decorative divider to separate the list content from the footer banner
          const Divider(color: AppColors.divider, thickness: 1, height: 32),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 16, offset: Offset(0, 4))],
            ),
            child: Column(
              children: [
                Builder(
                  builder: (context) => Text(context.loc.smartTour, textAlign: TextAlign.center, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 12),
                Builder(
                  builder: (context) => Text(context.loc.viewTour, textAlign: TextAlign.center, style: AppTextStyles.subtitle),
                ),
                const SizedBox(height: 28),
                // Primary button to trigger the Smart Tour AI flow
                ElevatedButton(
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SmartTourScreen())),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary, 
                    foregroundColor: AppColors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  ),
                  child: Builder(
                    builder: (context) => Text(context.loc.letsGo, style: AppTextStyles.buttonText),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}