import 'package:flutter/material.dart';
import '../../core/theme.dart'; 

/// A reusable visual component representing a single location card.
/// It displays an image, the location title, and the dynamically calculated distance.
class NearYouCard extends StatelessWidget {
  // We use <String, dynamic> here so the card can accept both text (like the title)
  // and math outputs (like the raw distance number) without Dart throwing a type error.
  final Map<String, dynamic> locationData;

  const NearYouCard({super.key, required this.locationData});

  @override
  Widget build(BuildContext context) {
    // 1. BULLETPROOF DATA EXTRACTION:
    final String title = locationData['Title']?.toString() ?? 
                         'Unknown Location';
                         
    final String distance = locationData['distance']?.toString() ?? 'Unknown distance';

    // 2. MAIN CARD CONTAINER:
    return Container(
      width: 280, 
      margin: const EdgeInsets.only(right: 16, bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.white, // Mapped to theme
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 12, offset: Offset(0, 4))
        ],
      ),
      // 3. HORIZONTAL LAYOUT: 
      // A Row is used to keep the image strictly on the left, and text on the right.
      child: Row(
        children: [
          // --- IMAGE SECTION ---
          Container(
            width: 100,
            margin: const EdgeInsets.all(12), 
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              image: const DecorationImage(
                image: NetworkImage('https://placehold.co/100x100/png?text=Nearby Event'), 
                fit: BoxFit.cover,
              ),
            ),
          ),
          
          // --- TEXT SECTION ---
          // Expanded ensures long event titles wrap to a new line instead of overflowing off-screen
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start, 
                mainAxisAlignment: MainAxisAlignment.center, 
                children: [
                  Text(
                    title,
                    maxLines: 2, // Caps the title at 2 lines
                    overflow: TextOverflow.ellipsis, // Adds '...' if the title is too long
                    style: AppTextStyles.subtitle.copyWith(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textMain, // Mapped to theme
                    ),
                  ),
                  const SizedBox(height: 6), 
                  Text(
                    distance,
                    style: AppTextStyles.subtitle.copyWith(
                      fontSize: 12,
                      color: AppColors.primary, // Highlights distance in brand colors
                      fontWeight: FontWeight.w600,
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
}