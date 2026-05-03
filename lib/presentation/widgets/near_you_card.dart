import 'package:flutter/material.dart';
import '../../core/theme.dart'; 
import '../screens/event_details_screen.dart';
import '../../core/utils/bilingual_helper.dart';

/// [NearYouCard] is a specialized UI component used to display localized 
/// event data in a horizontal list. It features a layout optimized for 
/// quick scannability of distance and travel time.
class NearYouCard extends StatelessWidget {
  /// The [locationData] map contains all Firestore attributes for the event,
  /// including bilingual titles and calculated distance metrics.
  final Map<String, dynamic> locationData;

  const NearYouCard({super.key, required this.locationData});

  @override
  Widget build(BuildContext context) {
    // 1. DYNAMIC DATA RESOLUTION:
    // Resolves bilingual fields (Maps) into localized Strings based on active locale.
    final String title = BilingualHelper.getText(locationData['Title'], context);
    final String distance = locationData['distance']?.toString() ?? '---';
    final String time = locationData['time']?.toString() ?? '---';
    
    // Resolves image source, supporting multiple potential database keys.
    final String imageUrl = BilingualHelper.getText(
      locationData['Image'] ?? locationData['Image_Url'], 
      context
    );

    return GestureDetector(
      onTap: () {
        // Navigation: Routes the user to the detailed view, passing the raw data map.
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EventDetailsScreen(eventData: locationData),
          ),
        );
      },
      child: Container(
        width: 310, 
        margin: const EdgeInsets.only(right: 16, bottom: 8),
        decoration: BoxDecoration(
          color: AppColors.white, 
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 24,
              offset: const Offset(0, 8),
            )
          ],
        ),
        child: Row(
          children: [
            // --- VISUAL SECTION ---
            // Displays the event thumbnail with a rounded corner treatment.
            Container(
              width: 100,
              margin: const EdgeInsets.all(12), 
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                image: DecorationImage(
                  image: NetworkImage(
                    imageUrl.isNotEmpty ? imageUrl : 'https://placehold.co/100x100/png?text=No+Image'
                  ), 
                  fit: BoxFit.cover,
                ),
              ),
            ),
            
            // --- CONTENT SECTION ---
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start, 
                  mainAxisAlignment: MainAxisAlignment.center, 
                  children: [
                    // Title: Constrained to 2 lines for UI consistency.
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
                    
                    // Proximity Metrics:
                    // Displays calculated distance and estimated drive-time (Riyadh traffic context).
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
                              style: const TextStyle(
                                fontSize: 11, 
                                color: Colors.grey, 
                                fontWeight: FontWeight.w500
                              ),
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
