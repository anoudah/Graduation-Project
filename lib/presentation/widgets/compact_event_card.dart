import 'package:flutter/material.dart';
// Make sure this points to your actual theme file!
import '../../core/theme.dart'; 

class CompactEventCard extends StatelessWidget {
  // Accepts the live mixed data from Python
  final Map<String, dynamic> eventData;

  const CompactEventCard({Key? key, required this.eventData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 1. IMAGE SAFETY CHECK: Intercept bad URLs from Firebase
    String imageUrl = eventData['Image_Url'] ?? '';
    if (imageUrl.isEmpty || imageUrl.contains('via.placeholder.com')) {
      // Force it to use the web-safe placeholder
      imageUrl = 'https://placehold.co/400x300/png?text=Culture+Event';
    }

    return Container(
      width: 220, // FIXED WIDTH: Keeps all cards the exact same size horizontally
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ==============================
          // 1. FIXED IMAGE SECTION
          // ==============================
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Image.network(
              imageUrl,
              height: 120, // FIXED HEIGHT: Stops images from stretching
              width: double.infinity,
              fit: BoxFit.cover, // Crops perfectly
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 120,
                  color: AppColors.avatarBg,
                  child: const Center(child: Icon(Icons.image_not_supported, color: AppColors.iconGrey)),
                );
              },
            ),
          ),
          
          // ==============================
          // 2. TEXT SECTION (FLEXIBLE ALIGNMENT)
          // ==============================
          Expanded( // EXPANDED: Forces this area to stretch, making cards even height
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    eventData['Title'] ?? 'Unknown Event',
                    style: AppTextStyles.sectionTitle.copyWith(fontSize: 14),
                    maxLines: 2, // Locks to 2 lines maximum
                    overflow: TextOverflow.ellipsis, // Adds "..." if it's too long
                  ),
                  const SizedBox(height: 4),
                  Text(
                    eventData['Category'] ?? '',
                    style: AppTextStyles.subtitle.copyWith(fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  // SPACER: This pushes the bottom row down so everything aligns perfectly!
                  const Spacer(), 
                  
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        eventData['Price'] != null ? '${eventData['Price']}' : 'Free',
                        style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 14),
                          const SizedBox(width: 4),
                          Text(
                            '${eventData['Rating'] ?? 4.0}',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ],
                      )
                    ],
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}