import 'package:flutter/material.dart';
import '../../core/theme.dart'; 
import '../screens/event_details_screen.dart';

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
    final String title = locationData['Title']?.toString() ?? 'Unknown Location';
    final String distance = locationData['distance']?.toString() ?? 'Unknown distance';
    final String time = locationData['time']?.toString() ?? 'Unknown time';
    final String imageUrl = locationData['Image']?.toString() ?? locationData['Image_Url']?.toString() ?? 'https://placehold.co/100x100/png?text=No+Image';

    // 2. MAIN CARD CONTAINER: 
    // Wrap the entire card in a GestureDetector so tapping anywhere opens the details!
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            // We pass 'locationData' so the details screen knows which event to show.
            builder: (context) => EventDetailsScreen(eventData: locationData),
          ),
        );
        debugPrint("WASEL: Opening Details for $title"); 
      },
      child: Container(
        width: 310, 
        margin: const EdgeInsets.only(right: 16, bottom: 8),
        decoration: BoxDecoration(
          color: AppColors.white, 
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04), // Barely visible color
            blurRadius: 24, // Huge blur for softness
            offset: const Offset(0, 8), // Pushed down slightly
          )
        ],
        ),
        child: Row(
          children: [
            // --- IMAGE SECTION ---
            Container(
              width: 100,
              margin: const EdgeInsets.all(12), 
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                image: DecorationImage(
                  image: NetworkImage(imageUrl), 
                  fit: BoxFit.cover,
                ),
              ),
            ),
            
            // --- TEXT SECTION ---
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start, 
                  mainAxisAlignment: MainAxisAlignment.center, 
                  children: [
                    Text(
                      title,
                      maxLines: 2, 
                      overflow: TextOverflow.ellipsis, 
                      style: AppTextStyles.subtitle.copyWith(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textMain, 
                      ),
                    ),
                    const SizedBox(height: 8), 
                    
                    // --- Distance & Time Stack ---
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.location_on, size: 14, color: AppColors.primary),
                            const SizedBox(width: 4),
                            Text(
                              distance,
                              style: AppTextStyles.subtitle.copyWith(
                                fontSize: 12,
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4), 
                        Row(
                          children: [
                            const Icon(Icons.directions_car, size: 14, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text(
                              time,
                              style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}